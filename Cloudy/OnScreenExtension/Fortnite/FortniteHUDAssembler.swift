// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Interface for local assembler
protocol FortniteHUDAssembler {
    func resolve() -> OnScreenControlsExtension?
}

/// Extension of the global assembler
extension FortniteHUDAssembler where Self: Assembler {
    func resolve() -> OnScreenControlsExtension? {
        FortniteHUD()
    }
}