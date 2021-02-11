// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Abstract assembler for optional on screen controls extensions
protocol OnScreenControlsExtensionAssembler {
    func resolve() -> OnScreenControlsExtension?
}

/// Extension of the global assembler
extension OnScreenControlsExtensionAssembler where Self: Assembler {

    func resolve() -> OnScreenControlsExtension? {
        #if REKAIROS
            return nil
        #else
            return nil
        #endif

    }
}
