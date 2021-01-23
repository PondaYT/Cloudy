// Copyright (c) 2020 Nomad5. All rights reserved.

import Foundation
import GameController

/// Infix operator declaration
infix operator =~: ComparisonPrecedence

/// Convenience extension
extension GCControllerButtonInput {

    /// Compare for similarity
    static func =~(lhs: GCControllerButtonInput, rhs: GCControllerButtonInput) -> Bool {
        lhs.isPressed == rhs.isPressed &&
        lhs.isTouched == rhs.isTouched &&
        lhs.value =~ rhs.value
    }

    /// Convenience creator
    var controller: CloudyController.Button {
        CloudyController.Button(pressed: isPressed, touched: isTouched, value: value)
    }

}

/// Convenience extension
extension Float {

    /// Check for similarity
    static func =~(lhs: Float, rhs: Float) -> Bool {
        abs(lhs - rhs) < 0.001
    }
}

/// Convenience extension
extension GCExtendedGamepad {

    /// Check all values for similarity
    static func =~(lhs: GCExtendedGamepad, rhs: GCExtendedGamepad) -> Bool {
        // if different nullable values,
        guard (lhs.buttonOptions == nil) == (rhs.buttonOptions == nil),
              (lhs.buttonHome == nil) == (rhs.buttonHome == nil),
              (lhs.leftThumbstickButton == nil) == (rhs.leftThumbstickButton == nil),
              (lhs.rightThumbstickButton == nil) == (rhs.rightThumbstickButton == nil) else {
            return false
        }
        // compare actual values
        guard let lhsButtonOptions = lhs.buttonOptions,
              let lhsButtonHome = lhs.buttonHome,
              let lhsLeftThumbstickButton = lhs.leftThumbstickButton,
              let lhsRightThumbstickButton = lhs.rightThumbstickButton,
              let rhsButtonOptions = rhs.buttonOptions,
              let rhsButtonHome = rhs.buttonHome,
              let rhsLeftThumbstickButton = rhs.leftThumbstickButton,
              let rhsRightThumbstickButton = rhs.rightThumbstickButton,
              lhs.leftThumbstick.xAxis.value =~ rhs.leftThumbstick.xAxis.value,
              lhs.leftThumbstick.yAxis.value =~ rhs.leftThumbstick.yAxis.value,
              lhs.rightThumbstick.xAxis.value =~ rhs.rightThumbstick.xAxis.value,
              lhs.rightThumbstick.yAxis.value =~ rhs.rightThumbstick.yAxis.value,
              lhs.buttonA =~ rhs.buttonA,
              lhs.buttonB =~ rhs.buttonB,
              lhs.buttonX =~ rhs.buttonX,
              lhs.buttonY =~ rhs.buttonY,
              lhs.leftShoulder =~ rhs.leftShoulder,
              lhs.rightShoulder =~ rhs.rightShoulder,
              lhs.leftTrigger =~ rhs.leftTrigger,
              lhs.rightTrigger =~ rhs.rightTrigger,
              lhsButtonOptions =~ rhsButtonOptions,
              lhs.buttonMenu =~ rhs.buttonMenu,
              lhsLeftThumbstickButton =~ rhsLeftThumbstickButton,
              lhsRightThumbstickButton =~ rhsRightThumbstickButton,
              lhs.dpad.up =~ rhs.dpad.up,
              lhs.dpad.down =~ rhs.dpad.down,
              lhs.dpad.left =~ rhs.dpad.left,
              lhs.dpad.right =~ rhs.dpad.right,
              lhsButtonHome =~ rhsButtonHome else {
            return false
        }
        return true
    }

    /// Type enum
    public enum id: Int {
        case playstation, xbox, stadia, nintendo

        func chromeFormat() -> String {
            switch self {
                case .playstation: // DualShock 4 v2 (Circle, Cross, Triangle, Square, L1, R1, L2, R2)
                    return "Cloudy emulated DualShock4 controller (STANDARD GAMEPAD Vendor: 054c Product: 09cc)"
                case .xbox: // Xbox One S Bluetooth (Dreamcast ABXY, LB, RB, LT, RT)
                    return "Cloudy emulated XboxOneS controller (STANDARD GAMEPAD Vendor: 045e Product: 02fd)"
                case .stadia: // Stadia controller (Dreamcast ABXY, L1, R1, L2, R2 — same as Apple's layout)
                    return "Cloudy emulated Stadia controller (STANDARD GAMEPAD Vendor: 18d1 Product: 9400)"
                case .nintendo: // Switch Pro controller (Classic ABXY, L, R, ZL, ZR)
                    return "Cloudy emulated SwitchPro controller (STANDARD GAMEPAD Vendor: 057e Product: 2009)"
            }
        }
    }

    /// Convert to json
    func toCloudyController() -> CloudyController? {
        guard let buttonOptions = buttonOptions,
              let buttonHome = buttonHome,
              let leftThumbstickButton = leftThumbstickButton,
              let rightThumbstickButton = rightThumbstickButton else {
            return nil
        }
        return CloudyController(
                axes: [
                    leftThumbstick.xAxis.value,
                    -1.0 * leftThumbstick.yAxis.value,
                    rightThumbstick.xAxis.value,
                    -1.0 * rightThumbstick.yAxis.value
                ],
                buttons: [
                    /*  0 */ buttonA.controller,
                    /*  1 */ buttonB.controller,
                    /*  2 */ buttonX.controller,
                    /*  3 */ buttonY.controller,
                    /*  4 */ leftShoulder.controller,
                    /*  5 */ rightShoulder.controller,
                    /*  6 */ leftTrigger.controller,
                    /*  7 */ rightTrigger.controller,
                    /*  8 */ buttonOptions.controller,
                    /*  9 */ buttonMenu.controller,
                    /* 10 */ leftThumbstickButton.controller,
                    /* 11 */ rightThumbstickButton.controller,
                    /* 12 */ dpad.up.controller,
                    /* 13 */ dpad.down.controller,
                    /* 14 */ dpad.left.controller,
                    /* 15 */ dpad.right.controller,
                    /* 16 */ buttonHome.controller,
                ])
    }
}
