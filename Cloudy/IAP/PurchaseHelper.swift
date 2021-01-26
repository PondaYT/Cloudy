// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import StoreKit

class PurchaseHelper {

    /// Injected dependencies
    private let alerter: Alerter

    /// Construction with dependencies
    init(with alerter: Alerter) {
        self.alerter = alerter
    }

    /// Handle tip jar button
    func showProducts() {
        IAPManager.shared.getProducts { (result) in
            DispatchQueue.main.async { [weak self] in
                switch result {
                    case .success(let products):
                        self?.alerter.showAlert(for: products) { [weak self] product in
                            self?.purchase(product: product)
                        }
                    case .failure(let error):
                        self?.alerter.showAlert(for: .somethingWentWrong)
                        Log.e("Error fetching products: \(error)")
                }
            }
        }
    }

    /// Purchase an item
    func purchase(product: SKProduct) {
        if !IAPManager.shared.canMakePayments() {
            alerter.showAlert(for: .cannotMakePayments)
            Log.e("User cannot make payments")
        } else {
            IAPManager.shared.buy(product: product) { (result) in
                DispatchQueue.main.async { [weak self] in
                    switch result {
                        case .success(_):
                            UserDefaults.standard.didDonateAlready = true
                            self?.alerter.showAlert(for: .purchaseSuccess)
                        case .failure(let error):
                            if case IAPManager.IAPManagerError.paymentWasCancelled = error {
                                Log.i("Payment cancelled")
                            } else {
                                Log.e("Error occurred")
                                self?.alerter.showAlert(for: .somethingWentWrong)
                            }
                    }
                }
            }
        }
    }
}
