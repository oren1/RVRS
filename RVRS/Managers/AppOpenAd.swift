//
//  AppOpenAd.swift
//  VideoSpeed
//
//  Created by oren shalev on 31/07/2023.
//

import Foundation
import GoogleMobileAds
import FirebaseRemoteConfig

typealias VoidClosure = () -> ()
class AppOpenAd: NSObject, GADFullScreenContentDelegate {
    
    var minimumAppOpensRequiredToShowAd: Int

    static let manager = AppOpenAd()
    
    override init() {
        minimumAppOpensRequiredToShowAd = RemoteConfig.remoteConfig().configValue(forKey: "minimumAppOpensToShowAd").numberValue.intValue
        print("minimumAppOpensRequiredToShowAd \(minimumAppOpensRequiredToShowAd)")
    }
    
    var amountOfAppOpens: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: "amountOfAppOpens")
        }
        get {
            UserDefaults.standard.integer(forKey: "amountOfAppOpens")
        }
    }
    
   
    func addOpenAppCount() {
        amountOfAppOpens = amountOfAppOpens + 1
        print("amount of app open: \(amountOfAppOpens)")
    }
}
