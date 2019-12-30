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
    @IBOutlet private weak var activityIndicator: ActivityIndicatorView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var buttonsContainerView: UIView!
    @IBOutlet weak var cameraButton: Button!
    @IBOutlet weak var libraryButton: Button!
    @IBOutlet weak var addNewButton: UIButton!
    @IBOutlet weak var inputCancelAreView: UIView!
    private var pageViewController = PageViewController(transitionStyle: .scroll,
                                                        navigationOrientation: .horizontal,
                                                        options: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PhotoManager.sharedInstance.delegate = self
        cameraButton.type = .Camera
        cameraButton.delegate = self
        libraryButton.type = .Library
        libraryButton.delegate = self
        addNewButton.isHidden = true
        setupInputCancelArea()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        view.sendSubviewToBack(pageViewController.view)
        pageViewController.view.pinBottomTopLeftRight(toParentView: view)
    }
    
    func setupInputCancelArea() {
        inputCancelAreView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCancelArea)))
    }
    
    @objc func didTapCancelArea() {
        buttonsContainerView.isHidden = true
        addNewButton.isHidden = false
    }
    
    fileprivate func didPressCameraButton(_ sender: Any) {
        pageViewController.pages.first?.imageView.image = nil
        PhotoManager.sharedInstance.openCamera(fromViewController: self)
    }
    
    fileprivate func didPressLibraryButton(_ sender: Any) {
        pageViewController.pages.first?.imageView.image = nil
        PhotoManager.sharedInstance.openLibrary(fromViewController: self)
    }
    
    @IBAction func didPressNewButton(_ sender: Any) {
        buttonsContainerView.isHidden = false
        addNewButton.isHidden = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //buttonsStackView.axis = (size.width > size.height) ? .horizontal : .vertical
    }
}

extension ViewController : PhotoManagerDelegate {
    
    func didFailInFetchingImage() {
        print("FAIL")
    }
    
    func didSucceedInFetchingImage(cameraImage: UIImage) {
        buttonsContainerView.isHidden = true
        addNewButton.isHidden = false
        activityIndicator.start()
        pageViewController.resetPages()
        pageViewController.setFirstImage(image: cameraImage)
        NetworkManager.sharedInstance.findVisuallySimilarImagesFor(image: cameraImage,
                                                                   withCompletionHandler: {
                                                                    
                                                                    imageURLS in
                                                                    let firstImageURL = imageURLS.first!
                                                                    self.pageViewController.addNewPages(withAmount: imageURLS.count)
                                                                    self.pageViewController.loadAndPresentFirstResult(withURL: firstImageURL) {
                                                                        
                                                                        self.activityIndicator.stop()
                                                                        guard imageURLS.count > 1 else { return }
                                                                        let remainingURLs = Array(imageURLS.dropFirst())
                                                                        self.pageViewController.loadRemainingResults(with: remainingURLs)
                                                                    }
        },
                                                                   andFailureHandler: {
                                                                    
                                                                    error in
                                                                    self.activityIndicator.stop()
                                                                    self.activityIndicator.text = error.localizedDescription
        })
    }
    
    func didSucceedInSavingPhoto() {
        let ac = UIAlertController(title: "Saved!", message: "", preferredStyle: .alert)
        self.present(ac, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            ac.dismiss(animated: true, completion: nil)
        })
    }
    
    func didFailInSavingPhoto(_: Error) {
        let ac = UIAlertController(title: "Error", message: "Image could not be saved", preferredStyle: .alert)
        self.present(ac, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            ac.dismiss(animated: true, completion: nil)
        })
    }
}

extension ViewController : ButtonDelegate {
    
    func didTap(button: Button) {
        
        switch button.type {
            case .Camera:
                didPressCameraButton(button)
            case .Library:
                didPressLibraryButton(button)
            default: break
        }
    }
}
