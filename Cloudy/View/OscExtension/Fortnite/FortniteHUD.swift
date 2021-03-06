// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import UIKit

#if !APPSTORE

    /// Main On Screen Controls extension for the fortnite hud
    class FortniteHUD: OscExtension {

        /// The different modes for the fortnite hud
        enum Mode {
            case combat
            case build
            case editFromCombat // indicates that editing was initiated from combat
            case editFromBuild  // indicates that editing was initiated from building
        }

        /// Relevant layers
        private let rootLayer:              CALayer                                          = CALayer()
        private var combatButtonLayers:     [FortniteButtonType.Combat: AlphaTestingCALayer] = [:]
        private var buildButtonLayers:      [FortniteButtonType.Build: AlphaTestingCALayer]  = [:]
        private var editButtonLayers:       [FortniteButtonType.Edit: AlphaTestingCALayer]   = [:]

        /// Relevant touches
        private var combatButtonLayerTouch: [FortniteButtonType.Combat: UITouch]             = [:]
        private var buildButtonLayerTouch:  [FortniteButtonType.Build: UITouch]              = [:]
        private var editButtonLayerTouch:   [FortniteButtonType.Edit: UITouch]               = [:]

        /// Predefined regular controller buttons to show when this hud is active / inactive
        private let onScreenButtonsWhenActive                                                = VisibleButtons(leftStick: true)
        private let onScreenButtonsWhenInactive                                              = VisibleButtons.all

        /// The active hud mode
        private var currentMode:            Mode?                                            = .none

        /// Left stick clicking disabled in this extension
        func leftStickClickEnabled() -> Bool {
            false
        }

        /// Right stick clicking disabled in this extension
        func rightStickClickEnabled() -> Bool {
            false
        }

        /// Construction
        init() {
            FortniteButtonType.Combat.allCases.forEach { type in
                combatButtonLayers[type] = AlphaTestingCALayer()
                let image = UIImage(named: type.rawValue.appending(".png"))
                combatButtonLayers[type]?.contents = image?.cgImage
                rootLayer.addSublayer(combatButtonLayers[type]!)
            }
            FortniteButtonType.Build.allCases.forEach { type in
                buildButtonLayers[type] = AlphaTestingCALayer()
                let image = UIImage(named: type.rawValue.appending(".png"))
                buildButtonLayers[type]?.contents = image?.cgImage
                rootLayer.addSublayer(buildButtonLayers[type]!)
            }
            FortniteButtonType.Edit.allCases.forEach { type in
                editButtonLayers[type] = AlphaTestingCALayer()
                let image = UIImage(named: type.rawValue.appending(".png"))
                editButtonLayers[type]?.contents = image?.cgImage
                rootLayer.addSublayer(editButtonLayers[type]!)
            }
        }

        /// Initialize the hud sublayers
        func initialize(in layer: CALayer) {
            layer.addSublayer(rootLayer)
            setMode(.none)
        }

        /// Draw all buttons
        func drawButtons() {
            // get saved positions
            guard let hudCombatButtonXSaved = UserDefaults.standard.array(forKey: FortniteHUDPositionKeys.combatHUDRectX) as? [CGFloat],
                  let hudCombatButtonYSaved = UserDefaults.standard.array(forKey: FortniteHUDPositionKeys.combatHUDRectY) as? [CGFloat],
                  let hudCombatButtonWidthSaved = UserDefaults.standard.array(forKey: FortniteHUDPositionKeys.combatHUDRectWidth) as? [CGFloat],
                  let hudCombatButtonHeightSaved = UserDefaults.standard.array(forKey: FortniteHUDPositionKeys.combatHUDRectHeight) as? [CGFloat] else {
                return
            }
            guard let hudBuildButtonXSaved = UserDefaults.standard.array(forKey: FortniteHUDPositionKeys.buildHUDRectX) as? [CGFloat],
                  let hudBuildButtonYSaved = UserDefaults.standard.array(forKey: FortniteHUDPositionKeys.buildHUDRectY) as? [CGFloat],
                  let hudBuildButtonWidthSaved = UserDefaults.standard.array(forKey: FortniteHUDPositionKeys.buildHUDRectWidth) as? [CGFloat],
                  let hudBuildButtonHeightSaved = UserDefaults.standard.array(forKey: FortniteHUDPositionKeys.buildHUDRectHeight) as? [CGFloat] else {
                return
            }
            guard let hudEditButtonXSaved = UserDefaults.standard.array(forKey: FortniteHUDPositionKeys.editHUDRectX) as? [CGFloat],
                  let hudEditButtonYSaved = UserDefaults.standard.array(forKey: FortniteHUDPositionKeys.editHUDRectY) as? [CGFloat],
                  let hudEditButtonWidthSaved = UserDefaults.standard.array(forKey: FortniteHUDPositionKeys.editHUDRectWidth) as? [CGFloat],
                  let hudEditButtonHeightSaved = UserDefaults.standard.array(forKey: FortniteHUDPositionKeys.editHUDRectHeight) as? [CGFloat] else {
                return
            }
            // update positions
            FortniteButtonType.Combat.allCases.enumerated().forEach { (index, type) in
                if (index < hudCombatButtonXSaved.count) {
                    print(type.rawValue)
                    combatButtonLayers[type]?.frame = CGRect(x: hudCombatButtonXSaved[index],
                                                             y: hudCombatButtonYSaved[index],
                                                             width: hudCombatButtonWidthSaved[index],
                                                             height: hudCombatButtonHeightSaved[index])
                }
            }
            FortniteButtonType.Build.allCases.enumerated().forEach { (index, type) in
                if (index < hudBuildButtonXSaved.count) {
                    print(type.rawValue)
                    buildButtonLayers[type]?.frame = CGRect(x: hudBuildButtonXSaved[index],
                                                            y: hudBuildButtonYSaved[index],
                                                            width: hudBuildButtonWidthSaved[index],
                                                            height: hudBuildButtonHeightSaved[index])
                }
            }
            FortniteButtonType.Edit.allCases.enumerated().forEach { (index, type) in
                if (index < hudEditButtonXSaved.count) {
                    print(type.rawValue)
                    editButtonLayers[type]?.frame = CGRect(x: hudEditButtonXSaved[index],
                                                           y: hudEditButtonYSaved[index],
                                                           width: hudEditButtonWidthSaved[index],
                                                           height: hudEditButtonHeightSaved[index])
                }
            }
            // initialize touches
            for type in FortniteButtonType.Combat.allCases {
                combatButtonLayerTouch.updateValue(UITouch(), forKey: type)
            }
            for type in FortniteButtonType.Build.allCases {
                buildButtonLayerTouch.updateValue(UITouch(), forKey: type)
            }
            for type in FortniteButtonType.Edit.allCases {
                editButtonLayerTouch.updateValue(UITouch(), forKey: type)
            }
        }

        /// Visibility mixin.
        func mixin(_ visible: Bool) -> VisibleButtons {
            if visible {
                setMode(.combat)
                return onScreenButtonsWhenActive
            } else {
                setMode(.none)
                return onScreenButtonsWhenInactive
            }
        }

        /// Handle touch moving
        /// return true if this touch was already saved somewhere
        func handleTouchMovedEvent(_ touch: UITouch) -> TouchResult {
            if combatButtonLayerTouch.first(where: { $0 == .shootBig && $1 == touch }) != nil ||
               buildButtonLayerTouch.first(where: { $0 == .shootBig && $1 == touch }) != nil ||
               editButtonLayerTouch.first(where: { $0 == .shootBig && $1 == touch }) != nil {
                return .handledPlusRightStick
            }
            if combatButtonLayerTouch.first(where: { $1 == touch }) != nil ||
               buildButtonLayerTouch.first(where: { $1 == touch }) != nil ||
               editButtonLayerTouch.first(where: { $1 == touch }) != nil {
                return .handledNoMovement
            }
            return .unhandled
        }

        /// Handle touch down events
        func handleTouchDownEvent(_ touch: UITouch, touchLocation: CGPoint, controller: Controller, controllerSupport: ControllerSupport) -> TouchResult {
            switch currentMode {
                case .combat:
                    
                    
                     if (combatButtonLayers[FortniteButtonType.Combat.map]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.BACK_FLAG.rawValue);
                         combatButtonLayerTouch[FortniteButtonType.Combat.map] = touch
                         return .handledNoMovement
                     }
                     
                    if (combatButtonLayers[FortniteButtonType.Combat.aim]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.updateLeftTrigger(controller, left: 0xFF)
                        combatButtonLayerTouch[FortniteButtonType.Combat.aim] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.jump]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.A_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.jump] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.shoot]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.updateRightTrigger(controller, right: 0xFF)
                        combatButtonLayerTouch[FortniteButtonType.Combat.shoot] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.shootBig]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.updateRightTrigger(controller, right: 0xFF)
                        combatButtonLayerTouch[FortniteButtonType.Combat.shootBig] = touch
                        return .handledPlusRightStick
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.switchToBuild]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.switchToBuild] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.inventory]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.UP_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.inventory] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.ping]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.RS_CLK_FLAG.rawValue)
                        combatButtonLayerTouch[FortniteButtonType.Combat.ping] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.emoteWheel]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.DOWN_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.emoteWheel] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.crouchDown]?.presentation()?.hitTest(touchLocation) != nil) {
                        //[_controllerSupport setButtonFlag:_controller flags:LS_CLK_FLAG];
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.LS_CLK_FLAG.rawValue)
                        combatButtonLayerTouch[FortniteButtonType.Combat.crouchDown] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.slotPickaxe]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.Y_FLAG.rawValue)
                        combatButtonLayerTouch[FortniteButtonType.Combat.slotPickaxe] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.reload]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.X_FLAG.rawValue)
                        combatButtonLayerTouch[FortniteButtonType.Combat.reload] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.interact]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.X_FLAG.rawValue)
                        combatButtonLayerTouch[FortniteButtonType.Combat.interact] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.edit]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.LEFT_FLAG.rawValue)
                        combatButtonLayerTouch[FortniteButtonType.Combat.edit] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.pyramidSelected]?.presentation()?.hitTest(touchLocation)) != nil {
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
                        combatButtonLayerTouch[FortniteButtonType.Combat.pyramidSelected] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.wallSelected]?.presentation()?.hitTest(touchLocation)) != nil {
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
                        combatButtonLayerTouch[FortniteButtonType.Combat.wallSelected] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.floorSelected]?.presentation()?.hitTest(touchLocation)) != nil {
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
                        combatButtonLayerTouch[FortniteButtonType.Combat.floorSelected] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.stairSelected]?.presentation()?.hitTest(touchLocation)) != nil {
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
                        combatButtonLayerTouch[FortniteButtonType.Combat.stairSelected] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.cycleWeaponsDown]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue)
                        combatButtonLayerTouch[FortniteButtonType.Combat.cycleWeaponsDown] = touch
                        return .handledNoMovement
                    }

                    if (combatButtonLayers[FortniteButtonType.Combat.cycleWeaponsUp]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue)
                        combatButtonLayerTouch[FortniteButtonType.Combat.cycleWeaponsUp] = touch
                        return .handledNoMovement
                    }

                case .build:
                    
                    if (buildButtonLayers[FortniteButtonType.Build.trapSelected]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.updateLeftTrigger(controller, left: 0xFF)
                        buildButtonLayerTouch[FortniteButtonType.Build.trapSelected] = touch
                        return .handledNoMovement
                    }
                    
                    if (buildButtonLayers[FortniteButtonType.Build.switchToCombat]?.presentation()?.hitTest(touchLocation)) != nil {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                        print("FLAG HERE")
                        buildButtonLayerTouch[FortniteButtonType.Build.switchToCombat] = touch
                        return .handledNoMovement
                    }

                    if (buildButtonLayers[FortniteButtonType.Build.pyramidSelected]?.presentation()?.hitTest(touchLocation)) != nil {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.LB_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.pyramidSelected] = touch
                        return .handledNoMovement
                    }
                    
                    if (buildButtonLayers[FortniteButtonType.Build.changeMaterials]?.presentation()?.hitTest(touchLocation)) != nil {
                        controllerSupport.updateRightTrigger(controller, right: 0xFF)
                        buildButtonLayerTouch[FortniteButtonType.Build.changeMaterials] = touch
                        return .handledNoMovement
                    }

                    if (buildButtonLayers[FortniteButtonType.Build.wallSelected]?.presentation()?.hitTest(touchLocation)) != nil {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.UP_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.wallSelected] = touch
                        return .handledNoMovement
                    }

                    if (buildButtonLayers[FortniteButtonType.Build.floorSelected]?.presentation()?.hitTest(touchLocation)) != nil {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.floorSelected] = touch
                        return .handledNoMovement
                    }

                    if (buildButtonLayers[FortniteButtonType.Build.stairSelected]?.presentation()?.hitTest(touchLocation)) != nil {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.DOWN_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.stairSelected] = touch
                        return .handledNoMovement
                    }

                    if (buildButtonLayers[FortniteButtonType.Build.jump]?.presentation()?.hitTest(touchLocation)) != nil {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.A_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.jump] = touch
                        return .handledNoMovement
                    }

                    if (buildButtonLayers[FortniteButtonType.Build.edit]?.presentation()?.hitTest(touchLocation)) != nil {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.LEFT_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.edit] = touch
                        return .handledNoMovement
                    }

                    if (buildButtonLayers[FortniteButtonType.Build.shoot]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.shoot] = touch
                        return .handledNoMovement
                    }

                    if (buildButtonLayers[FortniteButtonType.Build.shootBig]?.presentation()?.hitTest(touchLocation) != nil) {
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.shootBig] = touch
                        return .handledPlusRightStick
                    }

                case .editFromCombat, .editFromBuild:
                    if (editButtonLayers[FortniteButtonType.Edit.confirm]?.presentation()?.hitTest(touchLocation)) != nil {
                        editButtonLayerTouch[FortniteButtonType.Edit.confirm] = touch
                        controllerSupport.updateLeftTrigger(controller, left: 0xFF)
                        return .handledNoMovement
                    }

                    if (editButtonLayers[FortniteButtonType.Edit.edit]?.presentation()?.hitTest(touchLocation)) != nil {
                        editButtonLayerTouch[FortniteButtonType.Edit.edit] = touch
                        controllerSupport.updateRightTrigger(controller, right: 0xFF)
                        return .handledNoMovement
                    }

                    if (editButtonLayers[FortniteButtonType.Edit.ping]?.presentation()?.hitTest(touchLocation)) != nil {
                        editButtonLayerTouch[FortniteButtonType.Edit.ping] = touch
                        return .handledNoMovement
                    }

                    if (editButtonLayers[FortniteButtonType.Edit.reset]?.presentation()?.hitTest(touchLocation)) != nil {
                        editButtonLayerTouch[FortniteButtonType.Edit.reset] = touch
                        controllerSupport.setButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                        return .handledNoMovement
                    }

                    if (editButtonLayers[FortniteButtonType.Edit.rotate]?.presentation()?.hitTest(touchLocation)) != nil {
                        editButtonLayerTouch[FortniteButtonType.Edit.rotate] = touch
                        return .handledNoMovement
                    }

                    if (editButtonLayers[FortniteButtonType.Edit.shootBig]?.presentation()?.hitTest(touchLocation)) != nil {
                        editButtonLayerTouch[FortniteButtonType.Edit.shootBig] = touch
                        return .handledPlusRightStick
                    }

                    if (editButtonLayers[FortniteButtonType.Edit.shoot]?.presentation()?.hitTest(touchLocation)) != nil {
                        editButtonLayerTouch[FortniteButtonType.Edit.shoot] = touch
                        return .handledNoMovement
                    }

                    if (editButtonLayers[FortniteButtonType.Edit.switchToCombat]?.presentation()?.hitTest(touchLocation)) != nil {
                        editButtonLayerTouch[FortniteButtonType.Edit.switchToCombat] = touch
                        return .handledNoMovement
                    }
                default:
                    break
            }
            return .unhandled
        }

        /// Handle touch up events
        func handleTouchUpEvent(_ touch: UITouch, controller: Controller, controllerSupport: ControllerSupport) -> TouchResult {
            switch currentMode {
                case .combat:
                    
                    
                     if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.map]) {
                         controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.BACK_FLAG.rawValue);
                         combatButtonLayerTouch[FortniteButtonType.Combat.map] = nil
                         return .handledNoMovement
                     }
                     
                    
                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.aim]) {
                        controllerSupport.updateLeftTrigger(controller, left: 0);
                        combatButtonLayerTouch[FortniteButtonType.Combat.aim] = nil
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.jump]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.A_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.jump] = nil
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.shoot]) {
                        controllerSupport.updateRightTrigger(controller, right: 0)
                        combatButtonLayerTouch[FortniteButtonType.Combat.shoot] = nil
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.shootBig]) {
                        controllerSupport.updateRightTrigger(controller, right: 0)
                        combatButtonLayerTouch[FortniteButtonType.Combat.shootBig] = nil
                        return .handledPlusRightStick
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.switchToBuild]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.switchToBuild] = nil
                        setMode(.build)
                        cleanCombatTouches(controller: controller, controllerSupport: controllerSupport)
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.inventory]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.UP_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.inventory] = nil
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.ping]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RS_CLK_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.ping] = nil
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.emoteWheel]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.DOWN_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.emoteWheel] = nil
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.crouchDown]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LS_CLK_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.crouchDown] = nil
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.slotPickaxe]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.Y_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.slotPickaxe] = nil
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.edit]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LEFT_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.edit] = nil
                        setMode(.editFromCombat)
                        cleanCombatTouches(controller: controller, controllerSupport: controllerSupport)
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.reload]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.X_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.reload] = nil
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.interact]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.X_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.interact] = nil
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.pyramidSelected]) {
                        combatButtonLayerTouch[FortniteButtonType.Combat.pyramidSelected] = nil
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.wallSelected]) {
                        combatButtonLayerTouch[FortniteButtonType.Combat.wallSelected] = nil
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.floorSelected]) {
                        combatButtonLayerTouch[FortniteButtonType.Combat.floorSelected] = nil
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.stairSelected]) {
                        combatButtonLayerTouch[FortniteButtonType.Combat.stairSelected] = nil
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.cycleWeaponsDown]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.cycleWeaponsDown] = nil
                        return .handledNoMovement
                    }

                    if (touch == combatButtonLayerTouch[FortniteButtonType.Combat.cycleWeaponsUp]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                        combatButtonLayerTouch[FortniteButtonType.Combat.cycleWeaponsUp] = nil
                        return .handledNoMovement
                    }

                case .build:
                    
                    if (touch == buildButtonLayerTouch[FortniteButtonType.Build.trapSelected]) {
                        controllerSupport.updateLeftTrigger(controller, left: 0);
                        buildButtonLayerTouch[FortniteButtonType.Build.trapSelected] = nil
                        return .handledNoMovement
                    }
                    
                    if (touch == buildButtonLayerTouch[FortniteButtonType.Build.switchToCombat]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.switchToCombat] = nil
                        setMode(.combat)
                        cleanBuildTouches(controller: controller, controllerSupport: controllerSupport)
                        return .handledNoMovement
                    }

                    if (touch == buildButtonLayerTouch[FortniteButtonType.Build.pyramidSelected]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LB_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.pyramidSelected] = nil
                        return .handledNoMovement
                    }
                    
                    if (touch == buildButtonLayerTouch[FortniteButtonType.Build.changeMaterials]) {
                        controllerSupport.updateRightTrigger(controller, right: 0)
                        buildButtonLayerTouch[FortniteButtonType.Build.changeMaterials] = nil
                        return .handledNoMovement
                    }

                    if (touch == buildButtonLayerTouch[FortniteButtonType.Build.wallSelected]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.UP_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.wallSelected] = nil
                        return .handledNoMovement
                    }

                    if (touch == buildButtonLayerTouch[FortniteButtonType.Build.floorSelected]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.floorSelected] = nil
                        return .handledNoMovement
                    }

                    if (touch == buildButtonLayerTouch[FortniteButtonType.Build.stairSelected]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.DOWN_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.stairSelected] = nil
                        return .handledNoMovement
                    }

                    if (touch == buildButtonLayerTouch[FortniteButtonType.Build.edit]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LEFT_FLAG.rawValue);
                        setMode(.editFromBuild)
                        buildButtonLayerTouch[FortniteButtonType.Build.edit] = nil
                        return .handledNoMovement
                    }

                    if (touch == buildButtonLayerTouch[FortniteButtonType.Build.jump]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.A_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.jump] = nil
                        return .handledNoMovement
                    }

                    if (touch == buildButtonLayerTouch[FortniteButtonType.Build.shoot]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.shoot] = nil
                        return .handledNoMovement
                    }

                    if (touch == buildButtonLayerTouch[FortniteButtonType.Build.shootBig]) {
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                        buildButtonLayerTouch[FortniteButtonType.Build.shootBig] = nil
                        return .handledPlusRightStick
                    }

                case .editFromCombat, .editFromBuild:
                    if (touch == editButtonLayerTouch[FortniteButtonType.Edit.confirm]) {
                        editButtonLayerTouch[FortniteButtonType.Edit.confirm] = nil
                        controllerSupport.updateLeftTrigger(controller, left: 0)
                        if currentMode == .editFromBuild {
                            setMode(.build)
                        } else {
                            setMode(.combat)
                        }
                        cleanEditTouches(controller: controller, controllerSupport: controllerSupport)
                        return .handledNoMovement
                    }

                    if (touch == editButtonLayerTouch[FortniteButtonType.Edit.edit]) {
                        editButtonLayerTouch[FortniteButtonType.Edit.edit] = nil
                        controllerSupport.updateRightTrigger(controller, right: 0)
                        return .handledNoMovement
                    }

                    if (touch == editButtonLayerTouch[FortniteButtonType.Edit.ping]) {
                        editButtonLayerTouch[FortniteButtonType.Edit.ping] = nil
                        return .handledNoMovement
                    }

                    if (touch == editButtonLayerTouch[FortniteButtonType.Edit.reset]) {
                        editButtonLayerTouch[FortniteButtonType.Edit.reset] = nil
                        controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                        return .handledNoMovement
                    }

                    if (touch == editButtonLayerTouch[FortniteButtonType.Edit.rotate]) {
                        editButtonLayerTouch[FortniteButtonType.Edit.rotate] = nil
                        return .handledNoMovement
                    }

                    if (touch == editButtonLayerTouch[FortniteButtonType.Edit.shootBig]) {
                        editButtonLayerTouch[FortniteButtonType.Edit.shootBig] = nil
                        return .handledPlusRightStick
                    }

                    if (touch == editButtonLayerTouch[FortniteButtonType.Edit.shoot]) {
                        editButtonLayerTouch[FortniteButtonType.Edit.shoot] = nil
                        return .handledNoMovement
                    }

                    if (touch == editButtonLayerTouch[FortniteButtonType.Edit.switchToCombat]) {
                        editButtonLayerTouch[FortniteButtonType.Edit.switchToCombat] = nil
                        return .handledNoMovement
                    }
                default:
                    break
            }
            return .unhandled
        }

        /// Clean touch events for combat mode and react correspondingly
        private func cleanCombatTouches(controller: Controller, controllerSupport: ControllerSupport) {
            
            
            if (combatButtonLayerTouch[FortniteButtonType.Combat.aim] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.BACK_FLAG.rawValue);
                combatButtonLayerTouch[FortniteButtonType.Combat.map] = nil
            }
            
            if (combatButtonLayerTouch[FortniteButtonType.Combat.aim] != nil) {
                controllerSupport.updateLeftTrigger(controller, left: 0);
                combatButtonLayerTouch[FortniteButtonType.Combat.aim] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.jump] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.A_FLAG.rawValue);
                combatButtonLayerTouch[FortniteButtonType.Combat.jump] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.shoot] != nil) {
                controllerSupport.updateRightTrigger(controller, right: 0)
                combatButtonLayerTouch[FortniteButtonType.Combat.shoot] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.shootBig] != nil) {
                controllerSupport.updateRightTrigger(controller, right: 0)
                combatButtonLayerTouch[FortniteButtonType.Combat.shootBig] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.switchToBuild] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                combatButtonLayerTouch[FortniteButtonType.Combat.switchToBuild] = nil
                setMode(.build)

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.inventory] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.UP_FLAG.rawValue);
                combatButtonLayerTouch[FortniteButtonType.Combat.inventory] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.ping] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RS_CLK_FLAG.rawValue);
                combatButtonLayerTouch[FortniteButtonType.Combat.ping] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.emoteWheel] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.DOWN_FLAG.rawValue);
                combatButtonLayerTouch[FortniteButtonType.Combat.emoteWheel] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.crouchDown] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LS_CLK_FLAG.rawValue);
                combatButtonLayerTouch[FortniteButtonType.Combat.crouchDown] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.slotPickaxe] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.Y_FLAG.rawValue);
                combatButtonLayerTouch[FortniteButtonType.Combat.slotPickaxe] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.edit] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LEFT_FLAG.rawValue);
                combatButtonLayerTouch[FortniteButtonType.Combat.edit] = nil
                setMode(.editFromCombat)

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.reload] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.X_FLAG.rawValue);
                combatButtonLayerTouch[FortniteButtonType.Combat.reload] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.interact] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.X_FLAG.rawValue);
                combatButtonLayerTouch[FortniteButtonType.Combat.interact] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.pyramidSelected] != nil) {
                combatButtonLayerTouch[FortniteButtonType.Combat.pyramidSelected] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.wallSelected] != nil) {
                combatButtonLayerTouch[FortniteButtonType.Combat.wallSelected] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.floorSelected] != nil) {
                combatButtonLayerTouch[FortniteButtonType.Combat.floorSelected] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.stairSelected] != nil) {
                combatButtonLayerTouch[FortniteButtonType.Combat.stairSelected] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.cycleWeaponsDown] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                combatButtonLayerTouch[FortniteButtonType.Combat.cycleWeaponsDown] = nil

            } else if (combatButtonLayerTouch[FortniteButtonType.Combat.cycleWeaponsUp] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                combatButtonLayerTouch[FortniteButtonType.Combat.cycleWeaponsUp] = nil
            }
        }

        /// Clean touch events for build mode and react correspondingly
        private func cleanBuildTouches(controller: Controller, controllerSupport: ControllerSupport) {
            
            if (buildButtonLayerTouch[FortniteButtonType.Build.trapSelected] != nil) {
                controllerSupport.updateLeftTrigger(controller, left: 0);
                buildButtonLayerTouch[FortniteButtonType.Build.trapSelected] = nil
            }
            
            if (buildButtonLayerTouch[FortniteButtonType.Build.switchToCombat] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.B_FLAG.rawValue);
                buildButtonLayerTouch[FortniteButtonType.Build.switchToCombat] = nil

            } else if (buildButtonLayerTouch[FortniteButtonType.Build.pyramidSelected] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LB_FLAG.rawValue);
                buildButtonLayerTouch[FortniteButtonType.Build.pyramidSelected] = nil

            } else if (buildButtonLayerTouch[FortniteButtonType.Build.wallSelected] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.UP_FLAG.rawValue);
                buildButtonLayerTouch[FortniteButtonType.Build.wallSelected] = nil

            } else if (buildButtonLayerTouch[FortniteButtonType.Build.floorSelected] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
                buildButtonLayerTouch[FortniteButtonType.Build.floorSelected] = nil

            } else if (buildButtonLayerTouch[FortniteButtonType.Build.stairSelected] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.DOWN_FLAG.rawValue);
                buildButtonLayerTouch[FortniteButtonType.Build.stairSelected] = nil

            } else if (buildButtonLayerTouch[FortniteButtonType.Build.edit] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.LEFT_FLAG.rawValue);
                buildButtonLayerTouch[FortniteButtonType.Build.edit] = nil

            } else if (buildButtonLayerTouch[FortniteButtonType.Build.jump] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.A_FLAG.rawValue);
                buildButtonLayerTouch[FortniteButtonType.Build.jump] = nil

            } else if (buildButtonLayerTouch[FortniteButtonType.Build.shoot] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                buildButtonLayerTouch[FortniteButtonType.Build.shoot] = nil

            } else if (buildButtonLayerTouch[FortniteButtonType.Build.shootBig] != nil) {
                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RIGHT_FLAG.rawValue);
                buildButtonLayerTouch[FortniteButtonType.Build.shootBig] = nil
            }
        }

        /// Clean touch events for edit mode and react correspondingly
        private func cleanEditTouches(controller: Controller, controllerSupport: ControllerSupport) {
            if (editButtonLayerTouch[FortniteButtonType.Edit.confirm] != nil) {
                editButtonLayerTouch[FortniteButtonType.Edit.confirm] = nil
                controllerSupport.updateLeftTrigger(controller, left: 0)
                switch currentMode {
                    case .editFromBuild:
                        setMode(.build)
                    case .editFromCombat:
                        setMode(.combat)
                    default:
                        break
                }

            } else if (editButtonLayerTouch[FortniteButtonType.Edit.edit] != nil) {
                editButtonLayerTouch[FortniteButtonType.Edit.edit] = nil
                controllerSupport.updateRightTrigger(controller, right: 0)

            } else if (editButtonLayerTouch[FortniteButtonType.Edit.ping] != nil) {
                editButtonLayerTouch[FortniteButtonType.Edit.ping] = nil

            } else if (editButtonLayerTouch[FortniteButtonType.Edit.reset] != nil) {
                editButtonLayerTouch[FortniteButtonType.Edit.reset] = nil

                controllerSupport.clearButtonFlag(controller, flags: ButtonOptionSet.RB_FLAG.rawValue);
            } else if (editButtonLayerTouch[FortniteButtonType.Edit.rotate] != nil) {
                editButtonLayerTouch[FortniteButtonType.Edit.rotate] = nil

            } else if (editButtonLayerTouch[FortniteButtonType.Edit.shootBig] != nil) {
                editButtonLayerTouch[FortniteButtonType.Edit.shootBig] = nil

            } else if (editButtonLayerTouch[FortniteButtonType.Edit.shoot] != nil) {
                editButtonLayerTouch[FortniteButtonType.Edit.shoot] = nil

            } else if (editButtonLayerTouch[FortniteButtonType.Edit.switchToCombat] != nil) {
                editButtonLayerTouch[FortniteButtonType.Edit.switchToCombat] = nil
            }
        }

        /// Show specified buttons
        private func setMode(_ mode: Mode?) {
            var layerToHide: [CALayer] = []
            var layerToShow: [CALayer] = []
            let combatLayer            = Array(combatButtonLayers.values)
            let buildLayer             = Array(buildButtonLayers.values)
            let editLayer              = Array(editButtonLayers.values)
            if let mode = mode {
                switch mode {
                    case .combat:
                        layerToHide = buildLayer + editLayer
                        layerToShow = combatLayer
                    case .build:
                        layerToHide = combatLayer + editLayer
                        layerToShow = buildLayer
                    case .editFromBuild, .editFromCombat:
                        layerToHide = combatLayer + buildLayer
                        layerToShow = editLayer
                }
            } else {
                layerToHide = combatLayer + buildLayer + editLayer
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layerToHide.forEach { $0.isHidden = true }
            layerToShow.forEach { $0.isHidden = false }
            CATransaction.commit()
            currentMode = mode
        }

    }

#endif
