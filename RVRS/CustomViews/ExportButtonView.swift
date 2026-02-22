//
//  ExportButtonView.swift
//  RVRS
//
//  Created by oren shalev on 16/08/2024.
//

import UIKit

class ExportButtonView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var exportButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("ExportButtonView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        exportButton.addTarget(self, action: #selector(someExport), for: .touchUpInside)
    }
    
    @objc func someExport() {
        print("someExport")
    }
}
