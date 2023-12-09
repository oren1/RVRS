//
//  LoopSectionVC.swift
//  RVRS
//
//  Created by oren shalev on 23/08/2023.
//

import UIKit
enum LoopStart: Int {
    case forward = 0, reverse
}

typealias LoopSettingsClosure = (Int,LoopStart) -> ()
private let reuseIdentifier = "LoopItem"
private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
private let itemsPerRow: CGFloat = 2

class LoopSectionVC: SectionViewController {

    @IBOutlet weak var loopsCollectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let loopOptions = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    var loopSettingsChanged: LoopSettingsClosure?
    var selectedLoop: Int = 1 {
        didSet {
            let loopStartingPoint = LoopStart(rawValue: segmentedControl.selectedSegmentIndex)!
            loopSettingsChanged?(selectedLoop,loopStartingPoint)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.selectedSegmentIndex = LoopStart.reverse.rawValue
        let nibName = UINib(nibName: "LoopItemCollectionViewCell", bundle:nil)
        loopsCollectionView.register(nibName, forCellWithReuseIdentifier: reuseIdentifier)

    }
    
    // MARK: - Actions
    @IBAction func segmentedValueChanged(_ segmentedControl: UISegmentedControl) {
        let loopStartingPoint = LoopStart(rawValue: segmentedControl.selectedSegmentIndex)!
        loopSettingsChanged?(selectedLoop,loopStartingPoint)
    }
    
}


// MARK: - UICollectionViewDataSource
extension LoopSectionVC: UICollectionViewDataSource {
  // 1
   func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  // 2
   func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
      return loopOptions.count
  }

  // 3
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // 1
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: reuseIdentifier,
      for: indexPath
    ) as! LoopItemCollectionViewCell
       
       
       let loopOption = loopOptions[indexPath.row]
       cell.layer.borderWidth = 1
       cell.layer.borderColor = UIColor.white.cgColor
       if loopOption == selectedLoop {
           cell.backgroundColor = .systemBlue
           cell.titleLabel.textColor = .white
       }
       else {
           cell.backgroundColor = .black
           cell.titleLabel.textColor = .white
       }
       
       if loopOption == 0 {
           cell.titleLabel.text = "rvrs"
           return cell
       }
       
       cell.titleLabel.text = "\(loopOption)"
       return cell
  }
    
}

extension LoopSectionVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let loopOption = loopOptions[indexPath.row]
        if loopOption == 0 {
            UserDataManager.usingLoops = false
        }
        else {
            UserDataManager.usingLoops = true
        }
        selectedLoop = loopOption

        collectionView.reloadData()
    }
}

// MARK: - Collection View Flow Layout Delegate
extension LoopSectionVC: UICollectionViewDelegateFlowLayout {
  // 1
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
      let height = loopsCollectionView.frame.height
      return CGSize(width: height, height: height)
  }

  // 3
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    return sectionInsets
  }

  // 4
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {
    return sectionInsets.left
  }
}

