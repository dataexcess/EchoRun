//
//  ViewController.swift
//  innate
//
//  Created by Joeri Bultheel on 16/08/2019.
//  Copyright © 2019 dataexcess. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool { return true }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var consoleOutput: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var loadingTimer = Timer()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        CameraManager.sharedInstance.delegate = self
        scrollView.maximumZoomScale = 10.0
        scrollView.minimumZoomScale = 1.0
        scrollView.delegate = self
    }
    
    @IBAction func didPressCameraButton(_ sender: Any) {
        
        imageView.image = nil
        CameraManager.sharedInstance.openCamera(fromViewController: self)
    }
    
    func handleNetworkingError(_ error:NetworkingError) {
        
        stopLoadingTimer()
        consoleOutput.text = error.localizedDescription
    }
    
    //MARK: console output methods
    
    func startLoadingTimer() {
        
        var amountOfDots = 0
        loadingTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) {
            
            timer in
            var dots = ""
            for _ in 0..<amountOfDots { dots += "." }
            let finalLoadingString = "loading" + dots
            self.consoleOutput.text = finalLoadingString
            amountOfDots = (amountOfDots + 1)%4
            print(amountOfDots)
        }
    }
    
    func stopLoadingTimer() {
        loadingTimer.invalidate()
        consoleOutput.text = ""
    }
}

extension ViewController : CameraManagerDelegate {
    
    func didFailInFetchingCameraImage() {
        print("FAIL")
    }
    
    func didSucceedInFetchingCameraImage(img: UIImage) {
        
        imageView.image = img
        startLoadingTimer()
        NetworkManager.sharedInstance.findVisuallySimilarImagesFor(image: img,
                                                                   withCompletionHandler: {
                                                                    
                                                                    imageURLS in
                                                                    let imageURL = imageURLS.first!
                                                                    
                                                                    NetworkManager.sharedInstance.download(imageURL: imageURL, withCompletionHandler: {
                                                                        
                                                                        image in
                                                                        self.imageView.image = image
                                                                        self.stopLoadingTimer()
                                                                        
                                                                    }, andFailureHandler: {
                                                                        
                                                                        error in
                                                                        self.handleNetworkingError(error)
                                                                    })
        },
                                                                   andFailureHandler: {
                                                                    
                                                                    error in
                                                                    self.handleNetworkingError(error)
            
        })
    }
}

extension ViewController : UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
}
