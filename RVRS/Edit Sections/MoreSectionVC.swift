//
//  FileTypeSectionVC.swift
//  VideoSpeed
//
//  Created by oren shalev on 19/07/2023.
//

import UIKit
import AVFoundation

typealias FileTypeClosure = (AVFileType) -> ()
typealias SoundStateClosure = (Bool) -> ()

class MoreSectionVC: SectionViewController {

    var currentSoundSelectedButton: UIButton!

    @IBOutlet weak var movButton: UIButton!
    @IBOutlet weak var mp4Button: UIButton!
    @IBOutlet weak var onButton: UIButton!
    @IBOutlet weak var offButton: UIButton!
    
    var soundOn: Bool! = true
    var fileType: AVFileType = .mov
    var fileTypeDidChange: FileTypeClosure?
    var soundStateChanged: SoundStateClosure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBorderAndRadius(button: movButton)
        setBorderAndRadius(button: mp4Button)
        setBorderAndRadius(button: onButton)
        setBorderAndRadius(button: offButton)

        setSelectedButton(button: movButton)
        setSoundSelectedButton(button: onButton)

    }

    func updateSoundSelection(soundOn: Bool) {
        self.soundOn = soundOn
        if self.soundOn {
            setSoundSelectedButton(button: onButton)
        }
        else {
            setSoundSelectedButton(button: offButton)
        }
    }
    
    func setSoundSelectedButton(button: UIButton) {
        currentSoundSelectedButton?.tintColor = UIColor.black
        button.tintColor = .link
        currentSoundSelectedButton = button
    }
    
    @IBAction func movButtonTapped(_ sender: UIButton) {
        fileType = .mov
        fileTypeDidChange?(fileType)
        setSelectedButton(button: sender)
    }
    
    @IBAction func mp4ButtonTapped(_ sender: UIButton) {
        guard let _ = SpidProducts.store.userPurchasedProVersion() else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else {return}
                self.userNeedsToPurchase?()
            }
            return
        }
        fileType = .mp4
        fileTypeDidChange?(fileType)
        setSelectedButton(button: sender)
    }
    
    @IBAction func onButtonTapped(_ sender: Any) {
        soundOn = true
        setSoundSelectedButton(button: onButton)
        soundStateChanged?(soundOn)
    }
    
    @IBAction func offButtonTapped(_ sender: Any) {
        guard let purchasedProduct = SpidProducts.store.userPurchasedProVersion() else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else {return}
                self.userNeedsToPurchase?()
            }
            return
        }
        print("purchasedProduct \(purchasedProduct)")

        soundOn = false
        setSoundSelectedButton(button: offButton)
        soundStateChanged?(soundOn)
    }
    
}
