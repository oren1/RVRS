//
//  YearlySubscriptionPurchaseVC.swift
//  RVRS
//
//  Created by oren shalev on 17/03/2024.
//

import UIKit

enum PricingModel: String {
    case lifetime = "lifetime"
    case weekly = "weekly"
}

class YearlySubscriptionPurchaseVC: PurchaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        productIdentifier = BoomerangProducts.boomerangYearlySubscription
        product = UserDataManager.main.products.first {$0.productIdentifier == productIdentifier}
        priceLabel?.text = "\(product.localizedPrice) / year"
    }

}
