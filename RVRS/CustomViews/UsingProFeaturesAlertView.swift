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
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var reverseView: UIView!
    
    @IBOutlet weak var speedSliderLabel: UILabel!
    @IBOutlet weak var sliderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loopsViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var reverseViewHeightConstraint: NSLayoutConstraint!
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
        
        loopsViewHeightConstraint.constant = 0
        loopsView.isHidden = true
        
        sliderViewHeightConstraint.constant = 0
        sliderView.isHidden = true
        
        reverseViewHeightConstraint.constant = 0
        reverseView.isHidden = true
        
        if usingSlider {
            sliderViewHeightConstraint.constant = 24
            sliderView.isHidden = false
        }
       
        if usingLoops {
            loopsViewHeightConstraint.constant = 24
            loopsView.isHidden = false
        }
    }
    
    func updateStatus() {
        
        loopsViewHeightConstraint.constant = 0
        loopsView.isHidden = true
        
        sliderViewHeightConstraint.constant = 0
        sliderView.isHidden = true
        
        reverseViewHeightConstraint.constant = 0
        reverseView.isHidden = true
        
        layoutIfNeeded()

        if UserDataManager.usingMoreThanTwoLoops {
            loopsViewHeightConstraint.constant = 24
            loopsView.isHidden = false
        }
        
        if UserDataManager.usingRverse {
            reverseViewHeightConstraint.constant = 24
            reverseView.isHidden = false
        }
        
        if UserDataManager.speedSliderAboveOnePointFive {
            sliderViewHeightConstraint.constant = 24
            sliderView.isHidden = false
            speedSliderLabel.text = "Faster Than 1.5x"
        }
        
        else if UserDataManager.speedSliderBelowOne {
            sliderViewHeightConstraint.constant = 24
            sliderView.isHidden = false
            speedSliderLabel.text = "Slower Than 1x"
        }
        

        
        layoutIfNeeded()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        onCancel?()
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        onContinue?()
    }
    
}
