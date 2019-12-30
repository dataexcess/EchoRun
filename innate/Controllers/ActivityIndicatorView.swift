//
//  ActivityIndicatorView.swift
//  
//
//  Created by Joeri Bultheel on 21/08/2019.
//

import UIKit

class ActivityIndicatorView: UILabel {
    
    private var timer = Timer()
    private let loadingIcons = ["⍅","⍭","⍊","⌿","⍚","⍙"]
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
    }
    
    private func setup() {
        font = .systemFont(ofSize: 28)
        textColor = .white
        text = ""
    }
    
    func start() {
        var step = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) {
            
            timer in
            self.text! += self.loadingIcons.randomElement()!
            if (step % self.characterCap == 0) { self.text = "" }
            step += 1
        }
    }
    
    func stop() {
        timer.invalidate()
        text = ""
    }
}
