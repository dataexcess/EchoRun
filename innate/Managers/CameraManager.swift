//
//  CameraManager.swift
//  innate
//
//  Created by Joeri Bultheel on 16/08/2019.
//  Copyright © 2019 dataexcess. All rights reserved.
//

import UIKit

protocol CameraManagerDelegate {
    func didSucceedInFetchingCameraImage(img:UIImage)
    func didFailInFetchingCameraImage()
}

class CameraManager: NSObject {
    
    static let sharedInstance = CameraManager()
    let imagePicker = UIImagePickerController()
    var delegate:CameraManagerDelegate? = nil
    
    func openCamera(fromViewController vc:UIViewController) {
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        
        vc.present(imagePicker, animated: true)
    }
}

extension CameraManager : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        defer { picker.dismiss(animated: true) }
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            delegate?.didFailInFetchingCameraImage()
            return
        }
        
        delegate?.didSucceedInFetchingCameraImage(img: image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer { picker.dismiss(animated: true) }
        delegate?.didFailInFetchingCameraImage()
    }
}
