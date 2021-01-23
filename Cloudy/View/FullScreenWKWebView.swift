// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import WebKit

/// Extend web kit view to not have any insets, thus full fullscreen
class FullScreenWKWebView: WKWebView {
    override var safeAreaInsets: UIEdgeInsets {
        .zero
    }
}

/// Types of navigation
enum Navigation {
    case forward
    case backward
    case reload
}

/// Navigation execution hidden behind this protocol
protocol WebController {
    func executeNavigation(action: Navigation)
    func navigateTo(address: String)
    func clearCache()
}

extension FullScreenWKWebView: WebController {

    /// The message used for the handler
    static let messageHandlerName: String = "controller"

    /// Execute given navigation
    func executeNavigation(action: Navigation) {
        switch action {
            case .forward:
                goForward()
            case .backward:
                goBack()
            case .reload:
                guard let url = url else { return }
                navigateTo(url: url)
        }
    }

    /// Clear cache
    func clearCache() {
        // clean cookies
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // clean cache
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                #if DEBUG
                    Log.i("WKWebsiteDataStore record deleted: \(record)")
                #endif
            }
        }
    }

    /// Navigate to a given string
    func navigateTo(address: String) {
        /// build url
        guard let url = URL(string: address.fixedProtocol()) else {
            Log.e("Error creating Url from '\(address)'")
            return
        }
        // load
        navigateTo(url: url)
    }

    /// Navigate to url
    func navigateTo(url: URL) {
        load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData))
    }

    /// Inject inject the js controller script
    func inject(scripts: [String]) {
        scripts.forEach { script in
            evaluateJavaScript(script, completionHandler: nil)
        }
    }
}
