// Copyright (c) 2020 Nomad5. All rights reserved.

import Foundation
import GameController

/// Convenience access to persisted user defaults
@objc extension UserDefaults {

    /// Some keys for the user defaults
    private struct Config {
        static let lastVisitedUrlKey       = "lastVisitedUrlKey"
        static let manualUserAgent         = "manualUserAgent"
        static let useManualUserAgent      = "useManualUserAgent"
        static let allowInlineMedia        = "allowInlineMedia"
        static let controllerId            = "controllerId"
        static let onScreenControlsLevel   = "onScreenControlsLevel"
        static let touchFeedbackType       = "touchFeedbackType"
        static let customJsCodeToInject    = "customJsCodeToInject"
        static let webViewScale            = "webViewScale"
        static let actAsStandaloneApp      = "actAsStandaloneApp"
        static let injectControllerScripts = "injectControllerScripts"
    }

    /// Read / write the last visited url
    var          lastVisitedUrl:          URL? {
        get {
            UserDefaults.standard.url(forKey: Config.lastVisitedUrlKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Config.lastVisitedUrlKey)
        }
    }

    /// Read / write the manually overwritten user agent
    var          manualUserAgent:         String? {
        get {
            UserDefaults.standard.string(forKey: Config.manualUserAgent)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Config.manualUserAgent)
        }
    }

    /// Read / write the flag if the manual user agent should be used
    var          useManualUserAgent:      Bool {
        get {
            if UserDefaults.standard.object(forKey: Config.useManualUserAgent) == nil {
                return false
            }
            return UserDefaults.standard.bool(forKey: Config.useManualUserAgent)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Config.useManualUserAgent)
        }
    }

    /// Read / write the flag if the app should act as standalone PWA
    var          actAsStandaloneApp:      Bool {
        get {
            if UserDefaults.standard.object(forKey: Config.actAsStandaloneApp) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: Config.actAsStandaloneApp)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Config.actAsStandaloneApp)
        }
    }

    /// Read / write allow inline media enabled flag
    var          allowInlineMedia:        Bool {
        get {
            if UserDefaults.standard.object(forKey: Config.allowInlineMedia) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: Config.allowInlineMedia)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Config.allowInlineMedia)
        }
    }

    /// Read / write the webView scale
    var          webViewScale:            Int {
        get {
            UserDefaults.standard.integer(forKey: Config.webViewScale)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Config.webViewScale)
        }
    }

    /// Read / write the flag if the app should inject the custom controller scripts
    var          injectControllerScripts: Bool {
        get {
            if UserDefaults.standard.object(forKey: Config.injectControllerScripts) == nil {
                return false
            }
            return UserDefaults.standard.bool(forKey: Config.injectControllerScripts)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Config.injectControllerScripts)
        }
    }

    /// Read / write flag for controller ID
    @nonobjc var controllerId:            GCExtendedGamepad.id {
        get {
            if UserDefaults.standard.object(forKey: Config.controllerId) == nil {
                return .xbox
            }
            return GCExtendedGamepad.id(rawValue: UserDefaults.standard.integer(forKey: Config.controllerId))!
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Config.controllerId)
        }
    }

    /// Read / write flag for on screen controller
    @objc var    onScreenControlsLevel:   OnScreenControlsLevel {
        get {
            if UserDefaults.standard.object(forKey: Config.onScreenControlsLevel) == nil {
                return .off
            }
            return OnScreenControlsLevel(rawValue: UserDefaults.standard.integer(forKey: Config.onScreenControlsLevel))!
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Config.onScreenControlsLevel)
        }
    }

    /// Read / write flag for on screen controller feedback type
    @objc var    touchFeedbackType:       TouchFeedbackType {
        get {
            if UserDefaults.standard.object(forKey: Config.touchFeedbackType) == nil {
                return .off
            }
            return TouchFeedbackType(rawValue: UserDefaults.standard.integer(forKey: Config.touchFeedbackType))!
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Config.touchFeedbackType)
        }
    }

    /// Read / write the custom js injection
    var          customJsCodeToInject:    String? {
        get {
            UserDefaults.standard.string(forKey: Config.customJsCodeToInject)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Config.customJsCodeToInject)
        }
    }

}
