//
//  PHAsset+Extension.swift
//  VideoSpeed
//
//  Created by oren shalev on 15/07/2023.
//

import Foundation
import Photos

extension PHAsset {
    func getAVAsset(completionHandler : @escaping ((_ responseURL : AVAsset?) -> Void)){
               let options: PHVideoRequestOptions = PHVideoRequestOptions()
//        options.version = .original
        options.deliveryMode = .highQualityFormat
               PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                   completionHandler(asset)
               })
           
       }
    
    func getAVAssetUrl(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
               let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .fastFormat
               PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                   if let urlAsset = asset as? AVURLAsset {
                            let localVideoUrl: URL = urlAsset.url as URL
                                completionHandler(localVideoUrl)
                            } else {
                                completionHandler(nil)
                            }
               })
           
       }

    func getAVAssetUrl(progressHandler: PHAssetVideoProgressHandler?, completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
               let options: PHVideoRequestOptions = PHVideoRequestOptions()
               options.deliveryMode = .highQualityFormat
               options.isNetworkAccessAllowed = true
               options.progressHandler = progressHandler
        
               PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                   if let urlAsset = asset as? AVURLAsset {
                            let localVideoUrl: URL = urlAsset.url as URL
                                completionHandler(localVideoUrl)
                            } else {
                                completionHandler(nil)
                            }
               })
           
       }
}
