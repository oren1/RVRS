//
//  SoundSectionVC.swift
//  RVRS
//
//  Created by oren shalev on 29/08/2023.
//

import UIKit

class SoundSectionVC: SectionViewController {

    @IBOutlet weak var soundSwitch: UISwitch!
    var soundStateDidChange: SoundStateClosure?

    override func viewDidLoad() {
        super.viewDidLoad()
        soundSwitch.layer.cornerRadius = 16

        // Do any additional setup after loading the view.
    }

    @IBAction func soundStateChanged(_ sender: UISwitch) {
//        UserDataManager.soundOn = sender.isOn
        soundStateDidChange?(sender.isOn)
    }
    

}
