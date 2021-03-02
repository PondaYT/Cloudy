// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Ad types
enum AdType {
    case fullscreen
    case menu
}

protocol AdService {

    /// Show full screen add
    func showFullscreenAd()

    /// Show ad inside a give view
    func showAd(in view: UIView, at index: Int)

}
