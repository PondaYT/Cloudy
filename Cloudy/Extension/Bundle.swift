// Copyright (c) 2020 Nomad5. All rights reserved.

import Foundation

extension Bundle {

    /// Get release version number
    var releaseVersionNumber: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
    /// Get build number
    var buildVersionNumber:   String? {
        infoDictionary?["CFBundleVersion"] as? String
    }

}