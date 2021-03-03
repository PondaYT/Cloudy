// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Interface for local assembler
protocol AdServiceAssembler {
    func resolve() -> AdService
}
