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
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var buttonsContainerView: UIView!
    @IBOutlet weak var cameraButton: Button!
    @IBOutlet weak var libraryButton: Button!
    @IBOutlet weak var addNewButton: UIButton!
    @IBOutlet weak var inputCancelAreView: UIView!
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
    }
    
    private func setupButtons() {
        cameraButton.type = .Camera
        cameraButton.delegate = self
        libraryButton.type = .Library
        libraryButton.delegate = self
        addNewButton.isHidden = true
    }
    
    private func setupScrollView() {
        automaticallyAdjustsScrollViewInsets = false
        
        //setup main view container
        view.addSubview(container)
        view.sendSubviewToBack(container)
        container.pinTopBottom(toParentView: view, withPadding: 0)
        container.pinRight(toParentView: view, withPadding: 0)
        containerLeftConstraint = NSLayoutConstraint(item: container, attribute: .left, relatedBy: .equal,
                                                     toItem: view, attribute: .left, multiplier: 1.0, constant: 0)
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
        pageControl.alignCenterY(toParentView: view, withOffset: Int( (UIScreen.main.bounds.width / 2) + 14 ))
        pageControl.isHidden = true
        pageControl.dotColor = UIColor.darkGray
        pageControl.selectedColor = UIColor.white
    }
    
    func setupInputCancelArea() {
        inputCancelAreView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCancelArea)))
    }
    
    @objc func didTapCancelArea() {
        buttonsContainerView.isHidden = true
        addNewButton.isHidden = false
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
        buttonsContainerView.isHidden = false
        addNewButton.isHidden = true
        pageControl.isHidden = true
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
        pageControl.pages = (amount + 1)
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
        print("FAIL")
    }
    
    func didSucceedInFetchingImage(cameraImage: UIImage) {
        buttonsContainerView.isHidden = true
        addNewButton.isHidden = false
        activityIndicator.start()
        (imagesStackView.arrangedSubviews.first as! ImageResultView).imageView.image = cameraImage
        NetworkManager.sharedInstance.findVisuallySimilarImagesFor(image: cameraImage, withCompletionHandler: {
        imageURLS in
            guard let firstImageURL = imageURLS.first else { return }
            for _ in 0..<imageURLS.count { self.imagesStackView.addArrangedSubview(ImageResultView()) }
            (self.imagesStackView.arrangedSubviews[1] as! ImageResultView).loadImage(forURL: firstImageURL) {
                self.scrollView.scrollToPage(withIndex: 1, animated: true)
                self.setupPageControlPages(forAmount: imageURLS.count)
                self.pageControl.isHidden = false
                self.activityIndicator.stop()
                guard imageURLS.count > 1 else { return }
                let remainingURLs = Array(imageURLS.dropFirst())
                for (idx, url) in remainingURLs.enumerated() {
                    (self.imagesStackView.arrangedSubviews[idx+2] as! ImageResultView).loadImage(forURL: url, withCompletionHandler: nil)
                }
            }
        }, andFailureHandler: {
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
