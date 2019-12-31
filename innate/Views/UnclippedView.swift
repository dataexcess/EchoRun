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
        return self.point(inside: point, with: event) ? scrollView : nil
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
    }
}

