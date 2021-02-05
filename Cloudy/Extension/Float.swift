// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Infix operator declaration
infix operator =~: ComparisonPrecedence

/// Convenience extension
extension Float {

    /// Check for similarity
    static func =~(lhs: Float, rhs: Float) -> Bool {
        abs(lhs - rhs) < 0.001
    }
}