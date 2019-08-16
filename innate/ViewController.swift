//
//  ViewController.swift
//  innate
//
//  Created by Joeri Bultheel on 16/08/2019.
//  Copyright © 2019 dataexcess. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        CameraManager.sharedInstance.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CameraManager.sharedInstance.openCamera(fromViewController: self)
    }
}

extension ViewController : CameraManagerDelegate {
    
    func didFailInFetchingCameraImage() {
        print("FAIL")
    }
    
    func didSucceedInFetchingCameraImage(img: UIImage) {
        print("SUCCEED")
        NetworkManager.sharedInstance.uploadImage(img)
    }
}

