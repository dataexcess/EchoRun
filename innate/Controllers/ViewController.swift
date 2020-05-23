//
//  ViewController.swift
//  innate
//
//  Created by Joeri Bultheel on 16/08/2019.
//  Copyright © 2019 dataexcess. All rights reserved.
//

import UIKit
import ScrollingPageControl

final class ViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool { return true }
    @IBOutlet private weak var activityIndicator: ActivityIndicatorView!
    @IBOutlet weak var buttonsContainerView: UIView!
    @IBOutlet weak var cameraButton: Button!
    @IBOutlet weak var libraryButton: Button!
    @IBOutlet weak var addNewButton: UIButton!
    @IBOutlet weak var inputCancelAreView: UIView!
    @IBOutlet weak var introText: UILabel!
    private var container:UIView = { let view = UIView(); view.backgroundColor = .black; return view }()
    private var scrollViewContainer:UnclippedView!
    private var scrollView:UnclippedScrollView!
    private var imagesStackView:UIStackView!
    private var pageControl:ScrollingPageControl!
    private var scrollViewWidthConstraint:NSLayoutConstraint!
    private var containerLeftConstraint:NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PhotoManager.sharedInstance.delegate = self
        setupButtons()
        setupInputCancelArea()
        setupScrollView()
        setupImagesStackView()
        setupPageControl()
        activityIndicator.text = ""
    }
    
    private func setupButtons() {
        cameraButton.type = .Camera
        cameraButton.delegate = self
        libraryButton.type = .Library
        libraryButton.delegate = self
        buttonsContainerView.isHidden = true
    }
    
    private func setupScrollView() {
        //automaticallyAdjustsScrollViewInsets = false
        
        //setup main view container
        view.addSubview(container)
        view.sendSubviewToBack(container) 
        container.pinTopBottom(toParentView: view, withPadding: 0)
        container.pinRight(toParentView: view, withPadding: 0)
        containerLeftConstraint = NSLayoutConstraint(item: container, attribute: .left, relatedBy: .equal,
                                                     toItem: view.safeAreaLayoutGuide, attribute: .left, multiplier: 1.0, constant: 0)
        view.addConstraint(containerLeftConstraint)
        
        //setup scrollview container
        scrollViewContainer = UnclippedView()
        container.addSubview(scrollViewContainer)
        container.sendSubviewToBack(scrollViewContainer)
        scrollViewContainer.pinBottomTopLeftRight(toParentView: container)
        
        //setup scrollview
        scrollView = UnclippedScrollView()
        scrollViewContainer.addSubview(scrollView)
        scrollViewContainer.scrollView = scrollView
        scrollView.pinTopBottom(toParentView: scrollViewContainer, withPadding: 0)
        scrollView.equalHeight(toParentView: scrollViewContainer)
        scrollView.alignCenterX(toParentView: scrollViewContainer)
        toggleScrollViewLandscapeConstraint(isLandscape: true)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.layer.masksToBounds = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let isLandscape = view.bounds.width > view.bounds.height
        toggleScrollViewLandscapeConstraint(isLandscape: isLandscape)
    }
    
    private func toggleScrollViewLandscapeConstraint(isLandscape:Bool) {
        if scrollViewWidthConstraint != nil { scrollViewContainer.removeConstraint(scrollViewWidthConstraint) }
        scrollViewWidthConstraint = NSLayoutConstraint(item: scrollView!,
                                                      attribute: .width,
                                                      relatedBy: .equal,
                                                      toItem: scrollViewContainer,
                                                      attribute: .width,
                                                      multiplier: isLandscape ? 1/3 : 1.0,
                                                      constant: 0)
        scrollViewContainer.addConstraint(scrollViewWidthConstraint)
        calculateLeftOffsetForUnevenDeviceWidth()
        scrollViewContainer.updateConstraints()
    }
    
    private func calculateLeftOffsetForUnevenDeviceWidth() {
        let remainder = Double(UIScreen.main.bounds.width).remainder(dividingBy: 3)
        let division = floor(Double(UIScreen.main.bounds.width) / 3)
        if remainder != 0 {
            let offset = Double(UIScreen.main.bounds.width) - (division * 3)
            containerLeftConstraint.constant = CGFloat(offset)
        }
    }
    
    private func setupImagesStackView() {
        imagesStackView = UIStackView()
        scrollView.addSubview(imagesStackView)
        imagesStackView.pinBottomTopLeftRight(toParentView: scrollView)
        imagesStackView.axis = .horizontal
        imagesStackView.distribution = .fillEqually
        imagesStackView.alignment = .fill
        imagesStackView.spacing = 0
        let firstImage = ImageResultView()
        imagesStackView.addArrangedSubview(firstImage)
        firstImage.equalWidthAndHeight(toParentView: scrollView)
        
        scrollViewContainer.stackView = imagesStackView
        
        print(scrollView.bounds)
        print(firstImage.bounds)
    }
    
    func setupPageControl() {
        pageControl = ScrollingPageControl(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 20)))
        pageControl = ScrollingPageControl()
        view.addSubview(pageControl)
        view.bringSubviewToFront(pageControl)
        pageControl.alignCenterX(toParentView: view)
        pageControl.pinTop(toParentView: view, withPadding: 21)
        pageControl.isHidden = true
        pageControl.dotColor = UIColor.darkGray
        pageControl.selectedColor = UIColor.white
    }
    
    func setupInputCancelArea() {
        inputCancelAreView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCancelArea)))
    }
    
    @objc func didTapCancelArea() {
        buttonsContainerView.isHidden = true
        pageControl.isHidden = false
    }
    
    fileprivate func didPressCameraButton(_ sender: Any) {
        resetImageStackView()
        PhotoManager.sharedInstance.openCamera(fromViewController: self)
    }
    
    fileprivate func didPressLibraryButton(_ sender: Any) {
        resetImageStackView()
        PhotoManager.sharedInstance.openLibrary(fromViewController: self)
    }
    
    @IBAction func didPressNewButton(_ sender: Any) {
        introText.isHidden = true
        
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "input source:", preferredStyle: .actionSheet)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) {
            _ in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        let saveActionButton = UIAlertAction(title: "Camera", style: .default) {
            _ in
            self.didPressCameraButton(self)
        }
        actionSheetController.addAction(saveActionButton)
        let deleteActionButton = UIAlertAction(title: "Library", style: .default) {
            _ in
            self.didPressLibraryButton(self)
        }
        actionSheetController.addAction(deleteActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let index = pageControl.selectedPage
        coordinator.animateAlongsideTransition(in: nil, animation: {
            context in
            self.toggleScrollViewLandscapeConstraint(isLandscape: size.width > size.height)
            self.scrollView.scrollToPage(withIndex: index, animated: false)
        })
    }
    
    private func setupPageControlPages(forAmount amount:Int) {
        if amount <= 5 {
            pageControl.maxDots = 5
            pageControl.centerDots = 5
        } else {
            pageControl.maxDots = 7
            pageControl.centerDots = 3
        }
        pageControl.pages = amount
    }
    
    private func resetImageStackView() {
        imagesStackView.arrangedSubviews.forEach{ $0.removeFromSuperview() }
        let firstImage = ImageResultView()
        imagesStackView.addArrangedSubview(firstImage)
        firstImage.equalWidthAndHeight(toParentView: scrollView)
        pageControl.isHidden = true
        pageControl.pages = 0
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentIndex = scrollView.pageControlIndex
        if currentIndex != pageControl.selectedPage {
            pageControl.selectedPage = currentIndex
        }
    }
}

extension ViewController: PhotoManagerDelegate {
    
    func didFailInFetchingImage() {
        print("Did Fail to fetch image from camera or library")
    }
    
    func didSucceedInFetchingImage(cameraImage: UIImage) {
        buttonsContainerView.isHidden = true
        activityIndicator.stop()
        activityIndicator.start()
        (imagesStackView.arrangedSubviews.first as! ImageResultView).imageView.image = cameraImage
        NetworkManager.sharedInstance.findVisuallySimilarImagesFor(image: cameraImage, withCompletionHandler: {
        imageURLS in
            self.tryToLoadFirstImageAndAfterwardsTheRemainingImages(forURLS: imageURLS)
        }, andFailureHandler: {
        error in
            self.activityIndicator.stop()
            self.activityIndicator.text = error.localizedDescription
        })
    }
    
    func tryToLoadFirstImageAndAfterwardsTheRemainingImages(forURLS imageURLS:[URL]) {
        guard let firstImageURL = imageURLS.first else { return }
        for _ in 0..<imageURLS.count { self.imagesStackView.addArrangedSubview(ImageResultView()) }
        let firstResult = (self.imagesStackView.arrangedSubviews[1] as! ImageResultView)
        firstResult.loadImage(forURL: firstImageURL, withCompletionHandler: {
            self.scrollView.scrollToPage(withIndex: 1, animated: true)
            self.setupPageControlPages(forAmount: imageURLS.count)
            self.pageControl.isHidden = false
            self.activityIndicator.stop()
            guard imageURLS.count > 1 else { return }
            let remainingURLs = Array(imageURLS.dropFirst())
            
            RatingManager.sharedInstance.incrementSearchCount()
            RatingManager.sharedInstance.checkAndAskForReview()
            
            for (idx, url) in remainingURLs.enumerated() {
                let result = (self.imagesStackView.arrangedSubviews[idx+2] as! ImageResultView)
                result.loadImage(forURL: url, withCompletionHandler: nil, andFailureHandler: {
                    error in

                    result.removeFromSuperview()
                    self.setupPageControlPages(forAmount: self.imagesStackView.arrangedSubviews.count)
                })
            }
        }, andFailureHandler: {
            error in
            self.imagesStackView.arrangedSubviews[1..<self.imagesStackView.arrangedSubviews.count].forEach { $0.removeFromSuperview() }
            self.setupPageControlPages(forAmount: self.imagesStackView.arrangedSubviews.count)
            
            let remainingURLs = Array(imageURLS.dropFirst())
            if !remainingURLs.isEmpty {
                self.tryToLoadFirstImageAndAfterwardsTheRemainingImages(forURLS: Array(imageURLS.dropFirst()))
            } else {
                self.activityIndicator.stop()
                self.activityIndicator.text = error.localizedDescription
            }
        })
    }
    
    func didSucceedInSavingPhoto() {
        let ac = UIAlertController(title: "Saved!", message: "", preferredStyle: .alert)
        self.present(ac, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20), execute: {
            ac.dismiss(animated: true, completion: nil)
        })
    }
    
    func didFailInSavingPhoto(_: Error) {
        let ac = UIAlertController(title: "Error", message: "Image could not be saved", preferredStyle: .alert)
        self.present(ac, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20), execute: {
            ac.dismiss(animated: true, completion: nil)
        })
    }
}

extension ViewController: ButtonDelegate {
    
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
