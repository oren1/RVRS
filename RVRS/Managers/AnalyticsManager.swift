//
//  AnalyticsManager.swift
//  VideoSpeed
//
//  Created by oren shalev on 17/01/2024.
//

import Foundation
import FirebaseAnalytics

class AnalyticsManager {
    static func purchaseEvent() {
        let eventName = "purchase_event"
        Analytics.logEvent(eventName, parameters: [:])
    }
}

