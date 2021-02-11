// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Interface for local assembler
protocol AlerterAssembler {
    func resolve() -> Alerter
}

/// Extension of the global assembler
extension AlerterAssembler where Self: Assembler {
    func resolve() -> Alerter {
        Alerter(mainViewController: resolve())
    }
}