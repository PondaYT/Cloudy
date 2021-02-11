// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Global assembler aggregate which is the point
/// where its decided which implementations are injected
#if !REKAIROS
    /// The regular assembler
    protocol Assembler: NoopOnScreenControlAssembler {

    }
#else
    /// The reKairos assembler
    protocol Assembler: FortniteHUDAssembler {

    }
#endif

/// The global runtime configuration. This is injected from the host
/// application and is used by several assemblers to configure their
/// implementations accordingly to the requested configuration
public struct Configuration {
    public let launchUrl: URL?
}

/// Global assembler instance that handles dependency resolving
class AppAssembler: Assembler {

    /// Runtime config
    internal let config: Configuration

    /// Construction
    init(with config: Configuration) {
        self.config = config
    }
}