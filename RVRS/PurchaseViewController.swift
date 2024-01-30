//
//  PurchaseViewController.swift
//  VideoSpeed
//
//  Created by oren shalev on 23/07/2023.
//

import UIKit
import StoreKit
import FirebaseRemoteConfig
import FirebaseAnalytics

class PurchaseViewController: UIViewController {

    var product: SKProduct!
    var productIdentifier: ProductIdentifier!

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    var onDismiss: VoidClosure?

    @IBOutlet weak var oneTimeChargeLabel: UILabel!
    lazy var loadingView: LoadingView = {
        loadingView = LoadingView()
        return loadingView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productIdentifier = BoomerangProducts.proVersionLatest
        product = UserDataManager.main.products.first {$0.productIdentifier == productIdentifier}
        priceLabel.text = product.localizedPrice
        
        
//        let businessModelType = RemoteConfig.remoteConfig().configValue(forKey: "business_model_type").numberValue.intValue
//        let businessModel = BusinessModelType(rawValue: businessModelType)
//        switch businessModel {
//        case .onlyProVersionExport:
//            titleLabel.text = "Start Using Rvrs Now!"
//        case .allowedReverseExport:
//            titleLabel.text = "Use Boomerang Pro Now!"
//        case .none:
//            fatalError()
//        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            backButton.isHidden = true
        }
        
    }
    
    @IBAction func purchaseButtonTapped(_ sender: Any) {
                Task {
                    do {
                        showLoading()
                        let products = try await Product.products(for: [productIdentifier])
                        let product =  products.first
                        let purchaseResult = try await product?.purchase()
                        switch purchaseResult {
                        case .success(let verificationResult):
                            switch verificationResult {
                            case .verified(let transaction):
                                // Give the user access to purchased content.
                                print("verified transaction \(transaction)")
                                Analytics.logTransaction(transaction)
                                BoomerangProducts.store.updateIdentifier(identifier: transaction.productID)
                                AnalyticsManager.purchaseEvent()
                                purchaseCompleted()
                                // Complete the transaction after providing
                                // the user access to the content.
                                await transaction.finish()
                            case .unverified(_, let verificationError):
                                // Handle unverified transactions based
                                // on your business model.
                                showVerificationError(error: verificationError)
                                
                            }
                        case .pending:
                            // The purchase requires action from the customer.
                            // If the transaction completes,
                            // it's available through Transaction.updates.
                            self.hideLoading()

                            break
                        case .userCancelled:
                            // The user canceled the purchase.
                            self.hideLoading()
                            break
                        @unknown default:
                            self.hideLoading()
                            break
                        }
                    }
                    catch {
                        print("fatal error: couldn't get subscription products from Product struct")
                    }
        
                }
    }
    
    
    @IBAction func restoreButtonTapped(_ sender: Any) {
        Task {
            do {
                showLoading()
                try await AppStore.sync() // syncs all transactions from the appstore
                let refreshStatus =  try await BoomerangProducts.store.refreshPurchasedProducts()
                switch refreshStatus {
                case .foundActivePurchase:
                    showRefreshAlert(title: "You're All Set")
                case .noPurchasesFound:
                    showRefreshAlert(title: "No Active Subscriptions Found")
                }
            }
            catch {
                print(error)
            }
            
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    func showVerificationError(error: VerificationResult<Transaction>.VerificationError) {
        let alert = UIAlertController(
          title: "Could't Complete Purchase",
          message: error.localizedDescription,
          preferredStyle: .alert)
        alert.addAction(UIAlertAction(
          title: "OK",
          style: UIAlertAction.Style.cancel,
          handler: { [weak self] _ in
              self?.hideLoading()
          }))
        present(alert, animated: true, completion: nil)
    }
   
    func showRefreshAlert(title: String)  {
        let alert = UIAlertController(
          title: title,
          message: nil,
          preferredStyle: .alert)
        alert.addAction(UIAlertAction(
          title: "OK",
          style: UIAlertAction.Style.cancel,
          handler: { [weak self] _ in
              self?.restoreCompleted()
          }))
        present(alert, animated: true, completion: nil)
    }
    
    func purchaseCompleted() {
        onDismiss?()
        hideLoading()
        dismiss(animated: true)
    }
    
    func restoreCompleted() {
        onDismiss?()
        hideLoading()
        dismiss(animated: true)
    }
 
}
