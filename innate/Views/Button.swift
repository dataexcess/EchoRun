//
//  Button.swift
//  innate
//
//  Created by Joeri Bultheel on 25/08/2019.
//  Copyright © 2019 dataexcess. All rights reserved.
//

import UIKit

protocol ButtonDelegate {
    func didTap(button:Button)
}

enum ButtonType {
    case Camera
    case Library
    case None
}

class Button: UIView {
    var type:ButtonType = .None
    var delegate:ButtonDelegate?
    
    func setup() {
//        layer.borderColor = UIColor.white.cgColor
//        layer.borderWidth = 1
//        backgroundColor = .clear
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    @objc func didTap() {
        delegate?.didTap(button: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}
