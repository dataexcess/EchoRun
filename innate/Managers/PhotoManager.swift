//
//  CameraManager.swift
//  innate
//
//  Created by Joeri Bultheel on 16/08/2019.
//  Copyright © 2019 dataexcess. All rights reserved.
//

import UIKit

protocol PhotoManagerDelegate {
    func didSucceedInFetchingImage(cameraImage:UIImage)
    func didFailInFetchingImage()
    func didSucceedInSavingPhoto()
    func didFailInSavingPhoto(_:Error)
}

class PhotoManager: NSObject {
    
    static let sharedInstance = PhotoManager()
    let imagePicker = ImagePickerController()
    var delegate:PhotoManagerDelegate? = nil
    
    override init() {
        super.init()
        imagePicker.delegate = self
    }
    
    func openCamera(fromViewController vc:UIViewController) {
        imagePicker.sourceType = .camera
        vc.present(imagePicker, animated: true)
    }
    
    func openLibrary(fromViewController vc:UIViewController) {
        imagePicker.sourceType = .photoLibrary
        vc.present(imagePicker, animated: true)
    }
    
    func save(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(photoSavingCallback(presentingInViewController:withError:contextInfo:)), nil)
    }
    
    @objc func photoSavingCallback(presentingInViewController viewController:UIViewController, withError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            delegate?.didFailInSavingPhoto(error)
        } else {
            delegate?.didSucceedInSavingPhoto()
        }
    }
}

extension PhotoManager : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            delegate?.didFailInFetchingImage()
            picker.dismiss(animated: true)
            return
        }
        
        delegate?.didSucceedInFetchingImage(cameraImage: image)
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.didFailInFetchingImage()
        picker.dismiss(animated: true)
    }
}

class ImagePickerController: UIImagePickerController {
    override var prefersStatusBarHidden: Bool { return true }
}
