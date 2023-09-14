//
//  BlackTransparentOverlay.swift
//  VideoSpeed
//
//  Created by oren shalev on 18/08/2023.
//

import UIKit

class BlackTransparentOverlay: UIView {

    @IBOutlet var contentView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("BlackTransparentOverlay", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}
