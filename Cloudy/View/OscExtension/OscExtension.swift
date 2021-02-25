// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import UIKit

/// The on screen controls extensions
@objc protocol OscExtension {

    /// Initialize extension in given layer
    func initialize(in layer: CALayer)
    /// Will be invoked once the on screen controls are drawn
    func drawButtons()

    #if !APPSTORE
        /// Handle touch down event
        func handleTouchDownEvent(_ touch: UITouch, touchLocation: CGPoint, controller: Controller, controllerSupport: ControllerSupport) -> Bool
        /// Handle touch up event
        func handleTouchUpEvent(_ touch: UITouch, controller: Controller, controllerSupport: ControllerSupport) -> Bool
        /// Handle touch movement, return true if you handled the touch
        func handleTouchMovedEvent(_ touch: UITouch) -> Bool
    #endif

    /// Indication if the left axis stick should support clicking
    func leftStickClickEnabled() -> Bool
    /// Indication if the right axis stick should support clicking
    func rightStickClickEnabled() -> Bool

    /// Visibility mixin. True means the on screen controls extension should be prominent,
    /// false means the regular one goes prominent
    func mixin(_ visible: Bool) -> VisibleButtons

}
