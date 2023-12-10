//
//  UserDataManager.swift
//  VideoSpeed
//
//  Created by oren shalev on 23/07/2023.
//

import Foundation
import StoreKit

class UserDataManager {
    
    static let main: UserDataManager = UserDataManager()
    var products: [SKProduct]!
    static var usingMoreThanTwoLoops = false
    static var usingRverse = false
    static var speedSliderAboveOnePointFive = false
    static var speedSliderBelowOne = false
    
    func productforIdentifier(productIndentifier: ProductIdentifier) -> SKProduct? {
        if let product =  products.first(where: { $0.productIdentifier ==  productIndentifier}) {
            return product
        }
        
        return nil
    }
    
    func usingProFeatures() -> Bool {
        if UserDataManager.usingMoreThanTwoLoops ||
            UserDataManager.usingRverse ||
            UserDataManager.speedSliderAboveOnePointFive ||
            UserDataManager.speedSliderBelowOne {
            return true
        }
        return false
    }
}
