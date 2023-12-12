//
//  UsingProFeaturesAlertView.swift
//  VideoSpeed
//
//  Created by oren shalev on 18/08/2023.
//

import UIKit
import AVFoundation

enum ProFetureType: String {
  case moreThanTwoLoops = "More Than 2 Loops"
  case rvrs = "Reverse"
  case fasterThanOnePointFive = "Speed Faster Than 1.5x"
  case slowerThanOne = "Speed Slower Than 1x"
}

struct ProFeature {
    var proFeatureType: ProFetureType
    var imageName: String
}

class UsingProFeaturesAlertView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var continueButton: UIButton!
    var onCancel: VoidClosure?
    var onContinue: VoidClosure?
    
    @IBOutlet weak var tableView: UITableView!
    var proFeaturesInUse: [ProFeature] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
   
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
//        contentView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        registerTableViewCell()
    }
    

    private func registerTableViewCell() {
        let cell = UINib(nibName: "ProFeatureTableViewCell",
                                  bundle: nil)
        self.tableView.register(cell,
                                forCellReuseIdentifier: "ProFeatureTableViewCell")
    }
    
    func updateStatus() {

        proFeaturesInUse.removeAll()

        if UserDataManager.usingMoreThanTwoLoops {
            let proFeature = ProFeature(proFeatureType: .moreThanTwoLoops, imageName: "infinity")
            proFeaturesInUse.append(proFeature)
        }
        
        
        if UserDataManager.speedSliderAboveOnePointFive {
            let proFeature = ProFeature(proFeatureType: .fasterThanOnePointFive, imageName: "slider.horizontal.2.square.on.square")
            proFeaturesInUse.append(proFeature)
        }
        else if UserDataManager.speedSliderBelowOne {
            let proFeature = ProFeature(proFeatureType: .slowerThanOne, imageName: "slider.horizontal.2.square.on.square")
            proFeaturesInUse.append(proFeature)
        }
        
        if UserDataManager.usingRverse {
            let proFeature = ProFeature(proFeatureType: .rvrs, imageName: "backward")
            proFeaturesInUse.append(proFeature)
        }
        
        tableView.reloadData()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        onCancel?()
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        onContinue?()
    }
    
   
}

fileprivate typealias TableView = UsingProFeaturesAlertView
extension TableView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return proFeaturesInUse.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProFeatureTableViewCell") as? ProFeatureTableViewCell {
            let proFeature = proFeaturesInUse[indexPath.row]
            cell.nameLabel.text = proFeature.proFeatureType.rawValue
            cell.featureImageView.image = UIImage(systemName: proFeature.imageName)
            return cell
        }
        
        return UITableViewCell()
    }
}
