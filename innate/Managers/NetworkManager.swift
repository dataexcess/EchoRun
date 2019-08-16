//
//  NetworkManager.swift
//  innate
//
//  Created by Joeri Bultheel on 16/08/2019.
//  Copyright © 2019 dataexcess. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

let kGoogleImageSearchURL = "https://www.google.com/searchbyimage/upload"
let kEncodedImageKey = "encoded_image"

class NetworkManager: NSObject {
    static let sharedInstance = NetworkManager()
    
    func uploadImage(_ image:UIImage) {
        
        let imageData = image.jpegData(compressionQuality: 0.0)
        
            Alamofire.upload(multipartFormData: {
            
            multipartFormData in
            multipartFormData.append(imageData!,
                                     withName: "encoded_image",
                                     fileName: "my_image.jpg",
                                     mimeType: "image/jpg")
            },
                         to: URL(string: kGoogleImageSearchURL)!,
                         encodingCompletion: {
                            
                            encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.response {
                                    
                                    response in
                                    self.parse(response: response)
                                    
                                }
                            case .failure(let encodingError):
                                print(encodingError)
                            }
        })
    }
    
    func parse(response :DefaultDataResponse) {
        
        guard let metrics = response.metrics else { return }
        guard let transactionMetrics = metrics.transactionMetrics[0].response as? HTTPURLResponse else { return }
        guard let location = transactionMetrics.allHeaderFields["Location"] else { return }
        guard let locationString = location as? String else { return }
        guard let url = URL(string: locationString) else { return }
        
        getVisuallySimilarImage(fromUrl: url)
    }
    
    func getVisuallySimilarImage(fromUrl url:URL) {
        
        print(url.absoluteString)
        
        Alamofire.SessionManager.default.session.configuration.httpShouldSetCookies = false
        Alamofire.request(url).response {
            response in
            print(response)
        }
        
        let url_ = "https://www.google.com/webhp?tbs=sbi:AMhZZivGExkvmpguEZhe42DkT_1rMlcib7qBIztMPGfETwnezLiPyUSkqWXCvkcNvYoMmGZUT6OZrP27vhKRuaEWMFjjIQNdxDTmtkHYapxOICPAwLiP7BF6CRWnP-AGa5-Skoqjt6yKiQ8NGSJTJs5tADelkjneEVMDLMMbg6OuEhxorXiOpFlKX5kr3NDb6z8MAbdjkGGkJdEAzfvloCgJiojx6FeKlyy1fLAYns5faQjLlUjRYoD0nErpyoDaiKrlIVr4VQF_18KFxxm4xnX2UNQmLvHvaBUT3xbYofqMS49r2Yp0wJRVCLSc-rIzRCZscc8CnV4hHv"
        
        print(url_)
    }
}
