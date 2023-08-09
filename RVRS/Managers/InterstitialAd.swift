//
//  InterstitialAd.swift
//  VideoSpeed
//
//  Created by oren shalev on 03/08/2023.
//

import Foundation
import GoogleMobileAds
import FirebaseRemoteConfig

class InterstitialAd: NSObject {
    
    static let manager = InterstitialAd()
    private var interstitial: GADInterstitialAd?
    var finishedAdLogic: VoidClosure?
    var timer: Timer!
    var adsInterval: Int = RemoteConfig.remoteConfig().configValue(forKey: "adsInterval").numberValue.intValue
    weak var rootController: UIViewController?
    
    var adsIntervalTimeElapsed: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: "adsIntervalTimeElapsed")
        }
        get {
            return UserDefaults.standard.integer(forKey: "adsIntervalTimeElapsed")
        }
    }
    
    override init() {
        super.init()
        print("adsInterval", adsInterval)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    
    
    func start() {
                // Start loading the interstiotial ad only if the user didn't purchase the pro version
        if SpidProducts.store.userPurchasedProVersion() == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(increaseTimeElapsed), userInfo: nil, repeats: true)

            self.loadInterstitialAd()
        }
    }
        
    func stop() {
        timer.invalidate()
    }
    
    @objc private func increaseTimeElapsed() {
        adsIntervalTimeElapsed += 1
        print("time elapsed: \(adsIntervalTimeElapsed)")
    }
        
    private func loadInterstitialAd() {
            
            print("Interstitial Ad Loading...")
            
            var unitId = "ca-app-pub-5159016515859793/7002081213"
            #if DEBUG
                unitId = "ca-app-pub-3940256099942544/4411468910"
            #endif

            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: unitId,
                                   request: request) { [weak self] (ad, error) in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                print("Ad loaded successfully")
                self?.interstitial = ad
                self?.interstitial?.fullScreenContentDelegate = self

            }
        }


    func showAdIfAppropriate(controller: UIViewController, completion: @escaping VoidClosure) {
            self.rootController = controller
            finishedAdLogic = completion
        
            guard SpidProducts.store.userPurchasedProVersion() == nil else {
                print("purchased pro version")
                finishedAdLogic?()
                return
            }
            
            guard adsIntervalTimeElapsed >= adsInterval  else {
                print("timeElapsed \(adsIntervalTimeElapsed)")
                finishedAdLogic?()
                print("Interval time didn't passed")
                return
            }
            
            guard let interstitial = self.interstitial else {
                finishedAdLogic?()
                print("Ad wasn't ready")
                return
            }
            
            return interstitial.present(fromRootViewController: controller)
            
        }
        
    }





    fileprivate typealias FullScreenContendDelegate = InterstitialAd
    extension FullScreenContendDelegate: GADFullScreenContentDelegate {
        /// Tells the delegate that the ad failed to present full screen content.
        func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
            finishedAdLogic?()
          print("Ad did fail to present full screen content. Error: \(error)")
        }

        func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
            print("Ad will present full screen content.")
        }

        /// Tells the delegate that the ad dismissed full screen content.
        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
          print("Ad did dismiss full screen content.")
            adsIntervalTimeElapsed = 0
            loadInterstitialAd()
            finishedAdLogic?()
        }
        
    }



    fileprivate typealias AppEvents = InterstitialAd
    extension AppEvents {
        @objc func appDidBecomeActive() {
            if SpidProducts.store.userPurchasedProVersion() == nil {
                timer?.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(increaseTimeElapsed), userInfo: nil, repeats: true)
            }
        }
        
        @objc func appDidEnterBackground() {
            timer?.invalidate()
        }
    }
