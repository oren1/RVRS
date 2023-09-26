//
//  EditViewController+BottomView.swift
//  RVRS
//
//  Created by oren shalev on 22/08/2023.
//

import Foundation
import UIKit

class TabItem {
    init(title: String, selected: Bool, imageName: String, selectedImageName: String) {
        self.title = title
        self.selected = selected
        self.imageName = imageName
        self.selectedImageName = selectedImageName
    }
    var title: String
    var selected: Bool
    var imageName: String
    var selectedImageName: String
}

private let reuseIdentifier = "tabItem"
private let sectionInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
private let itemsPerRow: CGFloat = 3


// MARK: - UICollectionViewDataSource
extension EditViewController: UICollectionViewDataSource {
  // 1
   func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  // 2
   func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
      return tabs.count
  }

  // 3
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // 1
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: reuseIdentifier,
      for: indexPath
    ) as! TabCollectionViewCell

    let tabItem = tabs[indexPath.row]
       cell.title.text = tabItem.title
       cell.backgroundColor = .clear
       if tabItem.selected {
           cell.imageView.tintColor = .white
           cell.title.textColor = .white
           cell.imageView.image = UIImage(systemName: tabItem.selectedImageName)
       }
       else {
           cell.imageView.tintColor = .lightGray
           cell.title.textColor = .lightGray
           cell.imageView.image = UIImage(systemName: tabItem.imageName)
       }

    return cell
  }
    
}

extension EditViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tabs.forEach({$0.selected = false})
        let tabItem = tabs[indexPath.row]
        tabItem.selected = true
        
        switch tabItem.title {
        case "Speed":
            showSpeedSection()
        case "Loops":
            showLoopSection()
        default:
            showSoundSection()
        }
        
        collectionView.reloadData()
    }
}

// MARK: - Collection View Flow Layout Delegate
extension EditViewController: UICollectionViewDelegateFlowLayout {
  // 1
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    // 2
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    return CGSize(width: widthPerItem, height: 58)
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

