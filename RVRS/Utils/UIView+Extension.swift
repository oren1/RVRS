//
//  UIView+Extension.swift
//  RVRS
//
//  Created by oren shalev on 30/07/2025.
//

import UIKit

extension UIView {
    func attachToEdges(of superview: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(self)
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: constant),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: constant),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: constant),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: constant)
        ])
    }
}
