//
//  ProgressIndicatorView.swift
//  VideoSpeed
//
//  Created by oren shalev on 22/07/2023.
//

import UIKit

class ProgressIndicatorView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var progressViewContainer: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("ProgressIndicatorView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        progressViewContainer.layer.cornerRadius = 10
        progressView.progress = 0.8
    }
    
    
}
