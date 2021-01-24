// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import StoreKit

/// Product extension
extension SKProduct {

    /// Format the price
    var formattedPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)
    }

}