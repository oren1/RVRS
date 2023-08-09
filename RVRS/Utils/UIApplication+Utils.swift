//
//  UIApplication+Utils.swift
//  VideoSpeed
//
//  Created by oren shalev on 24/07/2023.
//

import Foundation

import UIKit

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
