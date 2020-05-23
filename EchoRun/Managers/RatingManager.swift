//
//  RatingManager.swift
//  innate
//
//  Created by Joeri Bultheel on 07/04/2020.
//  Copyright © 2020 dataexcess. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyUserDefaults

extension DefaultsKeys {
    var searchCount: DefaultsKey<Int> { .init("searchCount", defaultValue: 0) }
}

class RatingManager: NSObject {
    
    static let sharedInstance = RatingManager()
    
    public func incrementSearchCount() {
        Defaults[\.searchCount] += 1
    }
    
    public func checkAndAskForReview() {
        switch Defaults[\.searchCount] {
        case 5:
            requestReview()
        case _ where Defaults[\.searchCount]%10 == 0:
            requestReview()
        default:
            break;
        }
    }
    
    private func requestReview() {
        SKStoreReviewController.requestReview()
    }
}
