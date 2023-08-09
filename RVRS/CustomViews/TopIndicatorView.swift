//
//  TopIndicatorView.swift
//  VideoSpeed
//
//  Created by oren shalev on 18/07/2023.
//

import UIKit

class TopIndicatorView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("TopIndicatorView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
