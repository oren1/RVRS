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
    static var usingSpeedSlider: Bool = false
    static var usingLoops: Bool = false
    static var soundOn: Bool = true
    
    func productforIdentifier(productIndentifier: ProductIdentifier) -> SKProduct? {
        if let product =  products.first(where: { $0.productIdentifier ==  productIndentifier}) {
            return product
        }
        
        return nil
    }
    
    func usingProFeatures() -> Bool {
        if UserDataManager.usingSpeedSlider ||
            UserDataManager.usingLoops ||
            !UserDataManager.soundOn {
            return true
        }
        return false
    }
}
