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
    weak var rootController: UIViewController?
    

    func loadInterstitialAd() {
            
            print("Interstitial Ad Loading...")
            
            var unitId = "ca-app-pub-5159016515859793/9670873866"
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


    func showAd(controller: UIViewController, completion: @escaping VoidClosure) {
            self.rootController = controller
            finishedAdLogic = completion
        
            guard SpidProducts.store.userPurchasedProVersion() == nil else {
                print("purchased pro version")
                finishedAdLogic?()
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
        /// Tells the delegate that the ad dismissed full screen content.
        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
          print("Ad did dismiss full screen content.")
            loadInterstitialAd()
            finishedAdLogic?()
        }
        
    }

