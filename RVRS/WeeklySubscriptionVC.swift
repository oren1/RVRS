//
//  MonthlySubscriptionVC.swift
//  RVRS
//
//  Created by oren shalev on 16/06/2024.
//

import UIKit

class WeeklySubscriptionVC: PurchaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        productIdentifier = BoomerangProducts.weeklySubscription
        product = UserDataManager.main.products.first {$0.productIdentifier == productIdentifier}
        priceLabel?.text = "\(product.localizedPrice) / week"
    }
    
}
