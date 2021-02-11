// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Interface for local assembler
protocol NoopOnScreenControlAssembler {
    func resolve() -> OnScreenControlsExtension?
}

/// Extension of the global assembler
extension NoopOnScreenControlAssembler where Self: Assembler {
    func resolve() -> OnScreenControlsExtension? {
        nil
    }
}