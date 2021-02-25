// Copyright (c) 2021 Nomad5. All rights reserved.

import UIKit
import StoreKit

class Alerter {

    /// Types of alerts
    enum AlertType {
        case remindToDonate
        case tipChoice
        case cannotMakePayments
        case somethingWentWrong
        case purchaseSuccess
        case comingSoonAddBookmark
    }

    /// Actions for alerts
    struct Action {
        let text:     String
        let callback: () -> Void
    }

    /// Alert texts
    private let alertInfo:      [AlertType: (title: String, message: String)] = [
        .remindToDonate: ("Are you enjoying this App?", "If you do, please consider supporting the development with a small donation."),
        .tipChoice: ("Wooohaaa! <3", "Thank you for your consideration to support our development. Select the size of your tip!"),
        .cannotMakePayments: ("Too sad", "It seems you are not allowed to make any payments!"),
        .somethingWentWrong: ("Strange", "Something went wrong. Please try again later"),
        .purchaseSuccess: ("You are the best!", "Huge thanks for supporting the development <3"),
        .comingSoonAddBookmark: ("Coming soon!", "Adding bookmarks will be added soon")
    ]

    /// The view controller it acts on
    private let viewController: UIViewController

    /// Construction with dependencies
    init(mainViewController: MainViewController) {
        viewController = mainViewController.viewController
    }

    /// Show alert with available tips
    func showAlert(for products: [SKProduct], purchaseHandler: @escaping (SKProduct) -> Void) {
        guard let info = alertInfo[.tipChoice] else { return }
        let alert = UIAlertController(title: info.title, message: info.message, preferredStyle: .alert)
        products.sorted { p1, p2 in p1.price.compare(p2.price) == .orderedAscending }
                .forEach { product in
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
    func showAlert(for type: AlertType, positiveAction: Action? = nil, negativeAction: Action? = nil) {
        guard let info = alertInfo[type] else {
            Log.e("Error showing alert for type: \(type)")
            return
        }
        let alert = UIAlertController(title: info.title, message: info.message, preferredStyle: .alert)
        if let positive = positiveAction {
            alert.addAction(UIAlertAction(title: positive.text, style: .cancel, handler: { _ in
                alert.dismiss(animated: true)
                positive.callback()
            }))
        }
        if let negative = negativeAction {
            alert.addAction(UIAlertAction(title: negative.text, style: .default, handler: { _ in
                alert.dismiss(animated: true)
                negative.callback()
            }))
        }
        if positiveAction == nil && negativeAction == nil {
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in alert.dismiss(animated: true) }))
        }
        viewController.present(alert, animated: true)
    }
}
