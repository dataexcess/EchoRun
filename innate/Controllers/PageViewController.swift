//
//  PageViewController.swift
//  innate
//
//  Created by Joeri Bultheel on 19/08/2019.
//  Copyright © 2019 dataexcess. All rights reserved.
//

import UIKit
import ScrollingPageControl

class PageViewController: UIPageViewController {
    
    lazy var pages = {
        return [ImageViewController()]
    }()
    var pageControl: ScrollingPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        displayPage(atIndex: 0, animated: false)
        setupPageControl()
        resetPages()
        pages.first?.view.isHidden = true
    }
    
    func setupPageControl() {
        pageControl = ScrollingPageControl()
        view.addSubview(pageControl)
        pageControl.alignCenterX(toParentView: view)
        let offset = Int( (UIScreen.main.bounds.width / 2) + 14 )
        pageControl.alignCenterY(toParentView: view, withOffset: offset)
        view.bringSubviewToFront(pageControl)
        pageControl.isHidden = true
        pageControl.dotColor = UIColor.darkGray
        pageControl.selectedColor = UIColor.white
    }
    
    func addNewPages(withAmount amount:Int) {
        for _ in 0..<amount {
            let imageViewController = ImageViewController()
            pages.append(imageViewController)
            imageViewController.view.setNeedsLayout()
            imageViewController.view.layoutIfNeeded()
        }
        
        if amount <= 5 {
            pageControl.maxDots = 5
            pageControl.centerDots = 5
        } else {
            pageControl.maxDots = 7
            pageControl.centerDots = 3
        }
        pageControl.pages = (amount + 1)
    }
    
    func resetPages() {
        displayPage(atIndex: 0, animated: false)
        pages = [pages.first!]
        enableSwiping(enabled: false)
        pageControl.pages = 1
    }
    
    func displayPage(atIndex index:Int, animated:Bool) {
        let viewController = pages[index]
        setViewControllers([viewController],
                           direction: .forward,
                           animated: animated,
                           completion: nil)
    }
    
    func setFirstImage(image:UIImage) {
        pages.first?.imageView.image = image
        pages.first?.view.isHidden = false
    }
    
    func loadAndPresentFirstResult(withURL url:URL, withCompletionHandler completionHandler:@escaping ()->()) {
        enableSwiping(enabled: true)
        pages[1].loadImage(forURL: url) {
            self.displayPage(atIndex: 1, animated: true)
            self.pageControl.selectedPage = 1
            self.pageControl.isHidden = false
            completionHandler()
        }
    }
    
    func loadRemainingResults(with urls:[URL]) {
        let remainingIndexOffset = 2
        for (idx, url) in urls.enumerated() {
            pages[idx+remainingIndexOffset].loadImage(forURL: url,
                                                      withCompletionHandler: nil)
        }
    }
    
    func enableSwiping(enabled:Bool) {
        dataSource = enabled ? self : nil
    }
}

extension PageViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController as! ImageViewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
                
        return pages[previousIndex]
    }
        
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController as! ImageViewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return nil }
                
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let idx = pages.firstIndex(of: pendingViewControllers.first as! ImageViewController) else { return }
        pageControl.selectedPage = idx
    }
}
