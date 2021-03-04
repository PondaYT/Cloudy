// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import UIKit


/// Indicate if the regular controller should handle click, or move
@objc class TouchResult: NSObject {

    @objc enum AxisStick: Int {
        case none
        case left
        case right
    }

    @objc let handled:     Bool
    @objc let addMovement: AxisStick

    init(handled: Bool, addMovement: AxisStick? = nil) {
        self.handled = handled
        self.addMovement = addMovement ?? .none
        super.init()
    }

    @objc static let unhandled             = TouchResult(handled: false)
    @objc static let handledNoMovement     = TouchResult(handled: true)
    @objc static let handledPlusRightStick = TouchResult(handled: true, addMovement: .right)
    @objc static let handledPlusLeftStick  = TouchResult(handled: true, addMovement: .left)
}

/// The on screen controls extensions
@objc protocol OscExtension {

    /// Initialize extension in given layer
    func initialize(in layer: CALayer)
    /// Will be invoked once the on screen controls are drawn
    func drawButtons()

    #if !APPSTORE
        /// Handle touch down event
        func handleTouchDownEvent(_ touch: UITouch, touchLocation: CGPoint, controller: Controller, controllerSupport: ControllerSupport) -> TouchResult
        /// Handle touch up event
        func handleTouchUpEvent(_ touch: UITouch, controller: Controller, controllerSupport: ControllerSupport) -> TouchResult
        /// Handle touch movement, return true if you handled the touch
        func handleTouchMovedEvent(_ touch: UITouch) -> TouchResult
    #endif

    /// Indication if the left axis stick should support clicking
    func leftStickClickEnabled() -> Bool
    /// Indication if the right axis stick should support clicking
    func rightStickClickEnabled() -> Bool

    /// Visibility mixin. True means the on screen controls extension should be prominent,
    /// false means the regular one goes prominent
    func mixin(_ visible: Bool) -> VisibleButtons

}
