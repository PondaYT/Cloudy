// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import UIKit

#if !APPSTORE

    class FortniteHUD: OscExtension {

        private var combatButtonLayers: [combatButtonType: CALayer] = [:]
        private var buildButtonLayers: [buildButtonType: CALayer] = [:]
        private var editButtonLayers: [editButtonType: CALayer] = [:]

        private var combatButtonLayerTouch: [combatButtonType: UITouch] = [:]
        private var buildButtonLayerTouch: [buildButtonType: UITouch] = [:]
        private var editButtonLayerTouch: [editButtonType: UITouch] = [:]

        let onScreenButtonsWhenActive   = VisibleButtons(leftStick: true)
        let onScreenButtonsWhenInactive = VisibleButtons.all

        var combatMode = true
        var buildMode  = false
        var editMode   = false

        var editFromCombat = true

        func leftStickClickEnabled() -> Bool {
            false
        }

        func rightStickClickEnabled() -> Bool {
            false
        }

        /// Draw all buttons
        func drawButtons(in layer: CALayer) {
            guard let HUDCombatButtonXSaved = UserDefaults.standard.array(forKey: savedHUDLayoutRects.combatHUDRectX) as? [CGFloat],
                  let HUDCombatButtonYSaved = UserDefaults.standard.array(forKey: savedHUDLayoutRects.combatHUDRectY) as? [CGFloat],
                  let HUDCombatButtonWidthSaved = UserDefaults.standard.array(forKey: savedHUDLayoutRects.combatHUDRectWidth) as? [CGFloat],
                  let HUDCombatButtonHeightSaved = UserDefaults.standard.array(forKey: savedHUDLayoutRects.combatHUDRectHeight) as? [CGFloat] else {
                return
            }
            
            
            guard let HUDBuildButtonXSaved = UserDefaults.standard.array(forKey: savedHUDLayoutRects.buildHUDRectX) as? [CGFloat],
                  let HUDBuildButtonYSaved = UserDefaults.standard.array(forKey: savedHUDLayoutRects.buildHUDRectY) as? [CGFloat],
                  let HUDBuildButtonWidthSaved = UserDefaults.standard.array(forKey: savedHUDLayoutRects.buildHUDRectWidth) as? [CGFloat],
                  let HUDBuildButtonHeightSaved = UserDefaults.standard.array(forKey: savedHUDLayoutRects.buildHUDRectHeight) as? [CGFloat] else {
                return
            }
            
            guard let HUDEditButtonXSaved = UserDefaults.standard.array(forKey: savedHUDLayoutRects.editHUDRectX) as? [CGFloat],
                  let HUDEditButtonYSaved = UserDefaults.standard.array(forKey: savedHUDLayoutRects.editHUDRectY) as? [CGFloat],
                  let HUDEditButtonWidthSaved = UserDefaults.standard.array(forKey: savedHUDLayoutRects.editHUDRectWidth) as? [CGFloat],
                  let HUDEditButtonHeightSaved = UserDefaults.standard.array(forKey: savedHUDLayoutRects.editHUDRectHeight) as? [CGFloat] else {
                return
            }
            
            
            var index = 0
            
            for type in combatButtonType.allCases {
                combatButtonLayers[type] = CALayer.init()
                let image = UIImage(named:type.rawValue.appending(".png"))
                combatButtonLayers[type]?.frame = CGRect.init(x: HUDCombatButtonXSaved[index], y: HUDCombatButtonYSaved[index], width: HUDCombatButtonWidthSaved[index], height: HUDCombatButtonHeightSaved[index])
                combatButtonLayers[type]?.contents = image?.cgImage
                layer.addSublayer(combatButtonLayers[type]!)
                index += 1
            }
            
            index = 0
            for type in buildButtonType.allCases {
                buildButtonLayers[type] = CALayer.init()
                let image = UIImage(named:type.rawValue.appending(".png"))
                buildButtonLayers[type]?.frame = CGRect.init(x: HUDBuildButtonXSaved[index], y: HUDBuildButtonYSaved[index], width: HUDBuildButtonWidthSaved[index], height: HUDBuildButtonHeightSaved[index])
                buildButtonLayers[type]?.contents = image?.cgImage
                layer.addSublayer(buildButtonLayers[type]!)
                index += 1
            }
            
            index = 0
            for type in editButtonType.allCases {
                editButtonLayers[type] = CALayer.init()
                let image = UIImage(named:type.rawValue.appending(".png"))
                editButtonLayers[type]?.frame = CGRect.init(x: HUDEditButtonXSaved[index], y: HUDEditButtonYSaved[index], width: HUDEditButtonWidthSaved[index], height: HUDEditButtonHeightSaved[index])
                editButtonLayers[type]?.contents = image?.cgImage
                layer.addSublayer(editButtonLayers[type]!)
                index += 1
            }

            for type in combatButtonType.allCases {
                combatButtonLayerTouch.updateValue(UITouch.init(), forKey: type)
            }
            
            for type in buildButtonType.allCases {
                buildButtonLayerTouch.updateValue(UITouch.init(), forKey: type)
            }
            
            for type in editButtonType.allCases {
                editButtonLayerTouch.updateValue(UITouch.init(), forKey: type)
            }
            
            hideHUDButtons(hideCombat: false, hideBuild: true, hideEdit: true)
        }

        func handleTouchMovedEvent(_ touch: UITouch) -> Bool {
            if combatMode {
                for type in combatButtonType.allCases {
                    if touch == combatButtonLayerTouch[type] {
                        return true
                    }
                }
            } else if buildMode {
                for type in buildButtonType.allCases {
                    if touch == buildButtonLayerTouch[type] {
                        return true
                    }
                }
            } else if editMode {
                for type in editButtonType.allCases {
                    if touch == editButtonLayerTouch[type] {
                        return true
                    }
                }
            }
            return false
        }

        func mixin(_ visible: Bool) -> VisibleButtons {
            if visible {
                unhideHUDButtons(unhideCombat: true, unhideBuild: false, unhideEdit: false)
                editMode = false
                buildMode = false
                combatMode = true
                return onScreenButtonsWhenActive
            } else {
                hideHUDButtons(hideCombat: true, hideBuild: true, hideEdit: true)
                editMode = false
                buildMode = false
                combatMode = true
                return onScreenButtonsWhenInactive
            }
        }

        func hideHUDButtons(hideCombat: Bool, hideBuild: Bool, hideEdit:Bool) {
            
            if hideCombat {
                for type in combatButtonType.allCases {
                    combatButtonLayers[type]?.isHidden = true
                }
            }
            
            if hideBuild {
                for type in buildButtonType.allCases {
                    buildButtonLayers[type]?.isHidden = true
                }
            }
            
            if hideEdit {
                for type in editButtonType.allCases {
                    editButtonLayers[type]?.isHidden = true
                }
            }
        }

        func unhideHUDButtons(unhideCombat: Bool, unhideBuild: Bool, unhideEdit:Bool) {
            
            if unhideCombat {
                for type in combatButtonType.allCases {
                    combatButtonLayers[type]?.isHidden = false
                }
            }
            
            if unhideBuild {
                for type in buildButtonType.allCases {
                    buildButtonLayers[type]?.isHidden = false
                }
            }
            
            if unhideEdit {
                for type in editButtonType.allCases {
                    editButtonLayers[type]?.isHidden = false
                }
            }
        }


        func handleTouchUpEvent(_ touch: UITouch, controller: Controller, controllerSupport: ControllerSupport) -> Bool {
            
            if combatMode {
                if (touch == combatButtonLayerTouch[combatButtonType.aim]) {
                    controllerSupport.updateLeftTrigger(controller, left: 0);
                    combatButtonLayerTouch[combatButtonType.aim] = nil
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.jump]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.A_FLAG.rawValue);
                    combatButtonLayerTouch[combatButtonType.jump] = nil
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.shoot]) {
                    controllerSupport.updateRightTrigger(controller, right: 0)
                    combatButtonLayerTouch[combatButtonType.shoot] = nil
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.shootBig]) {
                    controllerSupport.updateRightTrigger(controller, right: 0)
                    
                    combatButtonLayerTouch[combatButtonType.shootBig] = nil
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.switchToBuild]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                    
                    combatButtonLayerTouch[combatButtonType.switchToBuild] = nil
                    hideHUDButtons(hideCombat: true, hideBuild: false, hideEdit: false)
                    unhideHUDButtons(unhideCombat: false, unhideBuild: true, unhideEdit: false)
                    buildMode = true
                    combatMode = false
                    editFromCombat = false
                    
                    cleanCombatTouches(controller: controller, controllerSupport: controllerSupport)
                    
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.inventory]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.UP_FLAG.rawValue);
                    
                    combatButtonLayerTouch[combatButtonType.inventory] = nil
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.ping]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RS_CLK_FLAG.rawValue);
                    
                    combatButtonLayerTouch[combatButtonType.ping] = nil
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.emoteWheel]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.DOWN_FLAG.rawValue);
                    combatButtonLayerTouch[combatButtonType.emoteWheel] = nil
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.crouchDown]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LS_CLK_FLAG.rawValue);
                    combatButtonLayerTouch[combatButtonType.crouchDown] = nil
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.slotPickaxe]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.Y_FLAG.rawValue);
                    combatButtonLayerTouch[combatButtonType.slotPickaxe] = nil
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.editReset]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LEFT_FLAG.rawValue);
                    combatButtonLayerTouch[combatButtonType.editReset] = nil
                    hideHUDButtons(hideCombat: true, hideBuild: false, hideEdit: false)
                    unhideHUDButtons(unhideCombat: false, unhideBuild: false, unhideEdit: true)
                    buildMode = false
                    editMode = true
                    combatMode = false
                    editFromCombat = true
                    cleanCombatTouches(controller: controller, controllerSupport: controllerSupport)
                    
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.reload]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.X_FLAG.rawValue);
                    combatButtonLayerTouch[combatButtonType.reload] = nil
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.interact]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.X_FLAG.rawValue);
                    combatButtonLayerTouch[combatButtonType.interact] = nil
                    return true
                    
                } else if (touch == combatButtonLayerTouch[combatButtonType.pyramidSelected]) {
                    combatButtonLayerTouch[combatButtonType.pyramidSelected] = nil
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.wallSelected]) {
                    
                    combatButtonLayerTouch[combatButtonType.wallSelected] = nil
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.floorSelected]) {
                    
                    combatButtonLayerTouch[combatButtonType.floorSelected] = nil
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.stairSelected]) {
                    
                    combatButtonLayerTouch[combatButtonType.stairSelected] = nil
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.cycleWeaponsDown]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                    combatButtonLayerTouch[combatButtonType.cycleWeaponsDown] = nil
                    return true
                } else if (touch == combatButtonLayerTouch[combatButtonType.cycleWeaponsUp]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                    combatButtonLayerTouch[combatButtonType.cycleWeaponsUp] = nil
                    return true
                }
                
            } else if buildMode {
                if (touch == buildButtonLayerTouch[buildButtonType.switchToCombat]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.switchToCombat] = nil
                    hideHUDButtons(hideCombat: false, hideBuild: true, hideEdit: false)
                    unhideHUDButtons(unhideCombat: true, unhideBuild: false, unhideEdit: false)
                    buildMode = false
                    combatMode = true
                    editFromCombat = true
                    cleanBuildTouches(controller: controller, controllerSupport: controllerSupport)
                    return true
                } else if (touch == buildButtonLayerTouch[buildButtonType.pyramidSelected]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LB_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.pyramidSelected] = nil
                    return true
                } else if (touch == buildButtonLayerTouch[buildButtonType.wallSelected]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.UP_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.wallSelected] = nil
                    return true
                } else if (touch == buildButtonLayerTouch[buildButtonType.floorSelected]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.floorSelected] = nil
                    return true
                } else if (touch == buildButtonLayerTouch[buildButtonType.stairSelected]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.DOWN_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.stairSelected] = nil
                    return true
                } else if (touch == buildButtonLayerTouch[buildButtonType.editReset]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LEFT_FLAG.rawValue);
                    hideHUDButtons(hideCombat: false, hideBuild: true, hideEdit: false)
                    unhideHUDButtons(unhideCombat: false, unhideBuild: false, unhideEdit: true)
                    editMode = true
                    buildMode = false
                    combatMode = false
                    buildButtonLayerTouch[buildButtonType.editReset] = nil
                    return true
                } else if (touch == buildButtonLayerTouch[buildButtonType.jump]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.A_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.jump] = nil
                    return true
                } else if (touch == buildButtonLayerTouch[buildButtonType.shoot]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.shoot] = nil
                    return true
                } else if (touch == buildButtonLayerTouch[buildButtonType.shootBig]) {
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.shootBig] = nil
                    return true
                }
            } else if editMode {
                if (touch == editButtonLayerTouch[editButtonType.confirm]) {
                    editButtonLayerTouch[editButtonType.confirm] = nil
                    controllerSupport.updateLeftTrigger(controller, left: 0)
                    
                    if !editFromCombat {
                        hideHUDButtons(hideCombat: false, hideBuild: false, hideEdit: true)
                        unhideHUDButtons(unhideCombat: false, unhideBuild: true, unhideEdit: false)
                        editMode = false
                        buildMode = true
                        combatMode = false
                    } else {
                        hideHUDButtons(hideCombat: false, hideBuild: false, hideEdit: true)
                        unhideHUDButtons(unhideCombat: true, unhideBuild: false, unhideEdit: false)
                        editMode = false
                        buildMode = false
                        combatMode = true
                    }
                    
                    cleanEditTouches(controller: controller, controllerSupport: controllerSupport)
                    return true
                } else if (touch == editButtonLayerTouch[editButtonType.edit]) {
                    editButtonLayerTouch[editButtonType.edit] = nil
                    controllerSupport.updateRightTrigger(controller, right: 0)
                    return true
                } else if (touch == editButtonLayerTouch[editButtonType.ping]) {
                    editButtonLayerTouch[editButtonType.ping] = nil
                    return true
                } else if (touch == editButtonLayerTouch[editButtonType.reset]) {
                    editButtonLayerTouch[editButtonType.reset] = nil
                    controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                    return true
                } else if (touch == editButtonLayerTouch[editButtonType.rotate]) {
                    editButtonLayerTouch[editButtonType.rotate] = nil
                    return true
                } else if (touch == editButtonLayerTouch[editButtonType.shootBig]) {
                    editButtonLayerTouch[editButtonType.shootBig] = nil
                    return true
                } else if (touch == editButtonLayerTouch[editButtonType.shoot]) {
                    editButtonLayerTouch[editButtonType.shoot] = nil
                    return true
                } else if (touch == editButtonLayerTouch[editButtonType.switchToCombat]) {
                    editButtonLayerTouch[editButtonType.switchToCombat] = nil
                    return true
                }
            }
            return false
        }

        func handleTouchDownEvent(_ touch: UITouch, touchLocation: CGPoint, controller: Controller, controllerSupport: ControllerSupport) -> Bool {
            
            if combatMode {
                if (combatButtonLayers[combatButtonType.aim]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.updateLeftTrigger(controller, left: 0xFF)
                    combatButtonLayerTouch[combatButtonType.aim] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.jump]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.A_FLAG.rawValue);
                    combatButtonLayerTouch[combatButtonType.jump] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.shoot]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.updateRightTrigger(controller, right: 0xFF)
                    combatButtonLayerTouch[combatButtonType.shoot] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.shootBig]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.updateRightTrigger(controller, right: 0xFF)
                    combatButtonLayerTouch[combatButtonType.shootBig] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.switchToBuild]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                    combatButtonLayerTouch[combatButtonType.switchToBuild] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.inventory]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.UP_FLAG.rawValue);
                    combatButtonLayerTouch[combatButtonType.inventory] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.ping]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.RS_CLK_FLAG.rawValue)
                    combatButtonLayerTouch[combatButtonType.ping] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.emoteWheel]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.DOWN_FLAG.rawValue);
                    combatButtonLayerTouch[combatButtonType.emoteWheel] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.crouchDown]?.presentation()?.hitTest(touchLocation) != nil) {
                    //[_controllerSupport setButtonFlag:_controller flags:LS_CLK_FLAG];
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.LS_CLK_FLAG.rawValue)
                    combatButtonLayerTouch[combatButtonType.crouchDown] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.slotPickaxe]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.Y_FLAG.rawValue)
                    combatButtonLayerTouch[combatButtonType.slotPickaxe] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.reload]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.X_FLAG.rawValue)
                    combatButtonLayerTouch[combatButtonType.reload] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.interact]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.X_FLAG.rawValue)
                    combatButtonLayerTouch[combatButtonType.interact] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.editReset]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.LEFT_FLAG.rawValue)
                    combatButtonLayerTouch[combatButtonType.editReset] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.pyramidSelected]?.presentation()?.hitTest(touchLocation)) != nil {
                    
                    /*
                    let c1 = CloudyController()
                    c1.buttons[0] = .digital(true)
                    let c2 = CloudyController()
                    c2.buttons[0] = .digital(false)
                    controllerSupport.controllerDataReceiver.enqueue(controllerData: [c1,  c2], for: .onScreen)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        let c3 = CloudyController()
                        c3.buttons[1] = .digital(true)
                        let c4 = CloudyController()
                        c4.buttons[1] = .digital(false)
                        controllerSupport.controllerDataReceiver.enqueue(controllerData: [c3,  c4], for: .onScreen)
                    }
                    */
                    combatButtonLayerTouch[combatButtonType.pyramidSelected] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.wallSelected]?.presentation()?.hitTest(touchLocation)) != nil {
                    /*
                    let c1 = CloudyController()
                    c1.buttons[0] = .digital(true)
                    let c2 = CloudyController()
                    c2.buttons[0] = .digital(false)
                    controllerSupport.controllerDataReceiver.enqueue(controllerData: [c1,  c2], for: .onScreen)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        let c3 = CloudyController()
                        c3.buttons[1] = .digital(true)
                        let c4 = CloudyController()
                        c4.buttons[1] = .digital(false)
                        controllerSupport.controllerDataReceiver.enqueue(controllerData: [c3,  c4], for: .onScreen)
                    }
                    */
                    combatButtonLayerTouch[combatButtonType.wallSelected] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.floorSelected]?.presentation()?.hitTest(touchLocation)) != nil {
                    /*
                    let c1 = CloudyController()
                    c1.buttons[0] = .digital(true)
                    let c2 = CloudyController()
                    c2.buttons[0] = .digital(false)
                    controllerSupport.controllerDataReceiver.enqueue(controllerData: [c1,  c2], for: .onScreen)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        let c3 = CloudyController()
                        c3.buttons[1] = .digital(true)
                        let c4 = CloudyController()
                        c4.buttons[1] = .digital(false)
                        controllerSupport.controllerDataReceiver.enqueue(controllerData: [c3,  c4], for: .onScreen)
                    }
                    */
                    combatButtonLayerTouch[combatButtonType.floorSelected] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.stairSelected]?.presentation()?.hitTest(touchLocation)) != nil {
                    /*
                    let c1 = CloudyController()
                    c1.buttons[0] = .digital(true)
                    let c2 = CloudyController()
                    c2.buttons[0] = .digital(false)
                    controllerSupport.controllerDataReceiver.enqueue(controllerData: [c1,  c2], for: .onScreen)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        let c3 = CloudyController()
                        c3.buttons[1] = .digital(true)
                        let c4 = CloudyController()
                        c4.buttons[1] = .digital(false)
                        controllerSupport.controllerDataReceiver.enqueue(controllerData: [c3,  c4], for: .onScreen)
                    }
                    */
                    combatButtonLayerTouch[combatButtonType.stairSelected] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.cycleWeaponsDown]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue)
                    combatButtonLayerTouch[combatButtonType.cycleWeaponsDown] = touch
                    return true
                } else if (combatButtonLayers[combatButtonType.cycleWeaponsUp]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue)
                    combatButtonLayerTouch[combatButtonType.cycleWeaponsUp] = touch
                    return true
                }
                
            } else if buildMode {
                
                if (buildButtonLayers[buildButtonType.switchToCombat]?.presentation()?.hitTest(touchLocation)) != nil {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                        print("FLAG HERE")
                    buildButtonLayerTouch[buildButtonType.switchToCombat] = touch

                    return true
                } else if (buildButtonLayers[buildButtonType.pyramidSelected]?.presentation()?.hitTest(touchLocation)) != nil {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.LB_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.pyramidSelected] = touch
                    return true
                } else if (buildButtonLayers[buildButtonType.wallSelected]?.presentation()?.hitTest(touchLocation)) != nil {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.UP_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.wallSelected] = touch
                    return true
                } else if (buildButtonLayers[buildButtonType.floorSelected]?.presentation()?.hitTest(touchLocation)) != nil {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.floorSelected] = touch
                    return true
                } else if (buildButtonLayers[buildButtonType.stairSelected]?.presentation()?.hitTest(touchLocation)) != nil {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.DOWN_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.stairSelected] = touch
                    return true
                } else if (buildButtonLayers[buildButtonType.jump]?.presentation()?.hitTest(touchLocation)) != nil {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.A_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.jump] = touch
                    return true
                } else if (buildButtonLayers[buildButtonType.editReset]?.presentation()?.hitTest(touchLocation)) != nil {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.LEFT_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.editReset] = touch
                    return true
                } else if (buildButtonLayers[buildButtonType.shoot]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.shoot] = touch
                    return true
                } else if (buildButtonLayers[buildButtonType.shootBig]?.presentation()?.hitTest(touchLocation) != nil) {
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                    buildButtonLayerTouch[buildButtonType.shootBig] = touch
                    return true
                }
                
                
            } else if editMode {
                if (editButtonLayers[editButtonType.confirm]?.presentation()?.hitTest(touchLocation)) != nil {
                    editButtonLayerTouch[editButtonType.confirm] = touch
                    controllerSupport.updateLeftTrigger(controller, left: 0xFF)
                    return true
                } else if (editButtonLayers[editButtonType.edit]?.presentation()?.hitTest(touchLocation)) != nil {
                    editButtonLayerTouch[editButtonType.edit] = touch
                    controllerSupport.updateRightTrigger(controller, right: 0xFF)
                    return true
                } else if (editButtonLayers[editButtonType.ping]?.presentation()?.hitTest(touchLocation)) != nil {
                    editButtonLayerTouch[editButtonType.ping] = touch
                    return true
                } else if (editButtonLayers[editButtonType.reset]?.presentation()?.hitTest(touchLocation)) != nil {
                    editButtonLayerTouch[editButtonType.reset] = touch
                    controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                    return true
                } else if (editButtonLayers[editButtonType.rotate]?.presentation()?.hitTest(touchLocation)) != nil {
                    editButtonLayerTouch[editButtonType.rotate] = touch
                    return true
                } else if (editButtonLayers[editButtonType.shootBig]?.presentation()?.hitTest(touchLocation)) != nil {
                    editButtonLayerTouch[editButtonType.shootBig] = touch
                    return true
                } else if (editButtonLayers[editButtonType.shoot]?.presentation()?.hitTest(touchLocation)) != nil {
                    editButtonLayerTouch[editButtonType.shoot] = touch
                    return true
                } else if (editButtonLayers[editButtonType.switchToCombat]?.presentation()?.hitTest(touchLocation)) != nil {
                    editButtonLayerTouch[editButtonType.switchToCombat] = touch
                    return true
                }
            }
            return false
        }

        func cleanCombatTouches(controller:Controller, controllerSupport: ControllerSupport) {
            if (combatButtonLayerTouch[combatButtonType.aim] != nil) {
                controllerSupport.updateLeftTrigger(controller, left: 0);
                combatButtonLayerTouch[combatButtonType.aim] = nil
                
            } else if (combatButtonLayerTouch[combatButtonType.jump] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.A_FLAG.rawValue);
                combatButtonLayerTouch[combatButtonType.jump] = nil
                
            } else if (combatButtonLayerTouch[combatButtonType.shoot] != nil) {
                controllerSupport.updateRightTrigger(controller, right: 0)
                combatButtonLayerTouch[combatButtonType.shoot] = nil
                
            } else if (combatButtonLayerTouch[combatButtonType.shootBig] != nil) {
                controllerSupport.updateRightTrigger(controller, right: 0)
                
                combatButtonLayerTouch[combatButtonType.shootBig] = nil
                
            } else if (combatButtonLayerTouch[combatButtonType.switchToBuild] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                
                combatButtonLayerTouch[combatButtonType.switchToBuild] = nil
                hideHUDButtons(hideCombat: true, hideBuild: false, hideEdit: false)
                unhideHUDButtons(unhideCombat: false, unhideBuild: true, unhideEdit: false)
                buildMode = true
                combatMode = false
                editFromCombat = false
                
                print("BUILD")
                
                
            } else if (combatButtonLayerTouch[combatButtonType.inventory] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.UP_FLAG.rawValue);
                
                combatButtonLayerTouch[combatButtonType.inventory] = nil
                
            } else if (combatButtonLayerTouch[combatButtonType.ping] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RS_CLK_FLAG.rawValue);
                
                combatButtonLayerTouch[combatButtonType.ping] = nil
                
            } else if (combatButtonLayerTouch[combatButtonType.emoteWheel] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.DOWN_FLAG.rawValue);
                combatButtonLayerTouch[combatButtonType.emoteWheel] = nil
                
            } else if (combatButtonLayerTouch[combatButtonType.crouchDown] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LS_CLK_FLAG.rawValue);
                combatButtonLayerTouch[combatButtonType.crouchDown] = nil
                
            } else if (combatButtonLayerTouch[combatButtonType.slotPickaxe] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.Y_FLAG.rawValue);
                combatButtonLayerTouch[combatButtonType.slotPickaxe] = nil
                
            } else if (combatButtonLayerTouch[combatButtonType.editReset] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LEFT_FLAG.rawValue);
                combatButtonLayerTouch[combatButtonType.editReset] = nil
                hideHUDButtons(hideCombat: true, hideBuild: false, hideEdit: false)
                unhideHUDButtons(unhideCombat: false, unhideBuild: false, unhideEdit: true)
                buildMode = false
                editMode = true
                combatMode = false
                editFromCombat = true
                
                
            } else if (combatButtonLayerTouch[combatButtonType.reload] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.X_FLAG.rawValue);
                combatButtonLayerTouch[combatButtonType.reload] = nil
                
            } else if (combatButtonLayerTouch[combatButtonType.interact] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.X_FLAG.rawValue);
                combatButtonLayerTouch[combatButtonType.interact] = nil
                
                
            } else if (combatButtonLayerTouch[combatButtonType.pyramidSelected] != nil) {
                combatButtonLayerTouch[combatButtonType.pyramidSelected] = nil
                
            } else if (combatButtonLayerTouch[combatButtonType.wallSelected] != nil) {
                
                combatButtonLayerTouch[combatButtonType.wallSelected] = nil
                
            } else if (combatButtonLayerTouch[combatButtonType.floorSelected] != nil) {
                
                combatButtonLayerTouch[combatButtonType.floorSelected] = nil
                
            } else if (combatButtonLayerTouch[combatButtonType.stairSelected] != nil) {
                
                combatButtonLayerTouch[combatButtonType.stairSelected] = nil
                
            } else if (combatButtonLayerTouch[combatButtonType.cycleWeaponsDown] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                combatButtonLayerTouch[combatButtonType.cycleWeaponsDown] = nil
                
            } else if (combatButtonLayerTouch[combatButtonType.cycleWeaponsUp] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                combatButtonLayerTouch[combatButtonType.cycleWeaponsUp] = nil
            }
        }


        func cleanBuildTouches(controller: Controller, controllerSupport: ControllerSupport) {
            
            if (buildButtonLayerTouch[buildButtonType.switchToCombat] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                buildButtonLayerTouch[buildButtonType.switchToCombat] = nil
            } else if (buildButtonLayerTouch[buildButtonType.pyramidSelected] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LB_FLAG.rawValue);
                buildButtonLayerTouch[buildButtonType.pyramidSelected] = nil
                
            } else if (buildButtonLayerTouch[buildButtonType.wallSelected] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.UP_FLAG.rawValue);
                buildButtonLayerTouch[buildButtonType.wallSelected] = nil
                
            } else if (buildButtonLayerTouch[buildButtonType.floorSelected] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                buildButtonLayerTouch[buildButtonType.floorSelected] = nil
                
            } else if (buildButtonLayerTouch[buildButtonType.stairSelected] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.DOWN_FLAG.rawValue);
                buildButtonLayerTouch[buildButtonType.stairSelected] = nil
                
            } else if (buildButtonLayerTouch[buildButtonType.editReset] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LEFT_FLAG.rawValue);
                buildButtonLayerTouch[buildButtonType.editReset] = nil
                
            } else if (buildButtonLayerTouch[buildButtonType.jump] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.A_FLAG.rawValue);
                buildButtonLayerTouch[buildButtonType.jump] = nil
                
            } else if (buildButtonLayerTouch[buildButtonType.shoot] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                buildButtonLayerTouch[buildButtonType.shoot] = nil
                
            } else if (buildButtonLayerTouch[buildButtonType.shootBig] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                buildButtonLayerTouch[buildButtonType.shootBig] = nil
            }
        }

        func cleanEditTouches(controller: Controller, controllerSupport: ControllerSupport) {
            
            if (editButtonLayerTouch[editButtonType.confirm] != nil) {
                editButtonLayerTouch[editButtonType.confirm] = nil
                controllerSupport.updateLeftTrigger(controller, left: 0)
                
                if !editFromCombat {
                    hideHUDButtons(hideCombat: false, hideBuild: false, hideEdit: true)
                    unhideHUDButtons(unhideCombat: false, unhideBuild: true, unhideEdit: false)
                    editMode = false
                    buildMode = true
                    combatMode = false
                } else {
                    hideHUDButtons(hideCombat: false, hideBuild: false, hideEdit: true)
                    unhideHUDButtons(unhideCombat: true, unhideBuild: false, unhideEdit: false)
                    editMode = false
                    buildMode = false
                    combatMode = true
                }
            } else if (editButtonLayerTouch[editButtonType.edit] != nil) {
                editButtonLayerTouch[editButtonType.edit] = nil
                controllerSupport.updateRightTrigger(controller, right: 0)
            } else if (editButtonLayerTouch[editButtonType.ping] != nil) {
                editButtonLayerTouch[editButtonType.ping] = nil
            } else if (editButtonLayerTouch[editButtonType.reset] != nil) {
                editButtonLayerTouch[editButtonType.reset] = nil
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
            } else if (editButtonLayerTouch[editButtonType.rotate] != nil) {
                editButtonLayerTouch[editButtonType.rotate] = nil
            } else if (editButtonLayerTouch[editButtonType.shootBig] != nil) {
                editButtonLayerTouch[editButtonType.shootBig] = nil
            } else if (editButtonLayerTouch[editButtonType.shoot] != nil) {
                editButtonLayerTouch[editButtonType.shoot] = nil
            } else if (editButtonLayerTouch[editButtonType.switchToCombat] != nil) {
                editButtonLayerTouch[editButtonType.switchToCombat] = nil
            }
        }
    }

#endif
