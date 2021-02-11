// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import UIKit

/// Global assembler aggregate which is the point
/// where its decided which implementations are injected
protocol Assembler: OnScreenControlsExtensionAssembler,
                    AlerterAssembler,
                    IAPAssembler {
    /// Provide config
    var config: Configuration { get }
    /// Provide main view controller
    func resolve() -> MainViewController
}

/// The global runtime configuration. This is injected from the host
/// application and is used by several assemblers to configure their
/// implementations accordingly to the requested configuration
struct Configuration {
    let launchUrl: URL?
}

/// Protocol to hide the main root view controller
protocol MainViewController {
    var viewController: UIViewController { get }
}

/// Global assembler instance that handles dependency resolving
class AppAssembler: Assembler {

    /// Get the main view controller
    func resolve() -> MainViewController {
        mainViewController
    }

    /// Runtime config
    internal let config:             Configuration
    internal let mainViewController: MainViewController

    /// Construction
    init(mainViewController: MainViewController,
         config: Configuration) {
        self.mainViewController = mainViewController
        self.config = config
    }
}