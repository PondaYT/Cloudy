// Copyright (c) 2020 Nomad5. All rights reserved.

import Foundation
import GameController

/// Helper to see if a value is close to zero
private let closeToZero: (Float) -> Bool = { abs($0) < 0.0001 }

/// Hacky stuff for geforce now
private var shouldPulse: Bool = false

/// Convenience structs
struct ControllerElements {
    struct DPad {
        let up:    Bool
        let down:  Bool
        let left:  Bool
        let right: Bool
    }

    struct Buttons {
        let a: Bool
        let b: Bool
        let x: Bool
        let y: Bool
    }

    struct Menu {
        let back: Bool
        let play: Bool
        let home: Bool
    }

    struct Shoulder {
        let trigger:  Float
        let shoulder: Bool
    }

    struct Stick {
        let x:     Float
        let y:     Float
        let click: Bool
    }
}

/// Struct for generating a js readable json that contains the
/// proper values from the native controller
@objc class CloudyController: NSObject, Encodable {

    /// Enum for the specific json export
    public enum JsonType {
        case regular
        @available(*, deprecated, message: "Do not use geforceNowOld. The whole thing will be kicked soon")
        case geforceNowOld
    }

    /// Button of the controller
    @objc public class Button: NSObject, Encodable {
        let pressed: Bool
        let touched: Bool
        var value:   Float

        init(pressed: Bool, touched: Bool, value: Float) {
            self.pressed = pressed
            self.touched = touched
            self.value = value
        }

        /// Convenience creation helper for a digital button
        static let digital: (Bool) -> Button = {
            Button(pressed: $0, touched: $0, value: $0 ? 1 : 0)
        }
        /// Convenience creation helper for an analog button
        static let analog: (Float) -> Button = {
            Button(pressed: closeToZero($0), touched: closeToZero($0), value: $0)
        }

        func pulse() {
            value = max(value - 0.002, 0) + (shouldPulse ? 0.002 : 0)
            shouldPulse = !shouldPulse
        }

        static var untouched: Button {
            Button(pressed: false, touched: false, value: 0)
        }

        /// Check all values for similarity
        static func =~(lhs: Button, rhs: Button) -> Bool {
            lhs.pressed == rhs.pressed &&
            lhs.touched == rhs.touched &&
            lhs.value =~ rhs.value
        }
    }

    /// Axes and buttons are the only dynamic values
    let axes:    [Float]
    let buttons: [Button?]

    /// Some static ones for proper configuration
    private let connected: Bool   = true
    private let id:        String = UserDefaults.standard.controllerId.chromeFormat()
    private let index:     Int    = 0
    private let mapping:   String = "standard"
    private let timestamp: Float  = 0

    /// Empty controller
    @objc override init() {
        axes = [Float](repeating: 0, count: 4)
        buttons = [Button](repeating: .untouched, count: 17)
        super.init()
    }

    /// Construction
    init(axes: [Float], buttons: [Button]) {
        self.axes = axes
        self.buttons = buttons
    }

    /// Convenience construction
    init(id: Int8,
         leftStick: ControllerElements.Stick,
         rightStick: ControllerElements.Stick,
         leftShoulder: ControllerElements.Shoulder,
         rightShoulder: ControllerElements.Shoulder,
         dpad: ControllerElements.DPad,
         buttons: ControllerElements.Buttons,
         menu: ControllerElements.Menu) {
        axes = [
            leftStick.x,
            leftStick.y,
            rightStick.x,
            rightStick.y,
        ]
        self.buttons = [
            /*  0 */ .digital(buttons.a),
            /*  1 */ .digital(buttons.b),
            /*  2 */ .digital(buttons.x),
            /*  3 */ .digital(buttons.y),
            /*  4 */ .digital(leftShoulder.shoulder), // leftShoulder.controller,
            /*  5 */ .digital(rightShoulder.shoulder), // rightShoulder.controller,
            /*  6 */ .analog(leftShoulder.trigger), // leftTrigger.controller,
            /*  7 */ .analog(rightShoulder.trigger), // rightTrigger.controller,
            /*  8 */ .digital(menu.back), // buttonOptions.controller,
            /*  9 */ .digital(menu.play), // buttonMenu.controller,
            /* 10 */ .digital(leftStick.click), // leftThumbstickButton.controller,
            /* 11 */ .digital(rightStick.click), // rightThumbstickButton.controller,
            /* 12 */ .digital(dpad.up), // dpad.up.controller,
            /* 13 */ .digital(dpad.down), // dpad.down.controller,
            /* 14 */ .digital(dpad.left), // dpad.left.controller,
            /* 15 */ .digital(dpad.right), // dpad.right.controller,
            /* 16 */ .digital(menu.home), // buttonHome.controller,
        ]
    }

    /// Construction for touch controls from objc
    @objc convenience init(controllerNumber: Int8,
                           activeGamepadMask: Int,
                           buttonFlags: Int32,
                           leftTrigger: Float,
                           rightTrigger: Float,
                           leftStickX: Float,
                           leftStickY: Float,
                           rightStickX: Float,
                           rightStickY: Float) {
        let buttonSet = ButtonOptionSet(rawValue: buttonFlags)
        self.init(id: controllerNumber,
                  leftStick: ControllerElements.Stick(x: leftStickX,
                                                      y: leftStickY,
                                                      click: buttonSet.contains(.LS_CLK_FLAG)),
                  rightStick: ControllerElements.Stick(x: rightStickX,
                                                       y: rightStickY,
                                                       click: buttonSet.contains(.RS_CLK_FLAG)),
                  leftShoulder: ControllerElements.Shoulder(trigger: leftTrigger,
                                                            shoulder: buttonSet.contains(.LB_FLAG)),
                  rightShoulder: ControllerElements.Shoulder(trigger: rightTrigger,
                                                             shoulder: buttonSet.contains(.RB_FLAG)),
                  dpad: ControllerElements.DPad(up: buttonSet.contains(.UP_FLAG),
                                                down: buttonSet.contains(.DOWN_FLAG),
                                                left: buttonSet.contains(.LEFT_FLAG),
                                                right: buttonSet.contains(.RIGHT_FLAG)),
                  buttons: ControllerElements.Buttons(a: buttonSet.contains(.A_FLAG),
                                                      b: buttonSet.contains(.B_FLAG),
                                                      x: buttonSet.contains(.X_FLAG),
                                                      y: buttonSet.contains(.Y_FLAG)),
                  menu: ControllerElements.Menu(back: buttonSet.contains(.BACK_FLAG),
                                                play: buttonSet.contains(.PLAY_FLAG),
                                                home: buttonSet.contains(.HOME_FLAG)))
    }

    /// Export json string
    func toJson(for exportType: JsonType) -> String {
        if exportType == .geforceNowOld {
            buttons[6]?.pulse()
        }
        return jsonString
    }

    /// Conversion to json
    private var jsonString: String {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }

    /// Check all values for similarity
    static func =~(lhs: CloudyController, rhs: CloudyController) -> Bool {
        for index in 0..<lhs.axes.count {
            guard let lhsAxis = lhs.axes[safe: index],
                  let rhsAxis = rhs.axes[safe: index],
                  lhsAxis =~ rhsAxis else {
                return false
            }
        }
        for index in 0..<lhs.buttons.count {
            guard let lhsButton = lhs.buttons[safe: index],
                  let lhsButtonNonNil = lhsButton,
                  let rhsButton = rhs.buttons[safe: index],
                  let rhsButtonNonNil = rhsButton,
                  lhsButtonNonNil =~ rhsButtonNonNil else {
                return false
            }
        }
        if lhs.timestamp =~ rhs.timestamp &&
           lhs.id == rhs.id &&
           lhs.index == rhs.index &&
           lhs.connected == rhs.connected &&
           lhs.mapping == rhs.mapping {
            return true
        }
        return false
    }

}

