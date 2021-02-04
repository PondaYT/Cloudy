// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import UIKit

class FortniteHUD: OnScreenControlsExtension {

    // COMBAT CALAYER AND TOUCHES
    // The button layers
    private let fortniteAim                = CALayer()
    private let fortniteCrouch_Down          = CALayer()
    private let fortniteEdit_Reset         = CALayer()
    private let fortniteEmote_Wheel        = CALayer()
    private let fortniteFloor_Selected     = CALayer()
    private let fortniteInventory          = CALayer()
    private let fortniteInteract           = CALayer() // ADD THIS!
    private let fortniteJump               = CALayer()
    private let fortnitePing               = CALayer()
    private let fortnitePyramid_Selected   = CALayer()
    private let fortniteShoot_Big          = CALayer()
    private let fortniteShoot              = CALayer()
    private let fortniteStair_Selected     = CALayer()
    private let fortniteSwitch_To_Build    = CALayer()
    private let fortniteUse                = CALayer()
    private let fortniteWall_Selected      = CALayer()
    
    //var listOfCombatHUDButtons = ["Aim", "Crouch Up", "Cycle Weapons Down", "Cycle Weapons Up", "Edit Reset", "Emote Wheel", "Floor Selected", "Inventory", "Interact", "Jump", "Ping", "Pyramid Selected", "Shoot Big", "Shoot", "Stair Selected", "Switch To Build", "Use", "Wall Selected"]
    
    
    //   var listOfCombatHUDButtons = ["Aim", "Crouch Up", "Edit Reset", "Emote Wheel", "Floor Selected", "Inventory", "Interact", "Jump", "Ping", "Pyramid Selected", "Shoot Big", "Shoot", "Stair Selected", "Switch To Build", "Use", "Wall Selected"]
    
    // The button touches
    private var fortniteAimTouch:                UITouch?
    private var fortniteCrouch_DownTouch:          UITouch?
    private var fortniteEdit_ResetTouch:         UITouch?
    private var fortniteEmote_WheelTouch:        UITouch?
    private var fortniteFloor_SelectedTouch:     UITouch?
    private var fortniteInventoryTouch:          UITouch?
    private var fortniteInteractTouch:           UITouch?
    private var fortniteJumpTouch:               UITouch?
    private var fortnitePingTouch:               UITouch?
    private var fortnitePyramid_SelectedTouch:   UITouch?
    private var fortniteShoot_BigTouch:          UITouch?
    private var fortniteShootTouch:              UITouch?
    private var fortniteStair_SelectedTouch:     UITouch?
    private var fortniteSwitch_To_BuildTouch:    UITouch?
    private var fortniteUseTouch:                UITouch?
    private var fortniteWall_SelectedTouch:      UITouch?
    
    
    // BUILD CALAYER AND TOUCHES
    
    private let fortniteBuildEdit_Reset = CALayer()
    private let fortniteBuildEmote_Wheel = CALayer()
    private let fortniteBuildFloor_Selected = CALayer()
    private let fortniteBuildJump = CALayer()
    private let fortniteBuildPing = CALayer()
    private let fortniteBuildPyramid_Selected = CALayer()
    private let fortniteBuildRepair = CALayer()
    private let fortniteBuildReset = CALayer()
    private let fortniteBuildRotate = CALayer()
    private let fortniteBuildShoot_Big = CALayer()
    private let fortniteBuildShoot = CALayer()
    private let fortniteBuildStair_Selected = CALayer()
    private let fortniteBuildSwitch_To_Combat = CALayer()
    private let fortniteBuildUse = CALayer()
    private let fortniteBuildWall_Selected = CALayer()
    
    //var listOfBuildingHUDButtons = ["Edit Reset", "Emote Wheel",  "Floor Selected", "Jump", "Ping", "Pyramid Selected", "Repair", "Reset", "Rotate", "Shoot Big", "Shoot", "Stair Selected", "Switch To Combat", "Use", "Wall Selected"]

    
    
    private var fortniteBuildEdit_ResetTouch: UITouch?
    private var fortniteBuildEmote_WheelTouch: UITouch?
    private var fortniteBuildFloor_SelectedTouch: UITouch?
    private var fortniteBuildJumpTouch: UITouch?
    private var fortniteBuildPingTouch: UITouch?
    private var fortniteBuildPyramid_SelectedTouch: UITouch?
    private var fortniteBuildRepairTouch: UITouch?
    private var fortniteBuildResetTouch: UITouch?
    private var fortniteBuildRotateTouch: UITouch?
    private var fortniteBuildShoot_BigTouch: UITouch?
    private var fortniteBuildShootTouch: UITouch?
    private var fortniteBuildStair_SelectedTouch: UITouch?
    private var fortniteBuildSwitch_To_CombatTouch: UITouch?
    private var fortniteBuildUseTouch: UITouch?
    private var fortniteBuildWall_SelectedTouch: UITouch?
    
    var listOfBuildingHUDButtons = ["Edit Reset",  "Emote Wheel",  "Floor Selected", "Jump", "Ping", "Pyramid Selected", "Repair", "Reset", "Rotate", "Shoot Big", "Shoot", "Stair Selected", "Switch To Combat", "Use", "Wall Selected"]

    
    // EDIT MODE CALAYER AND UITOUCH
    private let fortniteEditConfirm = CALayer()
    private let fortniteEditEdit = CALayer()
    private let fortniteEditPing = CALayer()
    private let fortniteEditReset = CALayer()
    private let fortniteEditRotate = CALayer()
    private let fortniteEditShoot_Big = CALayer()
    private let fortniteEditShoot = CALayer()
    private let fortniteEditSwitch_To_Combat = CALayer()

    var listOfEditHUDButtons = ["Confirm", "Edit", "Ping", "Reset", "Rotate", "Shoot Big", "Shoot", "Switch To Combat"]
    
    private var fortniteEditConfirmTouch: UITouch?
    private var fortniteEditEditTouch: UITouch?
    private var fortniteEditPingTouch: UITouch?
    private var fortniteEditResetTouch: UITouch?
    private var fortniteEditRotateTouch: UITouch?
    private var fortniteEditShoot_BigTouch: UITouch?
    private var fortniteEditShootTouch: UITouch?
    private var fortniteEditSwitch_To_CombatTouch: UITouch?

    

    var combatMode = true
    var buildMode = false
    var editMode = false
    
    
    

    /// Draw all buttons
    func drawButtons(in layer: CALayer) {
        guard let HUDCombatButtonXSaved = UserDefaults.standard.array(forKey: "reKairosCombatHUDRectX") as? [CGFloat],
              let HUDCombatButtonYSaved = UserDefaults.standard.array(forKey: "reKairosCombatHUDRectY") as? [CGFloat],
              let HUDCombatButtonWidthSaved = UserDefaults.standard.array(forKey: "reKairosCombatHUDRectWidth") as? [CGFloat],
              let HUDCombatButtonHeightSaved = UserDefaults.standard.array(forKey: "reKairosCombatHUDRectHeight") as? [CGFloat] else {
            return
        }
        
        
        guard let HUDBuildButtonXSaved = UserDefaults.standard.array(forKey: "reKairosBuildingHUDRectX") as? [CGFloat],
              let HUDBuildButtonYSaved = UserDefaults.standard.array(forKey: "reKairosBuildingHUDRectY") as? [CGFloat],
              let HUDBuildButtonWidthSaved = UserDefaults.standard.array(forKey: "reKairosBuildingHUDRectWidth") as? [CGFloat],
              let HUDBuildButtonHeightSaved = UserDefaults.standard.array(forKey: "reKairosBuildingHUDRectHeight") as? [CGFloat] else {
            return
        }

        
        let AimImage = UIImage(named: "Aim.png")
        fortniteAim.frame = CGRect(x: HUDCombatButtonXSaved[0], y: HUDCombatButtonYSaved[0], width: HUDCombatButtonWidthSaved[0], height: HUDCombatButtonHeightSaved[0])
        fortniteAim.contents = AimImage?.cgImage
        layer.addSublayer(fortniteAim)

        let Crouch_UpImage = UIImage(named: "Crouch Up.png")
        fortniteCrouch_Down.frame = CGRect(x: HUDCombatButtonXSaved[1], y: HUDCombatButtonYSaved[1], width: HUDCombatButtonWidthSaved[1], height: HUDCombatButtonHeightSaved[1])
        fortniteCrouch_Down.contents = Crouch_UpImage?.cgImage
        layer.addSublayer(fortniteCrouch_Down)

        let Edit_ResetImage = UIImage(named: "Edit Reset.png")
        fortniteEdit_Reset.frame = CGRect(x: HUDCombatButtonXSaved[2], y: HUDCombatButtonYSaved[2], width: HUDCombatButtonWidthSaved[2], height: HUDCombatButtonHeightSaved[2])
        fortniteEdit_Reset.contents = Edit_ResetImage?.cgImage
        layer.addSublayer(fortniteEdit_Reset)

        let Emote_WheelImage = UIImage(named: "Emote Wheel.png")
        fortniteEmote_Wheel.frame = CGRect(x: HUDCombatButtonXSaved[3], y: HUDCombatButtonYSaved[3], width: HUDCombatButtonWidthSaved[3], height: HUDCombatButtonHeightSaved[3])
        fortniteEmote_Wheel.contents = Emote_WheelImage?.cgImage
        layer.addSublayer(fortniteEmote_Wheel)

        let Floor_SelectedImage = UIImage(named: "Floor Selected.png")
        fortniteFloor_Selected.frame = CGRect(x: HUDCombatButtonXSaved[4], y: HUDCombatButtonYSaved[4], width: HUDCombatButtonWidthSaved[4], height: HUDCombatButtonHeightSaved[4])
        fortniteFloor_Selected.contents = Floor_SelectedImage?.cgImage
        layer.addSublayer(fortniteFloor_Selected)

        let InventoryImage = UIImage(named: "Inventory.png")
        fortniteInventory.frame = CGRect(x: HUDCombatButtonXSaved[5], y: HUDCombatButtonYSaved[5], width: HUDCombatButtonWidthSaved[5], height: HUDCombatButtonHeightSaved[5])
        fortniteInventory.contents = InventoryImage?.cgImage
        layer.addSublayer(fortniteInventory)

        let JumpImage = UIImage(named: "Jump.png")
        fortniteJump.frame = CGRect(x: HUDCombatButtonXSaved[6], y: HUDCombatButtonYSaved[6], width: HUDCombatButtonWidthSaved[6], height: HUDCombatButtonHeightSaved[6])
        fortniteJump.contents = JumpImage?.cgImage
        layer.addSublayer(fortniteJump)

        let PingImage = UIImage(named: "Ping.png")
        fortnitePing.frame = CGRect(x: HUDCombatButtonXSaved[7], y: HUDCombatButtonYSaved[7], width: HUDCombatButtonWidthSaved[7], height: HUDCombatButtonHeightSaved[7])
        fortnitePing.contents = PingImage?.cgImage
        layer.addSublayer(fortnitePing)

        let Pyramid_SelectedImage = UIImage(named: "Pyramid Selected.png")
        fortnitePyramid_Selected.frame = CGRect(x: HUDCombatButtonXSaved[8], y: HUDCombatButtonYSaved[8], width: HUDCombatButtonWidthSaved[8], height: HUDCombatButtonHeightSaved[8])
        fortnitePyramid_Selected.contents = Pyramid_SelectedImage?.cgImage
        layer.addSublayer(fortnitePyramid_Selected)

        let Shoot_BigImage = UIImage(named: "Shoot Big.png")
        fortniteShoot_Big.frame = CGRect(x: HUDCombatButtonXSaved[9], y: HUDCombatButtonYSaved[9], width: HUDCombatButtonWidthSaved[9], height: HUDCombatButtonHeightSaved[9])
        fortniteShoot_Big.contents = Shoot_BigImage?.cgImage
        layer.addSublayer(fortniteShoot_Big)

        let ShootImage = UIImage(named: "Shoot.png")
        fortniteShoot.frame = CGRect(x: HUDCombatButtonXSaved[10], y: HUDCombatButtonYSaved[10], width: HUDCombatButtonWidthSaved[10], height: HUDCombatButtonHeightSaved[10])
        fortniteShoot.contents = ShootImage?.cgImage
        layer.addSublayer(fortniteShoot)

        let Stair_SelectedImage = UIImage(named: "Stair Selected.png")
        fortniteStair_Selected.frame = CGRect(x: HUDCombatButtonXSaved[11], y: HUDCombatButtonYSaved[11], width: HUDCombatButtonWidthSaved[11], height: HUDCombatButtonHeightSaved[11])
        fortniteStair_Selected.contents = Stair_SelectedImage?.cgImage
        layer.addSublayer(fortniteStair_Selected)

        let Switch_To_BuildImage = UIImage(named: "Switch To Build.png")
        fortniteSwitch_To_Build.frame = CGRect(x: HUDCombatButtonXSaved[12], y: HUDCombatButtonYSaved[12], width: HUDCombatButtonWidthSaved[12], height: HUDCombatButtonHeightSaved[12])
        fortniteSwitch_To_Build.contents = Switch_To_BuildImage?.cgImage
        layer.addSublayer(fortniteSwitch_To_Build)

        let UseImage = UIImage(named: "Use.png")
        fortniteUse.frame = CGRect(x: HUDCombatButtonXSaved[13], y: HUDCombatButtonYSaved[13], width: HUDCombatButtonWidthSaved[13], height: HUDCombatButtonHeightSaved[13])
        fortniteUse.contents = UseImage?.cgImage
        layer.addSublayer(fortniteUse)

        let Wall_SelectedImage = UIImage(named: "Wall Selected.png")
        fortniteWall_Selected.frame = CGRect(x: HUDCombatButtonXSaved[14], y: HUDCombatButtonYSaved[14], width: HUDCombatButtonWidthSaved[14], height: HUDCombatButtonHeightSaved[14])
        fortniteWall_Selected.contents = Wall_SelectedImage?.cgImage
        layer.addSublayer(fortniteWall_Selected)
        
        
        
        

        let Edit_ResetBuildImage = UIImage(named: "Edit Reset.png")
        fortniteBuildEdit_Reset.frame = CGRect(x: HUDBuildButtonXSaved[0], y: HUDBuildButtonYSaved[0], width: HUDBuildButtonWidthSaved[0], height: HUDBuildButtonHeightSaved[0])
        fortniteBuildEdit_Reset.contents = Edit_ResetBuildImage?.cgImage
        layer.addSublayer(fortniteBuildEdit_Reset)

        let Emote_WheelBuildImage = UIImage(named: "Emote Wheel.png")
        fortniteBuildEmote_Wheel.frame = CGRect(x: HUDBuildButtonXSaved[1], y: HUDBuildButtonYSaved[1], width: HUDBuildButtonWidthSaved[1], height: HUDBuildButtonHeightSaved[1])
        fortniteBuildEmote_Wheel.contents = Emote_WheelBuildImage?.cgImage
        layer.addSublayer(fortniteBuildEmote_Wheel)

        let Floor_SelectedBuildImage = UIImage(named: "Floor Selected.png")
        fortniteBuildFloor_Selected.frame = CGRect(x: HUDBuildButtonXSaved[2], y: HUDBuildButtonYSaved[2], width: HUDBuildButtonWidthSaved[2], height: HUDBuildButtonHeightSaved[2])
        fortniteBuildFloor_Selected.contents = Floor_SelectedBuildImage?.cgImage
        layer.addSublayer(fortniteBuildFloor_Selected)

        let JumpBuildImage = UIImage(named: "Jump.png")
        fortniteBuildJump.frame = CGRect(x: HUDBuildButtonXSaved[4], y: HUDBuildButtonYSaved[4], width: HUDBuildButtonWidthSaved[4], height: HUDBuildButtonHeightSaved[4])
        fortniteBuildJump.contents = JumpBuildImage?.cgImage
        layer.addSublayer(fortniteBuildJump)

        let PingBuildImage = UIImage(named: "Ping.png")
        fortniteBuildPing.frame = CGRect(x: HUDBuildButtonXSaved[5], y: HUDBuildButtonYSaved[5], width: HUDBuildButtonWidthSaved[5], height: HUDBuildButtonHeightSaved[5])
        fortniteBuildPing.contents = PingBuildImage?.cgImage
        layer.addSublayer(fortniteBuildPing)

        let Pyramid_SelectedBuildImage = UIImage(named: "Pyramid Selected.png")
        fortniteBuildPyramid_Selected.frame = CGRect(x: HUDBuildButtonXSaved[6], y: HUDBuildButtonYSaved[6], width: HUDBuildButtonWidthSaved[6], height: HUDBuildButtonHeightSaved[6])
        fortniteBuildPyramid_Selected.contents = Pyramid_SelectedBuildImage?.cgImage
        layer.addSublayer(fortniteBuildPyramid_Selected)

        let RepairBuildImage = UIImage(named: "Repair.png")
        fortniteBuildRepair.frame = CGRect(x: HUDBuildButtonXSaved[7], y: HUDBuildButtonYSaved[7], width: HUDBuildButtonWidthSaved[7], height: HUDBuildButtonHeightSaved[7])
        fortniteBuildRepair.contents = RepairBuildImage?.cgImage
        layer.addSublayer(fortniteBuildRepair)

        let ResetBuildImage = UIImage(named: "Reset.png")
        fortniteBuildReset.frame = CGRect(x: HUDBuildButtonXSaved[8], y: HUDBuildButtonYSaved[8], width: HUDBuildButtonWidthSaved[8], height: HUDBuildButtonHeightSaved[8])
        fortniteBuildReset.contents = ResetBuildImage?.cgImage
        layer.addSublayer(fortniteBuildReset)

        let RotateBuildImage = UIImage(named: "Rotate.png")
        fortniteBuildRotate.frame = CGRect(x: HUDBuildButtonXSaved[9], y: HUDBuildButtonYSaved[9], width: HUDBuildButtonWidthSaved[9], height: HUDBuildButtonHeightSaved[9])
        fortniteBuildRotate.contents = RotateBuildImage?.cgImage
        layer.addSublayer(fortniteBuildRotate)

        let Shoot_BigBuildImage = UIImage(named: "Shoot Big.png")
        fortniteBuildShoot_Big.frame = CGRect(x: HUDBuildButtonXSaved[10], y: HUDBuildButtonYSaved[10], width: HUDBuildButtonWidthSaved[10], height: HUDBuildButtonHeightSaved[10])
        fortniteBuildShoot_Big.contents = Shoot_BigBuildImage?.cgImage
        layer.addSublayer(fortniteBuildShoot_Big)

        let ShootBuildImage = UIImage(named: "Shoot.png")
        fortniteBuildShoot.frame = CGRect(x: HUDBuildButtonXSaved[11], y: HUDBuildButtonYSaved[11], width: HUDBuildButtonWidthSaved[12], height: HUDBuildButtonHeightSaved[12])
        fortniteBuildShoot.contents = ShootBuildImage?.cgImage
        layer.addSublayer(fortniteBuildShoot)

        let Stair_SelectedBuildImage = UIImage(named: "Stair Selected.png")
        fortniteBuildStair_Selected.frame = CGRect(x: HUDBuildButtonXSaved[13], y: HUDBuildButtonYSaved[13], width: HUDBuildButtonWidthSaved[13], height: HUDBuildButtonHeightSaved[13])
        fortniteBuildStair_Selected.contents = Stair_SelectedBuildImage?.cgImage
        layer.addSublayer(fortniteBuildStair_Selected)

        let Switch_To_CombatBuildImage = UIImage(named: "Switch To Combat.png")
        fortniteBuildSwitch_To_Combat.frame = CGRect(x: HUDBuildButtonXSaved[14], y: HUDBuildButtonYSaved[14], width: HUDBuildButtonWidthSaved[14], height: HUDBuildButtonHeightSaved[14])
        fortniteBuildSwitch_To_Combat.contents = Switch_To_CombatBuildImage?.cgImage
        layer.addSublayer(fortniteBuildSwitch_To_Combat)

        let UseBuildImage = UIImage(named: "Use.png")
        fortniteBuildUse.frame = CGRect(x: HUDBuildButtonXSaved[15], y: HUDBuildButtonYSaved[15], width: HUDBuildButtonWidthSaved[15], height: HUDBuildButtonHeightSaved[15])
        fortniteBuildUse.contents = UseBuildImage?.cgImage
        layer.addSublayer(fortniteBuildUse)

        let Wall_SelectedBuildImage = UIImage(named: "Wall Selected.png")
        fortniteBuildWall_Selected.frame = CGRect(x: HUDBuildButtonXSaved[16], y: HUDBuildButtonYSaved[16], width: HUDBuildButtonWidthSaved[16], height: HUDBuildButtonHeightSaved[16])
        fortniteBuildWall_Selected.contents = Wall_SelectedBuildImage?.cgImage
        layer.addSublayer(fortniteBuildWall_Selected)


    }

    func handleTouchMovedEvent(_ touch: UITouch) -> Bool {
        if combatMode {
            if (touch == fortniteAimTouch ||
                    touch == fortniteCrouch_DownTouch ||
                    touch == fortniteEdit_ResetTouch ||
                    touch == fortniteEmote_WheelTouch ||
                    touch == fortniteFloor_SelectedTouch ||
                    touch == fortniteInventoryTouch ||
                    touch == fortniteJumpTouch ||
                    touch == fortnitePingTouch ||
                    touch == fortnitePyramid_SelectedTouch ||
                    touch == fortniteShoot_BigTouch ||
                    touch == fortniteShootTouch ||
                    touch == fortniteStair_SelectedTouch ||
                    touch == fortniteSwitch_To_BuildTouch ||
                    touch == fortniteUseTouch ||
                    touch == fortniteWall_SelectedTouch) {
                return true;
            }
            
        } else if buildMode {
            if (touch == fortniteBuildEdit_ResetTouch ||
                    touch == fortniteBuildEmote_WheelTouch ||
                    touch == fortniteBuildFloor_SelectedTouch ||
                    touch == fortniteBuildPingTouch ||
                    touch == fortniteBuildPyramid_SelectedTouch ||
                    touch == fortniteBuildRepairTouch ||
                    touch == fortniteBuildResetTouch ||
                    touch == fortniteBuildRotateTouch ||
                    touch == fortniteBuildShoot_BigTouch ||
                    touch == fortniteBuildShootTouch ||
                    touch == fortniteBuildStair_SelectedTouch ||
                    touch == fortniteBuildSwitch_To_CombatTouch ||
                    touch == fortniteBuildUseTouch ||
                    touch == fortniteBuildWall_SelectedTouch) {
                return true;
            }
        } else if editMode {
            
            
        }
        return false
    }
    
    
    func hideHUDButtons(hideCombat: Bool, hideBuild: Bool, hideEdit:Bool) {
        
        if hideCombat {
            fortniteAim.isHidden = true
            fortniteCrouch_Down.isHidden = true
            fortniteEdit_Reset.isHidden = true
            fortniteEmote_Wheel.isHidden = true
            fortniteFloor_Selected.isHidden = true
            fortniteInventory.isHidden = true
            fortniteJump.isHidden = true
            fortnitePing.isHidden = true
            fortnitePyramid_Selected.isHidden = true
            fortniteShoot_Big.isHidden = true
            fortniteShoot.isHidden = true
            fortniteStair_Selected.isHidden = true
            fortniteSwitch_To_Build.isHidden = true
            fortniteUse.isHidden = true
            fortniteWall_Selected.isHidden = true
        } else if hideBuild {

            fortniteBuildEdit_Reset.isHidden = true
            fortniteBuildEmote_Wheel.isHidden = true
            fortniteBuildFloor_Selected.isHidden = true
            fortniteBuildJump.isHidden = true
            fortniteBuildPing.isHidden = true
            fortniteBuildPyramid_Selected.isHidden = true
            fortniteBuildRepair.isHidden = true
            fortniteBuildReset.isHidden = true
            fortniteBuildRotate.isHidden = true
            fortniteBuildShoot_Big.isHidden = true
            fortniteBuildShoot.isHidden = true
            fortniteBuildStair_Selected.isHidden = true
            fortniteBuildSwitch_To_Combat.isHidden = true
            fortniteBuildUse.isHidden = true
            fortniteBuildWall_Selected.isHidden = true

        } else if hideEdit {
            
        }
        
    }
    
    func unhideHUDButtons(unhideCombat: Bool, unhideBuild: Bool, unhideEdit:Bool) {
        
        if unhideCombat {
            fortniteAim.isHidden = false
            fortniteCrouch_Down.isHidden = false
            fortniteEdit_Reset.isHidden = false
            fortniteEmote_Wheel.isHidden = false
            fortniteFloor_Selected.isHidden = false
            fortniteInventory.isHidden = false
            fortniteJump.isHidden = false
            fortnitePing.isHidden = false
            fortnitePyramid_Selected.isHidden = false
            fortniteShoot_Big.isHidden = false
            fortniteShoot.isHidden = false
            fortniteStair_Selected.isHidden = false
            fortniteSwitch_To_Build.isHidden = false
            fortniteUse.isHidden = false
            fortniteWall_Selected.isHidden = false
        } else if unhideBuild {
            fortniteBuildEdit_Reset.isHidden = false
            fortniteBuildEmote_Wheel.isHidden = false
            fortniteBuildFloor_Selected.isHidden = false
            fortniteBuildJump.isHidden = false
            fortniteBuildPing.isHidden = false
            fortniteBuildPyramid_Selected.isHidden = false
            fortniteBuildRepair.isHidden = false
            fortniteBuildReset.isHidden = false
            fortniteBuildRotate.isHidden = false
            fortniteBuildShoot_Big.isHidden = false
            fortniteBuildShoot.isHidden = false
            fortniteBuildStair_Selected.isHidden = false
            fortniteBuildSwitch_To_Combat.isHidden = false
            fortniteBuildUse.isHidden = false
            fortniteBuildWall_Selected.isHidden = false
        } else if unhideEdit {
            
        }
        
    }
    

    func handleTouchUpEvent(_ touch: UITouch, controller: Controller, controllerSupport: ControllerSupport) -> Bool {
        
        if combatMode {
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
            else if (touch == fortniteShootTouch) {
                controllerSupport.updateRightTrigger(controller, right: 0)
                fortniteShootTouch = nil
                return true
            }
            // ...
            else if (touch == fortniteShoot_BigTouch) {
                controllerSupport.updateRightTrigger(controller, right: 0)
                
                fortniteShoot_BigTouch = nil
                return true
            }
            // ...
            else if (touch == fortniteSwitch_To_BuildTouch) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                
                fortniteSwitch_To_BuildTouch = nil
                return true
            }
            // ...
            else if (touch == fortniteInventoryTouch) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.UP_FLAG.rawValue);
                
                fortniteInventoryTouch = nil
                return true
            }
            // ...
            else if (touch == fortnitePingTouch) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LEFT_FLAG.rawValue);
                
                fortnitePingTouch = nil
                return true
            }
            // ...
            else if (touch == fortniteEmote_WheelTouch) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.DOWN_FLAG.rawValue);
                
                fortniteEmote_WheelTouch = nil
                return true
            }
        } else if buildMode {
            if (touch == fortniteBuildSwitch_To_CombatTouch) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                fortniteBuildSwitch_To_CombatTouch = nil
                return true
            } else if (touch == fortniteBuildPyramid_SelectedTouch) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LB_FLAG.rawValue);
                fortniteBuildPyramid_SelectedTouch = nil
                return true
            } else if (touch == fortniteBuildWall_SelectedTouch) {
                controllerSupport.updateRightTrigger(controller, right: 0)
                fortniteBuildWall_SelectedTouch = nil
                return true
            } else if (touch == fortniteBuildFloor_SelectedTouch) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                fortniteBuildFloor_SelectedTouch = nil
                return true
            } else if (touch == fortniteBuildStair_SelectedTouch) {
                controllerSupport.updateLeftTrigger(controller, left: 0)
                fortniteBuildStair_SelectedTouch = nil
                return true
            } else if (touch == fortniteBuildEdit_ResetTouch) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                fortniteBuildEdit_ResetTouch = nil
                return true
            }
        } else if editMode {
            
        }
        
        //fortniteSwitch_To_BuildTouch

        return false
    }

    func handleTouchDownEvent(_ touch: UITouch, touchLocation: CGPoint, controller: Controller, controllerSupport: ControllerSupport) -> Bool {
        
        if combatMode {
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
            else if (fortniteShoot.presentation()?.hitTest(touchLocation) != nil) {
                controllerSupport.updateRightTrigger(controller, right: 0xFF)
                fortniteShootTouch = touch
                return true
            }
            // ...
            else if (fortniteShoot_Big.presentation()?.hitTest(touchLocation) != nil) {
                controllerSupport.updateRightTrigger(controller, right: 0xFF)
                fortniteShoot_BigTouch = touch
                return true
            }
            // ...
            else if (fortniteSwitch_To_Build.presentation()?.hitTest(touchLocation) != nil) {
                controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                fortniteSwitch_To_BuildTouch = touch
                hideHUDButtons(hideCombat: true, hideBuild: false, hideEdit: false)
                unhideHUDButtons(unhideCombat: false, unhideBuild: true, unhideEdit: false)
                return true
            }
            // ...
            else if (fortniteInventory.presentation()?.hitTest(touchLocation) != nil) {
                controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.UP_FLAG.rawValue);
                fortniteInventoryTouch = touch
                return true
            }
            // ...
            else if (fortnitePing.presentation()?.hitTest(touchLocation) != nil) {
                controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.LEFT_FLAG.rawValue);
                fortnitePingTouch = touch
                return true
            }
            // ...
            else if (fortniteEmote_Wheel.presentation()?.hitTest(touchLocation) != nil) {
                controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.DOWN_FLAG.rawValue);
                fortniteEmote_WheelTouch = touch
                return true
            }
            
        } else if buildMode {
            
            if (fortniteBuildSwitch_To_Combat.presentation()?.hitTest(touchLocation)) != nil {
                controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                hideHUDButtons(hideCombat: false, hideBuild: true, hideEdit: false)
                unhideHUDButtons(unhideCombat: true, unhideBuild: false, unhideEdit: false)
                fortniteBuildSwitch_To_CombatTouch = touch
            } else if (fortniteBuildPyramid_Selected.presentation()?.hitTest(touchLocation)) != nil {
                controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.LB_FLAG.rawValue);
                fortniteBuildPyramid_SelectedTouch = touch
            } else if (fortniteBuildWall_Selected.presentation()?.hitTest(touchLocation)) != nil {
                controllerSupport.updateRightTrigger(controller, right: 0xFF)
                fortniteBuildWall_SelectedTouch = touch
            } else if (fortniteBuildFloor_Selected.presentation()?.hitTest(touchLocation)) != nil {
                controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                fortniteBuildFloor_SelectedTouch = touch
            } else if (fortniteBuildStair_Selected.presentation()?.hitTest(touchLocation)) != nil {
                controllerSupport.updateLeftTrigger(controller, left: 0xFF)
                fortniteBuildStair_SelectedTouch = touch
            } else if (fortniteBuildEdit_Reset.presentation()?.hitTest(touchLocation)) != nil {
                controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.LEFT_FLAG.rawValue);
                hideHUDButtons(hideCombat: false, hideBuild: true, hideEdit: false)
                unhideHUDButtons(unhideCombat: false, unhideBuild: false, unhideEdit: true)
                fortniteBuildEdit_ResetTouch = touch
            }
            
            
        } else if editMode {
            
            
        }
        return false
    }

}
