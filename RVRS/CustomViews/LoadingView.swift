//
//  LoadingView.swift
//  VideoSpeed
//
//  Created by oren shalev on 27/07/2023.
//

import UIKit

class LoadingView: UIView {

    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("LoadingView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}
