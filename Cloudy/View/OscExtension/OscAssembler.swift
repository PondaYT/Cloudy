// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Abstract assembler for optional on screen controls extensions
protocol OscAssembler {
    func resolve() -> OscExtension?
}

/// Extension of the global assembler
extension OscAssembler where Self: Assembler {

    func resolve() -> OscExtension? {
        #if REKAIROS
            return nil
        #else
            return nil
        #endif

    }
}
