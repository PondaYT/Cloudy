// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import StoreKit

/// The in app purchase manager
class IAPManager: NSObject {

    /// Common errors
    enum IAPManagerError: LocalizedError {
        case noProductsFound
        case paymentWasCancelled
        case productRequestFailed

        var errorDescription: String? {
            switch self {
                case .noProductsFound: return "No In-App Purchases were found."
                case .productRequestFailed: return "Unable to fetch available In-App Purchase products at the moment."
                case .paymentWasCancelled: return "In-App Purchase process was cancelled."
            }
        }
    }

    /// All available products
    static private let productIds = Set([
                                            "com.nomad5.cloudy.tip.big",
                                            "com.nomad5.cloudy.tip.medium",
                                            "com.nomad5.cloudy.tip.small",
                                        ])

    /// Products received handler
    var onReceiveProductsHandler: ((Result<[SKProduct], IAPManagerError>) -> Void)?
    /// Purchase handler
    var onBuyProductHandler:      ((Result<Bool, Error>) -> Void)?

    /// Nasty singleton
    static let shared = IAPManager()

    /// Start observing the queue
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }

    /// Stop observing the queue
    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }

    /// Can we do payments?
    func canMakePayments() -> Bool {
        SKPaymentQueue.canMakePayments()
    }

    /// Get all products
    func getProducts(_ productsReceiveHandler: @escaping (_ result: Result<[SKProduct], IAPManagerError>) -> Void) {
        // Keep the handler (closure) that will be called when requesting for
        // products on the App Store is finished.
        onReceiveProductsHandler = productsReceiveHandler
        // Initialize a product request.
        let request = SKProductsRequest(productIdentifiers: IAPManager.productIds)
        // Set self as the its delegate.
        request.delegate = self
        // Make the request.
        request.start()
    }

    /// Purchase a product
    func buy(product: SKProduct, handler: @escaping (_ result: Result<Bool, Error>) -> Void) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        // Keep the completion handler.
        onBuyProductHandler = handler
    }
}

/// Payment transaction observer extension
extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
                case .purchased:
                    onBuyProductHandler?(.success(true))
                    SKPaymentQueue.default().finishTransaction(transaction)

                case .failed:
                    if let error = transaction.error as? SKError {
                        if error.code != .paymentCancelled {
                            onBuyProductHandler?(.failure(error))
                        } else {
                            onBuyProductHandler?(.failure(IAPManagerError.paymentWasCancelled))
                        }
                    }
                    SKPaymentQueue.default().finishTransaction(transaction)

                case .deferred, .purchasing, .restored:
                    break
                @unknown default:
                    break
            }
        }
    }
}

/// Products request extension
extension IAPManager: SKProductsRequestDelegate {
    /// Received products
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // Check if there are any products available.
        if response.products.count > 0 {
            // Call the following handler passing the received products.
            onReceiveProductsHandler?(.success(response.products))
        } else {
            // No products were found.
            onReceiveProductsHandler?(.failure(.noProductsFound))
        }
    }

    /// Error happened
    func request(_ request: SKRequest, didFailWithError error: Error) {
        onReceiveProductsHandler?(.failure(.productRequestFailed))
    }
}
