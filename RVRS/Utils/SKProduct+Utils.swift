//
//  SKProduct+Utils.swift
//  VideoSpeed
//
//  Created by oren shalev on 23/07/2023.
//

import Foundation
import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
