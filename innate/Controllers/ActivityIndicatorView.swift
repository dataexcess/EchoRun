//
//  ActivityIndicatorView.swift
//  
//
//  Created by Joeri Bultheel on 21/08/2019.
//

import UIKit

class ActivityIndicatorView: UILabel {
    
    private var timer = Timer()
    private let loadingIcons = ["●"]
    private let characterCap = 4
    
    init() {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 20)))
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        //font = .systemFont(ofSize: 14)
        textColor = .white
        text = ""
        self.addCharacterSpacing(kernValue: 1.6)
    }
    
    func start() {
        var step = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) {
            timer in
            
            self.attributedText = NSAttributedString(string: self.attributedText!.string + self.loadingIcons.randomElement()!)
            if (step % self.characterCap == 0) { self.attributedText = NSAttributedString(string: "") }
            step += 1
            self.addCharacterSpacing(kernValue: 1.6)
        }
    }
    
    func stop() {
        timer.invalidate()
        text = ""
    }
}
