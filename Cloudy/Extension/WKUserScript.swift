// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import WebKit

extension WKUserScript {

    static let standalone = WKUserScript(source: Scripts.standaloneOverride,
                                         injectionTime: .atDocumentEnd,
                                         forMainFrameOnly: true)

    static let controller = WKUserScript(source: Scripts.controllerOverride(),
                                         injectionTime: .atDocumentEnd,
                                         forMainFrameOnly: true)
}
