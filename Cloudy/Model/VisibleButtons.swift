// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

@objc class VisibleButtons: NSObject {

    @objc private(set) var buttons:       Bool
    @objc private(set) var dpad:          Bool
    @objc private(set) var leftShoulder:  Bool
    @objc private(set) var rightShoulder: Bool
    @objc private(set) var leftStick:     Bool
    @objc private(set) var rightStick:    Bool
    @objc private(set) var menuButtons:   Bool

    @objc init(buttons: Bool = false,
               dpad: Bool = false,
               leftShoulder: Bool = false,
               rightShoulder: Bool = false,
               leftStick: Bool = false,
               rightStick: Bool = false,
               menuButtons: Bool = false) {
        self.buttons = buttons
        self.dpad = dpad
        self.leftShoulder = leftShoulder
        self.rightShoulder = rightShoulder
        self.leftStick = leftStick
        self.rightStick = rightStick
        self.menuButtons = menuButtons
    }

    static var all: VisibleButtons {
        VisibleButtons(buttons: true,
                       dpad: true,
                       leftShoulder: true,
                       rightShoulder: true,
                       leftStick: true,
                       rightStick: true,
                       menuButtons: true)
    }
}