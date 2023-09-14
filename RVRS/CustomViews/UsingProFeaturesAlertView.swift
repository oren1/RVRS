//
//  UsingProFeaturesAlertView.swift
//  VideoSpeed
//
//  Created by oren shalev on 18/08/2023.
//

import UIKit
import AVFoundation

class UsingProFeaturesAlertView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var continueButton: UIButton!
    var onCancel: VoidClosure?
    var onContinue: VoidClosure?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
   
    @IBOutlet weak var loopsView: UIView!
    @IBOutlet weak var soundOffView: UIView!
    @IBOutlet weak var sliderView: UIView!
    
    @IBOutlet weak var sliderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loopsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var soundViewHeightConstraint: NSLayoutConstraint!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("UsingProFeaturesAlertView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.layer.cornerRadius = 8
        continueButton.layer.cornerRadius = 8
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func updateStatus(usingSlider: Bool, usingLoops: Bool, soundOn: Bool) {
        sliderViewHeightConstraint.constant = 0
        sliderView.isHidden = true
        
        soundViewHeightConstraint.constant = 0
        soundOffView.isHidden = true
        
        loopsViewHeightConstraint.constant = 0
        loopsView.isHidden = true
        
        if usingSlider {
            sliderViewHeightConstraint.constant = 24
            sliderView.isHidden = false
        }
        if !soundOn {
            soundViewHeightConstraint.constant = 24
            soundOffView.isHidden = false
        }
        if usingLoops {
            loopsViewHeightConstraint.constant = 24
            loopsView.isHidden = false
        }
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        onCancel?()
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        onContinue?()
    }
    
}
