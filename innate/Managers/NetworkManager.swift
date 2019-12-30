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
let kRegexVisuallySimilarLink = "href=\"((?:(?!href).)*?)\">Visually similar"
let kRegexVisuallySimilarImageURLs = "\"ou\":\"((?:(?!\"ou\":\").)*?)\",\"ow\""
let kMultipartFormDataNameKey = "encoded_image"
let kMultipartFormDataFileNameKey = "image.jpg"
let kMultipartFormDataMimeTypeKey = "image/jpg"
let kHeaderAcceptLanguage = "en-US,en-GB,en;q=1.0"
let kHeaderUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36"

enum NetworkingError: Error, LocalizedError {
    case uploadError
    case parsingError
    case dataError
    case connectionError
    case notFound
    
    public var errorDescription: String? {
        switch self {
        case .uploadError:
            return NSLocalizedString("⌿ upload error ⍀", comment: "")
        case .parsingError:
            return NSLocalizedString("⌿ parsing error ⍀", comment: "")
        case .dataError:
            return NSLocalizedString("⌿ data error ⍀", comment: "")
        case .connectionError:
            return NSLocalizedString("⌿ connection error ⍀", comment: "")
        case .notFound:
            return NSLocalizedString("⌿ not found ⍀", comment: "")
        }
    }
}

class NetworkManager: NSObject {
    static let sharedInstance = NetworkManager()
    let headers: HTTPHeaders = [
        "Accept-Language": kHeaderAcceptLanguage,
        "User-Agent": kHeaderUserAgent
    ]
    
    func findVisuallySimilarImagesFor(image:UIImage,
                                      withCompletionHandler completionHandler:@escaping (_:[URL])->(),
                                      andFailureHandler failurehandler:@escaping (_:NetworkingError)->()){
        
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
        guard let url = URL(string: locationString) else { return nil }
        
        return url
    }
    
    func getVisuallySimilarButtonLinkURL(inResponse response:String) -> URL? {
        
        guard let regexResult = kRegexVisuallySimilarLink.r?.findFirst(in: response)?.group(at: 1) else { return nil }
        guard let url = URL(string: "https://www.google.com" + regexResult.replacingOccurrences(of: "&amp;", with: "&")) else { return nil }
        
        return url
    }
    
    func getVisuallySimilarImageURLs(inResponse response:String) -> [URL]? {
        
        guard let result = kRegexVisuallySimilarImageURLs.r?.findAll(in: response) else { return nil }
        let urls = result.map{ URL(string: $0.group(at: 1)!)}.compactMap{ $0 }
        guard urls.count > 0 else { return nil }
        
        return urls
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
            guard let image = response.result.value else { failureHandler(.dataError); return }
            completionHandler(image)
        }
    }
}
