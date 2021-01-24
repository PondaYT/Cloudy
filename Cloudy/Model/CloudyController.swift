// Copyright (c) 2020 Nomad5. All rights reserved.

import Foundation
import GameController

/// Helper to see if a value is close to zero
private let closeToZero: (Float) -> Bool = { abs($0) < 0.0001 }

/// Hacky stuff for geforce now
private var shouldPulse: Bool = false

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

    /// Construction for touch controls from objc
    @objc init(controllerNumber: CShort, activeGamepadMask: CShort,
               buttonFlags: CShort, leftTrigger: CUnsignedChar, rightTrigger: CUnsignedChar,
               leftStickX: CShort, leftStickY: CShort, rightStickX: CShort, rightStickY: CShort) {
        let buttonDigital: (Bool) -> Button = { Button(pressed: $0, touched: $0, value: $0 ? 1 : 0) }
        let buttonAnalog: (Float) -> Button = { Button(pressed: closeToZero($0), touched: closeToZero($0), value: $0) }
        let buttonSet = ButtonOptionSet(rawValue: Int(buttonFlags))
        axes = [
            Float(leftStickX) / Float(CShort.max),
            -1.0 * Float(leftStickY) / Float(CShort.max),
            Float(rightStickX) / Float(CShort.max),
            -1.0 * Float(rightStickY) / Float(CShort.max),
        ]
        buttons = [
            /*  0 */ buttonDigital(buttonSet.contains(.A_FLAG)),
            /*  1 */ buttonDigital(buttonSet.contains(.B_FLAG)),
            /*  2 */ buttonDigital(buttonSet.contains(.X_FLAG)),
            /*  3 */ buttonDigital(buttonSet.contains(.Y_FLAG)),
            /*  4 */ buttonDigital(buttonSet.contains(.LB_FLAG)), // leftShoulder.controller,
            /*  5 */ buttonDigital(buttonSet.contains(.RB_FLAG)), // rightShoulder.controller,
            /*  6 */ buttonAnalog(Float(leftTrigger) / Float(CUnsignedChar.max)), // leftTrigger.controller,
            /*  7 */ buttonAnalog(Float(rightTrigger) / Float(CUnsignedChar.max)), // rightTrigger.controller,
            /*  8 */ buttonDigital(buttonSet.contains(.BACK_FLAG)), // buttonOptions.controller,
            /*  9 */ buttonDigital(buttonSet.contains(.PLAY_FLAG)), // buttonMenu.controller,
            /* 10 */ buttonDigital(buttonSet.contains(.LS_CLK_FLAG)), // leftThumbstickButton.controller,
            /* 11 */ buttonDigital(buttonSet.contains(.RS_CLK_FLAG)), // rightThumbstickButton.controller,
            /* 12 */ buttonDigital(buttonSet.contains(.UP_FLAG)), // dpad.up.controller,
            /* 13 */ buttonDigital(buttonSet.contains(.DOWN_FLAG)), // dpad.down.controller,
            /* 14 */ buttonDigital(buttonSet.contains(.LEFT_FLAG)), // dpad.left.controller,
            /* 15 */ buttonDigital(buttonSet.contains(.RIGHT_FLAG)), // dpad.right.controller,
            /* 16 */ buttonDigital(false), // buttonHome.controller,
        ]
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

