//
//  PhotoLibraryUsageDisabledView.swift
//  VideoSpeed
//
//  Created by oren shalev on 05/08/2023.
//

import UIKit

class PhotoLibraryUsageDisabledView: UIView {

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
        Bundle.main.loadNibNamed("PhotoLibraryUsageDisabledView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @IBAction func topMessageViewTapped(_ sender: Any) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
}
