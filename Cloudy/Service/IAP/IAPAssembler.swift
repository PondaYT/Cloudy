// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Interface for local assembler
protocol IAPAssembler {
    func resolve() -> IAPPurchaseHelper
}

/// Extension of the global assembler
extension IAPAssembler where Self: Assembler {
    func resolve() -> IAPPurchaseHelper {
        IAPPurchaseHelper(alerter: resolve())
    }
}