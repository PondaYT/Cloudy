// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Abstract assembler for optional on screen controls extensions
protocol OnScreenControlsExtensionAssembler {
    func resolve() -> OnScreenControlsExtension?
}
