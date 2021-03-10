// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Interface for local assembler
protocol NoopAdServiceAssembler: AdServiceAssembler {
    func resolve() -> AdService
}

/// Extension of the global assembler
extension NoopAdServiceAssembler where Self: Assembler {

    func resolve() -> AdService {
        NoopAdService()
    }
}
