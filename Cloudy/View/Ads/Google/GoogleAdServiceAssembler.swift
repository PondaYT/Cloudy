// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Interface for local assembler
protocol GoogleAdServiceAssembler: AdServiceAssembler {
    func resolve() -> AdService
}

/// Extension of the global assembler
extension GoogleAdServiceAssembler where Self: Assembler {

    func resolve() -> GoogleAdSensitives {
        GoogleAdSensitives()
    }

    func resolve() -> AdService {
        GoogleAdService(with: resolve(), googleAdSensitives: resolve())
    }
}
