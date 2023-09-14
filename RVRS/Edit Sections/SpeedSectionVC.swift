//
//  SpeedSectionVC.swift
//  VideoSpeed
//
//  Created by oren shalev on 16/07/2023.
//

import UIKit
typealias SpeedClosure = (Float) -> Void

class SpeedSectionVC: SectionViewController {

   
    
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
        
    }
    
    @IBAction func onSliderChange(_ sender: Any) {
        let slider = sender as! UISlider
        speed = convertSliderValue(value: slider.value)
        if speed != 1 {
            UserDataManager.usingSpeedSlider = true
        }
        else {
            UserDataManager.usingSpeedSlider = false
        }
        sliderValueChange?(speed)
    }

    @IBAction func sliderReleased(_ sender: Any) {
        speed = convertSliderValue(value: slider.value)
        speedDidChange?(speed)
    }
    
    func convertSliderValue(value: Float) -> Float {
        
        if value < 16 {
            switch value {
            case 1..<1.6:
                return 0.1
            case 1.6..<3.2:
                return 0.2
            case 3.2..<4.8:
                return 0.3
            case 4.8..<6.4:
                return 0.4
            case 6.4..<8:
                return 0.5
            case 8..<9.6:
                return 0.6
            case 9.6..<11.2:
                return 0.7
            case 11.2..<12.8:
                return 0.8
            case 12.8..<14.4:
                return 0.9
            case 14.4..<16:
                return 1
                
            default:
                return 1
            }
        }
      
        else {
            var newValue = value - 15
            newValue = Float(round(10 * newValue) / 10)
            return newValue
        }
    }
    
    
}
