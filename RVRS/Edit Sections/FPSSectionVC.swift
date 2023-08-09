//
//  FPSSectionVC.swift
//  VideoSpeed
//
//  Created by oren shalev on 19/07/2023.
//

import UIKit
enum FPS: Int {
    case thirty = 30
    case sixty = 60
}
class FPSSectionVC: SectionViewController {

    typealias FPSClosure = (Int32) -> ()
    
    @IBOutlet weak var thirtyButton: UIButton!
    @IBOutlet weak var sixtyButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var fpsDidChange: FPSClosure?

    var fps: Int32 = 30 {
        didSet {
            fpsDidChange?(fps)
        }
    }
    
    let fpsOptions = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,60]

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark

        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.setValue(UIColor.white, forKey: "textColor")
        pickerView.selectRow(29, inComponent: 0, animated: false)
        
//        setBorderAndRadius(button: thirtyButton)
//        setBorderAndRadius(button: sixtyButton)
//        setSelectedButton(button: thirtyButton)
    }

    
    
    
    @IBAction func thirtyButtonTapped(_ sender: Any) {
        fps = 30
        setSelectedButton(button: thirtyButton)
    }
    @IBAction func sixtyButtonTapped(_ sender: Any) {
        fps = 60
        setSelectedButton(button: sixtyButton)
    }
    
    
}

extension FPSSectionVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fpsOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let fps = fpsOptions[row]
        return String(fps)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 38
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let purchasedProduct = SpidProducts.store.userPurchasedProVersion() else {
            pickerView.selectRow(29, inComponent: 0, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                guard let self = self else {return}
                self.userNeedsToPurchase?()
            }
            return
        }
        
        print("purchasedProduct \(purchasedProduct)")
        fps = Int32(fpsOptions[row])
        print(fps)
    }
}
