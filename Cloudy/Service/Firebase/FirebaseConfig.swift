// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Firebase

/// Helper for initializing firebase for multiple schemes and configurations
class FirebaseConfig: NSObject {

    /// Get the options
    static var options: FirebaseOptions? {
        get {
            guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else { return nil }
            guard let dic = NSDictionary(contentsOfFile: path) else { return nil }
            guard let file = dic["FIREBASE_CONFIG"] as? String else { return nil }
            guard let optionsFile = Bundle.main.path(forResource: file, ofType: "plist", inDirectory: "Sensitive/Firebase") else { return nil }
            guard let options = FirebaseOptions(contentsOfFile: optionsFile) else { return nil }
            return options
        }
    }

    /// Initialize firebase
    static func configure() {
        guard let options = FirebaseConfig.options else {
            Log.e("Invalid firebase options. Skipping Firebase initialization")
            return
        }
        FirebaseApp.configure(options: options)
    }
}
