//
//  SplashViewController.swift
//  VideoSpeed
//
//  Created by oren shalev on 23/07/2023.
//

import UIKit
import GoogleMobileAds
import FirebaseCore
import FirebaseRemoteConfig

class SplashViewController: UIViewController, GADFullScreenContentDelegate {

    var appOpenAd: GADAppOpenAd?
    var adDidDismis = false
    var requestsDidFinish = false
    var error: Error?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RemoteConfig.remoteConfig().setDefaults(fromPlist: "remote_config_defaults")

        let downloadGroup = DispatchGroup()

        downloadGroup.enter()
        SpidProducts.store.requestProducts { success, products in
            if let products = products, success {
                UserDataManager.main.products = products
                downloadGroup.leave()
            }
            /* In case of error it means that the products were not fetched and i dont want to enter the app
               let it be stuck and the user to reload the app
             */
        }
        
        downloadGroup.enter()
        getRemoteConfig {
            downloadGroup.leave()
        }
        
        downloadGroup.enter()
        loadAppOpenAdIfAppropriate(viewVontroller: self) {
            downloadGroup.leave()
        }
        
        
        
        downloadGroup.notify(queue: DispatchQueue.main) { [weak self] in
             if let appOpenAd = self?.appOpenAd,
                let rootViewController = self?.view.window?.rootViewController {
                 appOpenAd.present(fromRootViewController: rootViewController)
                 return
             }
             else {
                self?.pushMainViewController()
             }
        }
    }
    

    
    func loadAppOpenAdIfAppropriate(viewVontroller: UIViewController, completion: @escaping VoidClosure) {
        
        guard SpidProducts.store.userPurchasedProVersion() == nil else {
            print("AppOpenAd: purchased pro version")
            completion()
            return
        }
        
        guard AppOpenAd.manager.amountOfAppOpens >= AppOpenAd.manager.minimumAppOpensRequiredToShowAd else {
            print("AppOpenAd: amount of ads less than minimum")
            completion()
            return
        }
        
        var unitId = "ca-app-pub-5159016515859793/1688354407"
        #if DEBUG
        unitId = "ca-app-pub-3940256099942544/5662855259"
        #endif
                
        GADAppOpenAd.load(withAdUnitID: unitId, request: GADRequest(),
                          orientation: UIInterfaceOrientation.portrait) { [weak self] ad, error in
            if let error = error {
                self?.error = error
                completion()
                return
            }
            
            AppOpenAd.manager.amountOfAppOpens = 0
            self?.appOpenAd = ad
            self?.appOpenAd?.fullScreenContentDelegate = self
            
            completion()
            
        }
    }

    func pushMainViewController() {
        let mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        navigationController?.pushViewController(mainViewController, animated: false)
    }
    
    func getRemoteConfig(completion: @escaping VoidClosure) {
        let remoteConfig = RemoteConfig.remoteConfig()

        #if DEBUG
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        #endif
        
        remoteConfig.fetch { (status, error) -> Void in
          if status == .success {
            print("Config fetched!")
            remoteConfig.activate { changed, error in
              // ...
            }
          } else {
            print("Config not fetched")
            print("Error: \(error?.localizedDescription ?? "No error available.")")
          }

          completion()
        }

    }
    
}

fileprivate typealias FullScreenContentDelegate = SplashViewController
extension SplashViewController {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
       pushMainViewController()
    }
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
    }
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        pushMainViewController()
    }
}
