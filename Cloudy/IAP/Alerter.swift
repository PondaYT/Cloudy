// Copyright (c) 2021 Nomad5. All rights reserved.

import UIKit
import StoreKit

class Alerter {

    /// Types of alerts
    enum AlertType {
        case tipChoice
        case cannotMakePayments
        case somethingWentWrong
        case purchaseSuccess
    }

    /// Alert texts
    private let alertInfo:      [AlertType: (title: String, message: String)] = [
        .tipChoice: ("Wooohaaa! <3", "Thank you for your consideration to support our development. Select the size of your tip!"),
        .cannotMakePayments: ("Too sad", "It seems you are not allowed to make any payments!"),
        .somethingWentWrong: ("Strange", "Something went wrong. Please try again later"),
        .purchaseSuccess: ("You are the best!", "Huge thanks for supporting the development <3")
    ]

    /// The view controller it acts on
    private let viewController: UIViewController

    /// Construction with dependencies
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    /// Show alert with available tips
    func showAlert(for products: [SKProduct], purchaseHandler: @escaping (SKProduct) -> Void) {
        guard let info = alertInfo[.tipChoice] else { return }
        let alert = UIAlertController(title: info.title, message: info.message, preferredStyle: .alert)
        products.forEach { product in
            guard let price = product.formattedPrice else {
                Log.e("Error getting price for \(product.productIdentifier)")
                return
            }
            alert.addAction(UIAlertAction(title: "\(product.localizedTitle) for \(price)",
                                          style: .default,
                                          handler: { _ in
                                              purchaseHandler(product)
                                              alert.dismiss(animated: true)
                                          }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in alert.dismiss(animated: true) }))
        viewController.present(alert, animated: true)
    }


    /// Show normal alert text
    func showAlert(for type: AlertType) {
        guard let info = alertInfo[type] else {
            Log.e("Error showing alert for type: \(type)")
            return
        }
        let alert = UIAlertController(title: info.title, message: info.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in alert.dismiss(animated: true) }))
        viewController.present(alert, animated: true)
    }
}
