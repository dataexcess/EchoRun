//
//  UnclippedView.swift
//  testScrollView
//
//  Created by dataexcess on 06.12.19.
//  Copyright © 2019 dataexcess. All rights reserved.
//

import UIKit

class UnclippedView: UIView {
    
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var stackView:UIStackView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        clipsToBounds = true
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var hitView:UIView!
        stackView.arrangedSubviews.forEach {
            view in
            let point = CGPoint(x: (scrollView.contentOffset.x - scrollView.frame.origin.x) + point.x,
                                y: (scrollView.contentOffset.y - scrollView.frame.origin.y) + point.y)
            let pointt = view.convert(point, from: scrollView)
            if view.point(inside: pointt, with: event) {
                hitView = (view as! ImageResultView).imageContainerView
            }
        }
        return hitView
    }
}

class UnclippedScrollView: UIScrollView {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        layer.masksToBounds = false
        contentInset = .zero
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        return false
    }
}

