//
//  UIViewController+Extension.swift
//  RVRS
//
//  Created by oren shalev on 08/08/2023.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showLoading() {
        let loadingView = LoadingView()
        loadingView.tag = 12
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
        let loadingView = view.viewWithTag(12) as? LoadingView
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

}

