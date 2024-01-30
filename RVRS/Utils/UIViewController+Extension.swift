//
//  UIViewController+Extension.swift
//  RVRS
//
//  Created by oren shalev on 08/08/2023.
//

import Foundation
import UIKit
import FirebaseRemoteConfig

let loadinViewTag = 12


extension UIViewController {
    
    func getPurchaseViewController() -> PurchaseViewController {
        let purchaseViewController: PurchaseViewController
        purchaseViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
       
//        let businessModelType = RemoteConfig.remoteConfig().configValue(forKey: "boomerang_business_model_type").numberValue.intValue
//        let businessModel = BusinessModelType(rawValue: businessModelType)
//        switch businessModel {
//        case .limitedFeatures:
//           purchaseViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
//        default:
//            purchaseViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OneExportPurchaseViewController") as! OneExportPurchaseViewController
//        }
//        
        return purchaseViewController
    }
    
    func showLoading(opacity: Float? = nil, title: String? = nil) {
        let loadingView = LoadingView()
        loadingView.layer.opacity = opacity ?? 1
        loadingView.titleLabel.text = title ?? ""
        loadingView.tag = loadinViewTag
        disablePresentaionDismiss()
        loadingView.activityIndicator.startAnimating()
        view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            loadingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            loadingView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func hideLoading() {
        let loadingView = view.viewWithTag(loadinViewTag) as? LoadingView
        enablePresentationDismiss()
        loadingView?.activityIndicator.stopAnimating()
        loadingView?.removeFromSuperview()
    }

    func disablePresentaionDismiss() {
        isModalInPresentation = true
    }

    func enablePresentationDismiss() {
        isModalInPresentation = false
    }

    func showError(message: String) {
        let alert = UIAlertController(
          title: "Error",
          message: message,
          preferredStyle: .alert)
        alert.addAction(UIAlertAction(
          title: "OK",
          style: UIAlertAction.Style.cancel,
          handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

