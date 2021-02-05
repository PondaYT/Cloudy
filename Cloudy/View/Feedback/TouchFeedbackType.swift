// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// The different types of feedback
@objc enum TouchFeedbackType: Int {
    case off      = 0
    case acoustic = 1
    case vibrate  = 2
    case all      = 3
}