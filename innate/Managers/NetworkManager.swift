//
//  NetworkManager.swift
//  innate
//
//  Created by Joeri Bultheel on 16/08/2019.
//  Copyright © 2019 dataexcess. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Regex

let kGoogleImageSearchURL = "https://www.google.com/searchbyimage/upload"
let kRegexVisuallySimilarLink = "href=((?:(?!href).)*?)>Visually similar"
let kRegexVisuallySimilarImageURLs = "(http[^\\s]+(jpg|jpeg|png|tiff)\\b)"
let kMultipartFormDataNameKey = "encoded_image"
let kMultipartFormDataFileNameKey = "image.jpg"
let kMultipartFormDataMimeTypeKey = "image/jpg"
let kHeaderAcceptLanguage = "en-US,en-GB,en;q=1.0"
let kHeaderContentType = "image"
let kHeaderUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36"
let kBaseURL = "https://www.google.com"

enum NetworkingError: Error, LocalizedError {
    case uploadError
    case parsingError
    case dataError
    case connectionError
    case notFound
    
    public var errorDescription: String? {
        switch self {
        case .uploadError:
            return NSLocalizedString("upload error", comment: "")
        case .parsingError:
            return NSLocalizedString("parsing error", comment: "")
        case .dataError:
            return NSLocalizedString("data error", comment: "")
        case .connectionError:
            return NSLocalizedString("connection error", comment: "")
        case .notFound:
            return NSLocalizedString("not found", comment: "")
        }
    }
}

final class NetworkManager: NSObject {
    
    public static let sharedInstance = NetworkManager()
    private let headers: HTTPHeaders = [
        "Accept-Language": kHeaderAcceptLanguage,
        "User-Agent": kHeaderUserAgent,
        //"Content-Type": kHeaderContentType,
    ]
    
    func findVisuallySimilarImagesFor(image:UIImage,
                                      withCompletionHandler completionHandler:@escaping (_:[URL])->(),
                                      andFailureHandler failurehandler:@escaping (_:NetworkingError)->()) {
        clearCookies()
        upload(image: image) {
            response in
            guard let uploadResultURL = self.getImageSearchUploadResultURL(forResponse: response) else {
                failurehandler(.uploadError); return
            }
            self.request(uploadResultURL) {
                response in
                guard let visuallySimilarURL = self.getVisuallySimilarButtonLinkURL(inResponse: response) else {
                    failurehandler(.parsingError); return
                }
                self.request(visuallySimilarURL) {
                    response in
                    guard let imageURLs = self.getVisuallySimilarImageURLs(inResponse: response) else {
                        failurehandler(.notFound); return
                    }
                    completionHandler(imageURLs)
                }
            }
        }
    }
    
    func getImageSearchUploadResultURL(forResponse response :DefaultDataResponse) -> URL? {
        guard let metrics = response.metrics else { return nil }
        guard let transactionMetrics = metrics.transactionMetrics[0].response as? HTTPURLResponse else { return nil }
        guard let location = transactionMetrics.allHeaderFields["Location"] else { return nil }
        guard let locationString = location as? String else { return nil }
        guard let URL = URL(string: locationString) else { return nil }

        return URL
    }
    
    func getVisuallySimilarButtonLinkURL(inResponse response:String) -> URL? {
        guard var regexResult = kRegexVisuallySimilarLink.r?.findFirst(in: response)?.group(at: 1) else { return nil }
        guard var URLString = (kBaseURL + regexResult.convertSpecialCharacters()).components(separatedBy: " ").first else { return nil }
        if URLString.last == ">" { URLString = String(URLString.dropLast()) }
        guard let URL = URL(string: URLString) else { return nil }
        return URL
    }
    
    func getVisuallySimilarImageURLs(inResponse response:String) -> [URL]? {
        let matched = matches(for: kRegexVisuallySimilarImageURLs, in: response)
        let filtered = matched.filter({ (match:String) -> Bool in !match.contains("google") }).filter({ (match:String) -> Bool in !match.contains("gstatic") })
        let URLs = filtered.map{ URL(string: $0)}.compactMap{ $0 }
        guard URLs.count > 0 else { return nil }
        return URLs
    }
    
    //MARK: HELPER METHODS
    
    func request(_ url:URL,
                 withCompletionHandler completionHandler:@escaping (_:String)->()) {
        
        Alamofire.request(url,
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers: headers).responseString {
                            
                            response in
                            guard let responseString = response.result.value else { return }
                            completionHandler(responseString)
        }
    }
    
    func upload(image:UIImage,
                withCompletionHandler completionHandler:@escaping (_:DefaultDataResponse)->()) {
        
        let imageData = image.jpegData(compressionQuality: 0.0)
        
        Alamofire.upload(multipartFormData: {
            
            multipartFormData in
            multipartFormData.append(imageData!,
                                     withName: kMultipartFormDataNameKey,
                                     fileName: kMultipartFormDataFileNameKey,
                                     mimeType: kMultipartFormDataMimeTypeKey)
        },
                         to: URL(string: kGoogleImageSearchURL)!,
                         encodingCompletion: {
                            
                            encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.response {
                                    
                                    response in
                                    completionHandler(response)
                                }
                            case .failure(let encodingError):
                                print(encodingError)
                            }
        })
    }
    
    func download(imageURL:URL,
                  withCompletionHandler completionHandler:@escaping (_:UIImage)->(),
                  andFailureHandler failureHandler:@escaping (_:NetworkingError)->()){
        Alamofire.request(imageURL).responseImage {
            
            response in
            guard let image = response.result.value else {
                failureHandler(.dataError);
                return
            }
            completionHandler(image)
        }
    }
    
    func matches(for regex: String!, in text: String!) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func clearCookies() {
        let cstorage = HTTPCookieStorage.shared
        if let cookies = cstorage.cookies(for: URL(string: kBaseURL)!) {
            for cookie in cookies {
                cstorage.deleteCookie(cookie)
            }
        }
    }
}
