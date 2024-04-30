//
//  SubscriptionOptionView.swift
//  VideoSpeed
//
//  Created by oren shalev on 16/01/2024.
//

import UIKit

class SubscriptionOptionView: UIView {

    @IBOutlet var contentView: UIView!
  
    @IBOutlet weak var indicatorImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("SubscriptionOptionView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = contentView.frame.height / 6
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.white.cgColor
        indicatorImageView.image = UIImage(systemName: "circle")
    }

    
    func select() {
        contentView.layer.borderWidth = 4
        indicatorImageView.image = UIImage(systemName: "circle.fill")
    }
    func unSelect() {
        contentView.layer.borderWidth = 1
        indicatorImageView.image = UIImage(systemName: "circle")
    }
}
