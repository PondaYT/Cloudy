// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import UIKit

class FortniteHUD: OnScreenControlsExtension {


    // The button layers
    private let fortniteAim                = CALayer()
    private let fortniteAutorun            = CALayer()
    private let fortniteConfirm            = CALayer()
    private let fortniteCrouch_Down        = CALayer()
    private let fortniteCrouch_Up          = CALayer()
    private let fortniteCycle_Weapons_Down = CALayer()
    private let fortniteCycle_Weapons_Up   = CALayer()
    private let fortniteEdit_Crosshair     = CALayer()
    private let fortniteEdit_Reset         = CALayer()
    private let fortniteEdit               = CALayer()
    private let fortniteEmote_Wheel        = CALayer()
    private let fortniteExit               = CALayer()
    private let fortniteFloor_Selected     = CALayer()
    private let fortniteFloor_Unselected   = CALayer()
    private let fortniteInventory          = CALayer()
    private let fortniteJump               = CALayer()
    private let fortniteMic_Muted          = CALayer()
    private let fortniteMic_Unmuted        = CALayer()
    private let fortniteMove_Joystick      = CALayer()
    private let fortniteMove_Outer         = CALayer()
    private let fortniteOpen_Chest         = CALayer()
    private let fortniteOpen_Door          = CALayer()
    private let fortnitePing               = CALayer()
    private let fortnitePyramid_Selected   = CALayer()
    private let fortnitePyramid_Unselected = CALayer()
    private let fortniteQuick_Chat         = CALayer()
    private let fortniteQuick_Heal         = CALayer()
    private let fortniteRepair             = CALayer()
    private let fortniteReset              = CALayer()
    private let fortniteRotate             = CALayer()
    private let fortniteShoot_Big          = CALayer()
    private let fortniteShoot              = CALayer()
    private let fortniteStair_Selected     = CALayer()
    private let fortniteStair_Unselected   = CALayer()
    private let fortniteSwitch_To_Build    = CALayer()
    private let fortniteSwitch_To_Combat   = CALayer()
    private let fortniteThrow              = CALayer()
    private let fortniteUse                = CALayer()
    private let fortniteWall_Selected      = CALayer()
    private let fortniteWall_Unselected    = CALayer()

    // The button touches
    private var fortniteAimTouch:                UITouch?
    private var fortniteAutorunTouch:            UITouch?
    private var fortniteConfirmTouch:            UITouch?
    private var fortniteCrouch_DownTouch:        UITouch?
    private var fortniteCrouch_UpTouch:          UITouch?
    private var fortniteCycle_Weapons_DownTouch: UITouch?
    private var fortniteCycle_Weapons_UpTouch:   UITouch?
    private var fortniteEdit_CrosshairTouch:     UITouch?
    private var fortniteEdit_ResetTouch:         UITouch?
    private var fortniteEditTouch:               UITouch?
    private var fortniteEmote_WheelTouch:        UITouch?
    private var fortniteExitTouch:               UITouch?
    private var fortniteFloor_SelectedTouch:     UITouch?
    private var fortniteFloor_UnselectedTouch:   UITouch?
    private var fortniteInventoryTouch:          UITouch?
    private var fortniteJumpTouch:               UITouch?
    private var fortniteMic_MutedTouch:          UITouch?
    private var fortniteMic_UnmutedTouch:        UITouch?
    private var fortniteMove_JoystickTouch:      UITouch?
    private var fortniteMove_OuterTouch:         UITouch?
    private var fortniteOpen_ChestTouch:         UITouch?
    private var fortniteOpen_DoorTouch:          UITouch?
    private var fortnitePingTouch:               UITouch?
    private var fortnitePyramid_SelectedTouch:   UITouch?
    private var fortnitePyramid_UnselectedTouch: UITouch?
    private var fortniteQuick_ChatTouch:         UITouch?
    private var fortniteQuick_HealTouch:         UITouch?
    private var fortniteRepairTouch:             UITouch?
    private var fortniteResetTouch:              UITouch?
    private var fortniteRotateTouch:             UITouch?
    private var fortniteShoot_BigTouch:          UITouch?
    private var fortniteShootTouch:              UITouch?
    private var fortniteStair_SelectedTouch:     UITouch?
    private var fortniteStair_UnselectedTouch:   UITouch?
    private var fortniteSwitch_To_BuildTouch:    UITouch?
    private var fortniteSwitch_To_CombatTouch:   UITouch?
    private var fortniteThrowTouch:              UITouch?
    private var fortniteUseTouch:                UITouch?
    private var fortniteWall_SelectedTouch:      UITouch?
    private var fortniteWall_UnselectedTouch:    UITouch?

    /// Draw all buttons
    func drawButtons(in layer: CALayer) {
        guard let HUDCombatButtonXSaved = UserDefaults.standard.array(forKey: "reKairosCombatHUDRectX") as? [CGFloat],
              let HUDCombatButtonYSaved = UserDefaults.standard.array(forKey: "reKairosCombatHUDRectY") as? [CGFloat],
              let HUDCombatButtonWidthSaved = UserDefaults.standard.array(forKey: "reKairosCombatHUDRectWidth") as? [CGFloat],
              let HUDCombatButtonHeightSaved = UserDefaults.standard.array(forKey: "reKairosCombatHUDRectHeight") as? [CGFloat] else {
            return
        }

        let AimImage = image(with: UIImage(named: "Aim.png"), scaledToFill: CGSize(width: HUDCombatButtonWidthSaved[0], height: HUDCombatButtonHeightSaved[0]))
        fortniteAim.frame = CGRect(x: HUDCombatButtonXSaved[0], y: HUDCombatButtonYSaved[0], width: HUDCombatButtonWidthSaved[0], height: HUDCombatButtonHeightSaved[0])
        fortniteAim.contents = AimImage?.cgImage
        layer.addSublayer(fortniteAim)
    }

    func handleTouchMovedEvent(_ touch: UITouch) -> Bool {
        if (touch == fortniteAimTouch ||
            touch == fortniteAutorunTouch ||
            touch == fortniteConfirmTouch ||
            touch == fortniteCrouch_DownTouch ||
            touch == fortniteCrouch_UpTouch ||
            touch == fortniteCycle_Weapons_DownTouch ||
            touch == fortniteCycle_Weapons_UpTouch ||
            touch == fortniteEdit_CrosshairTouch ||
            touch == fortniteEdit_ResetTouch ||
            touch == fortniteEditTouch ||
            touch == fortniteEmote_WheelTouch ||
            touch == fortniteExitTouch ||
            touch == fortniteFloor_SelectedTouch ||
            touch == fortniteFloor_UnselectedTouch ||
            touch == fortniteInventoryTouch ||
            touch == fortniteJumpTouch ||
            touch == fortniteMic_MutedTouch ||
            touch == fortniteMic_UnmutedTouch ||
            touch == fortniteMove_JoystickTouch ||
            touch == fortniteMove_OuterTouch ||
            touch == fortniteOpen_ChestTouch ||
            touch == fortniteOpen_DoorTouch ||
            touch == fortnitePingTouch ||
            touch == fortnitePyramid_SelectedTouch ||
            touch == fortnitePyramid_UnselectedTouch ||
            touch == fortniteQuick_ChatTouch ||
            touch == fortniteQuick_HealTouch ||
            touch == fortniteRepairTouch ||
            touch == fortniteResetTouch ||
            touch == fortniteRotateTouch ||
            touch == fortniteShoot_BigTouch ||
            touch == fortniteShootTouch ||
            touch == fortniteStair_SelectedTouch ||
            touch == fortniteStair_UnselectedTouch ||
            touch == fortniteSwitch_To_BuildTouch ||
            touch == fortniteSwitch_To_CombatTouch ||
            touch == fortniteThrowTouch ||
            touch == fortniteUseTouch ||
            touch == fortniteWall_SelectedTouch ||
            touch == fortniteWall_UnselectedTouch) {
            return true;
        }
        return false
    }

    func handleTouchUpEvent(_ touch: UITouch, controller: Controller, controllerSupport: ControllerSupport) -> Bool {
        if (touch == fortniteAimTouch) {
            controllerSupport.updateLeftTrigger(controller, left: 0);
            fortniteAimTouch = nil
            return true
        }
        // ...
        else if (touch == fortniteJumpTouch) {
            controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.A_FLAG.rawValue);
            fortniteJumpTouch = nil
            return true
        }
        // ...
        return false
    }

    func handleTouchDownEvent(_ touch: UITouch, touchLocation: CGPoint, controller: Controller, controllerSupport: ControllerSupport) -> Bool {
        if (fortniteAim.presentation()?.hitTest(touchLocation) != nil) {
            controllerSupport.updateLeftTrigger(controller, left: 0xFF)
            fortniteAimTouch = touch
            return true
        }
        // ...
        else if (fortniteJump.presentation()?.hitTest(touchLocation) != nil) {
            controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.A_FLAG.rawValue);
            fortniteJumpTouch = touch
            return true
        }
        // ...
        return false
    }

    private func image(with image: UIImage?, scaledToFill size: CGSize) -> UIImage? {
        let scale     = CGFloat(max(size.width / (image?.size.width ?? 0.0), size.height / (image?.size.height ?? 0.0)))
        let width     = (image?.size.width ?? 0.0) * scale
        let height    = (image?.size.height ?? 0.0) * scale
        let imageRect = CGRect(
                x: (size.width - width) / 2.0,
                y: (size.height - height) / 2.0,
                width: width,
                height: height)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image?.draw(in: imageRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
