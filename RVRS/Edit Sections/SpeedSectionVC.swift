//
//  SpeedSectionVC.swift
//  VideoSpeed
//
//  Created by oren shalev on 16/07/2023.
//

import UIKit
typealias SpeedClosure = (Float) -> Void

class SpeedSectionVC: SectionViewController {

    @IBOutlet weak var point25Button: UIButton!
    @IBOutlet weak var point5Button: UIButton!
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var onePoint5Button: UIButton!
    @IBOutlet weak var twoButton: UIButton!

    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var speedLabel: UILabel!
    
    var speedDidChange: SpeedClosure?
    var sliderValueChange: SpeedClosure?
    
    var speed: Float = 1 {
        didSet {
            speedLabel?.text = "\(speed)x"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBorderAndRadius(button: point25Button)
        setBorderAndRadius(button: point5Button)
        setBorderAndRadius(button: oneButton)
        setBorderAndRadius(button: onePoint5Button)
        setBorderAndRadius(button: twoButton)

        setSelectedButton(button: oneButton)
    }

    
    @IBAction func point25ButtonTapped(_ sender: UIButton) {
        setSelectedButton(button: sender)
        speed = 0.25
        speedDidChange?(speed)

    }
    @IBAction func point5ButtonTapped(_ sender: UIButton) {
        setSelectedButton(button: sender)
        speed = 0.5
        speedDidChange?(speed)

    }
    @IBAction func oneButtonTapped(_ sender: UIButton) {
        setSelectedButton(button: sender)
        speed = 1
        speedDidChange?(speed)

    }
    @IBAction func onePoint5ButtonTapped(_ sender: UIButton) {
        setSelectedButton(button: sender)
        speed = 1.5
        speedDidChange?(speed)

    }
    @IBAction func twoButtonTapped(_ sender: UIButton) {
        setSelectedButton(button: sender)
        speed = 2
        speedDidChange?(speed)
    }

    
    @IBAction func onSliderChange(_ sender: Any) {
        currentSelectedButton?.tintColor = .link
        let slider = sender as! UISlider
        speed = convertSliderValue(value: slider.value)
        sliderValueChange?(speed)

    }

    @IBAction func sliderReleased(_ sender: Any) {
        guard let purchasedProduct = SpidProducts.store.userPurchasedProVersion() else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else {return}
                self.speed = 1
                self.slider.value = 19
                self.setButtonUnselected(button: self.currentSelectedButton)
                self.setSelectedButton(button: self.oneButton)
                self.userNeedsToPurchase?()
            }
            return
        }
        
        print("purchasedProduct \(purchasedProduct)")
        let slider = sender as! UISlider
        speed = convertSliderValue(value: slider.value)
        speedDidChange?(speed)
    }
    
    func convertSliderValue(value: Float) -> Float {
        
        if value < 20 {
            switch Int(value) {
            case 1...2:
                return 0.1
            case 3...4:
                return 0.2
            case 5...6:
                return 0.3
            case 7...8:
                return 0.4
            case 9...10:
                return 0.5
            case 11...12:
                return 0.6
            case 13...14:
                return 0.7
            case 15...16:
                return 0.8
            case 17...18:
                return 0.9
            case 19...20:
                return 1
                
            default:
                return 1
            }
        }
      
        else {
            var newValue = value - 19
            newValue = Float(round(10 * newValue) / 10)
            return newValue
        }
    }
    
    
}
