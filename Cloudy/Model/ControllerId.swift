// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Type enum
public enum ControllerId: Int {
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