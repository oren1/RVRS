//
//  AppStoreReviewManager.swift
//  VideoSpeed
//
//  Created by oren shalev on 24/07/2023.
//

import Foundation
import StoreKit
import FirebaseRemoteConfig

enum AppStoreReviewManager {
    
  static let minimumReviewWorthyActionCount = RemoteConfig.remoteConfig().configValue(forKey: "minimumReviewWorthyActionCount").numberValue.intValue

  static func requestReviewIfAppropriate() {
        let defaults = UserDefaults.standard
        let bundle = Bundle.main

        // increasing the count by 1
        var actionCount = defaults.integer(forKey: Consts.reviewWorthyActionCount)
        actionCount += 1
        defaults.set(actionCount, forKey: Consts.reviewWorthyActionCount)

        print("worthy review count: \(actionCount)")
        // checking if the current count is bigger then the minimum review worthy count
        guard actionCount >= minimumReviewWorthyActionCount else {
          return
        }

        
        let lastVersion = defaults.string(forKey: Consts.lastReviewRequestAppVersion)
        // making sure that the review request wasn't already prompted in the current version
//        guard let currentVersion = UIApplication.appVersion,
//              lastVersion == nil || lastVersion != currentVersion else { return }
              

        // prompt the review request
        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
        else {
            SKStoreReviewController.requestReview()
        }

        // reset the worthy count to zero and last app version to the current version
        defaults.set(0, forKey: Consts.reviewWorthyActionCount)
//        defaults.set(currentVersion, forKey: Consts.lastReviewRequestAppVersion)

     }
  
}
