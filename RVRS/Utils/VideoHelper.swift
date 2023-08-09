//
//  VideoHelper.swift
//  VideoSpeed
//
//  Created by oren shalev on 22/07/2023.
//

import AVFoundation
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class VideoHelper {
    static func startMediaBrowser(
      delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate,
      sourceType: UIImagePickerController.SourceType
    ) {
      guard UIImagePickerController.isSourceTypeAvailable(sourceType)
        else { return }

      let mediaUI = UIImagePickerController()
      mediaUI.sourceType = sourceType
      mediaUI.mediaTypes = [UTType.movie.identifier]
      mediaUI.allowsEditing = true
      mediaUI.delegate = delegate
      delegate.present(mediaUI, animated: true, completion: nil)
    }
    
    static func orientation(from transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
      var assetOrientation = UIImage.Orientation.up
      var isPortrait = false
      if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
        assetOrientation = .right
        isPortrait = true
      } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
        assetOrientation = .left
        isPortrait = true
      } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
        assetOrientation = .up
      } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
        assetOrientation = .down
      }
      
      return (assetOrientation, isPortrait)
    }
    
    static func orientationFromTransform(
      _ transform: CGAffineTransform
    ) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
      var assetOrientation = UIImage.Orientation.up
      var isPortrait = false
      let tfA = transform.a
      let tfB = transform.b
      let tfC = transform.c
      let tfD = transform.d

      if tfA == 0 && tfB == 1.0 && tfC == -1.0 && tfD == 0 {
        assetOrientation = .right
        isPortrait = true
      } else if tfA == 0 && tfB == -1.0 && tfC == 1.0 && tfD == 0 {
        assetOrientation = .left
        isPortrait = true
      } else if tfA == 1.0 && tfB == 0 && tfC == 0 && tfD == 1.0 {
        assetOrientation = .up
      } else if tfA == -1.0 && tfB == 0 && tfC == 0 && tfD == -1.0 {
        assetOrientation = .down
      }
      return (assetOrientation, isPortrait)
    }

    static func getVideoTransform(orientation: UIImage.Orientation) -> CGAffineTransform {
        switch orientation {
            case .up:
                return .identity
            case .down:
                return CGAffineTransform(rotationAngle: .pi)
            case .left:
                return CGAffineTransform(rotationAngle: .pi/2)
            case .right:
                return CGAffineTransform(rotationAngle: -.pi/2)
            default:
                return .identity
            }
        }
}
