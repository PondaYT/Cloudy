// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

class NoopAdService: AdService {

    /// Show full screen google add
    func showFullscreenAd() {
        // noop
    }

    /// Show google ad inside a give view
    func showAd(in parentView: UIView, at index: Int) {
        // noop
    }
}
