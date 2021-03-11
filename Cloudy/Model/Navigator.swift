// Copyright (c) 2020 Nomad5. All rights reserved.

import Foundation

/// Model class to map navigation based on url
class Navigator {

    /// Some global constants
    struct Config {
        struct Url {
            static let google                = URL(string: "https://www.google.com")!
            static let googleStadia          = URL(string: "https://stadia.google.com")!
            static let googleAccounts        = URL(string: "https://accounts.google.com")!
            static let geforceNowOld         = URL(string: "https://play.geforcenow.com")!
            static let geforceNowOldFortnite = URL(string: "https://play.geforcenow.com/mall/#/deeplink?game-id=46bfab06-d864-465d-9e56-2d9e45cdee0a")!
            static let geforceNowBeta        = URL(string: "https://beta.play.geforcenow.com")!
            static let boosteroid            = URL(string: "https://cloud.boosteroid.com")!
            static let nvidiaRoot            = URL(string: "https://www.nvidia.com")!
            static let amazonLuna            = URL(string: "https://amazon.com/luna")!
            static let gamepadTester         = URL(string: "https://gamepad-tester.com")!
            static let patreon               = URL(string: "https://www.patreon.com/cloudyApp")!
            static let patreonReKairos       = URL(string: "https://www.patreon.com/reKairos")!
            static let paypal                = URL(string: "https://www.paypal.me/pools/c/8tPw2veZIm")!
            static let paypalReKairos        = URL(string: "https://www.paypal.com/pools/c/8xD5TnEOZK")!
            static let discord               = URL(string: "https://discord.gg/9sgTxFx")!
        }

        struct UserAgent {
            static let chromeDesktop = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.72 Safari/537.36"
            static let chromeOS      = "Mozilla/5.0 (X11; CrOS aarch64 13099.85.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.110 Safari/537.36"
            static let iPhone        = "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15"
            static let safariIOS     = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.2 Safari/605.1.15"
        }
    }

    /// The navigation that shall be executed
    struct Navigation {
        let userAgent:  String?
        let bridgeType: CloudyController.JsonType
    }

    /// Get the initial navigation
    var initialWebsite: URL {
        #if APPSTORE
            return Config.Url.google
        #elseif REKAIROS
            return Config.Url.geforceNowOldFortnite
        #else
            if let lastVisitedUrl = UserDefaults.standard.lastVisitedUrl {
                return lastVisitedUrl
            }
            return Config.Url.googleStadia
        #endif
    }

    /// Map navigation address
    func getNavigation(for address: String?) -> Navigation {
        // early exit
        guard let requestedUrl = address else {
            return Navigation(userAgent: nil, bridgeType: .regular)
        }
        // manual user agent override
        let userAgentOverride: String? = UserDefaults.standard.useManualUserAgent ? UserDefaults.standard.manualUserAgent : nil
        // old regular geforce now
        if requestedUrl.starts(with: Config.Url.geforceNowOld.absoluteString) {
            return Navigation(userAgent: userAgentOverride ?? Config.UserAgent.chromeOS, bridgeType: .regular)
        }
        return Navigation(userAgent: userAgentOverride, bridgeType: .regular)
    }

    /// Handle popup
    func shouldOpenPopup(for url: String?) -> Bool {
        // early exit
        guard let url = url else {
            return false
        }
        if url.starts(with: Config.Url.boosteroid.absoluteString) {
            return false
        }
        return true
    }
}
