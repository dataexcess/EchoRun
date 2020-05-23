//
//  ImageResultView.swift
//  innate
//
//  Created by dataexcess on 31.12.19.
//  Copyright © 2019 dataexcess. All rights reserved.
//

import UIKit

class ImageResultView: UIView {
    
    var imageView: ImageView!
    var imageContainerView: UIView!
    var scrollView: UIScrollView!
    var activityIndicator: ActivityIndicatorView!
    var longPressRecognizer: UILongPressGestureRecognizer!
    var portraitConstraints: [NSLayoutConstraint]!
    var landscapeConstraints: [NSLayoutConstraint]!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .black
        scrollView = UIScrollView(frame: bounds)
        imageContainerView = UIView()
        imageView = ImageView()
        activityIndicator = ActivityIndicatorView()
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didPerformLongPress))
        longPressRecognizer.minimumPressDuration = 0.5
        imageContainerView.addGestureRecognizer(longPressRecognizer)
        setupViews()
    }
    
    func setupViews() {
        setupScrollView()
        setupImageContainerView()
        setupImageView()
        setupActivityIndicatorView()
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.pinBottomTopLeftRight(toParentView: self)
        scrollView.maximumZoomScale = 10.0
        scrollView.minimumZoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.delegate = self
    }
    
    private func setupImageContainerView() {
        scrollView.addSubview(imageContainerView)
        imageContainerView.pinBottomTopLeftRight(toParentView: scrollView)
        imageContainerView.equalWidthAndHeight(toParentView: scrollView)
    }
    
    private func setupImageView() {
        imageContainerView.addSubview(imageView)
        imageView.alignCenter(toParentView: imageContainerView)
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        portraitConstraints = [NSLayoutConstraint(item: imageView!,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: imageView!,
                           attribute: .width,
                           multiplier: 1.0,
                           constant: 0),
        NSLayoutConstraint(item: imageView!,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: imageContainerView!,
                           attribute: .left,
                           multiplier: 1.0,
                           constant: 10),
        NSLayoutConstraint(item: imageView!,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: imageContainerView!,
                           attribute: .right,
                           multiplier: 1.0,
                           constant: -10)]
        imageContainerView.addConstraints(portraitConstraints)
    }
    
    @objc private func didPerformLongPress() {
        guard let image = imageView.image else { return }
        presentSavingDialog(withImage: image)
    }
    
    func presentSavingDialog(withImage image: UIImage) {
        let alert = AlertController(title: "Save Image", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            action in
            PhotoManager.sharedInstance.save(image: image)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {
            action in
            alert.dismiss(animated: true, completion: nil)
        }))
        if !UIApplication.topViewController()!.isKind(of: AlertController.self) {
            UIApplication.topViewController()!.present(alert, animated: true, completion: nil)
        }
    }
    
    private func setupActivityIndicatorView() {
        imageView.addSubview(activityIndicator)
        activityIndicator.alignCenter(toParentView: imageView)
    }
    
    func loadImage(forURL url: URL,
                   withCompletionHandler completionHandler: (()->Void)?,
                   andFailureHandler failureHandler:((_:NetworkingError)->())?) {
        activityIndicator.start()
        NetworkManager.sharedInstance.download(imageURL: url, withCompletionHandler: {
            
            image in
            self.imageView.image = image
            self.activityIndicator.stop()
            completionHandler?()
        }, andFailureHandler: {
                                                
            error in
            debugPrint(error)
            self.activityIndicator.stop()
            self.activityIndicator.text = error.localizedDescription
            failureHandler?(error)
        })
    }
}

extension ImageResultView : UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageContainerView
    }
}

class ImageView : UIImageView {
    
}

class AlertController : UIAlertController {
    
    override var preferredStyle: UIAlertController.Style {
        get { return .actionSheet }
        set { }
    }
}
