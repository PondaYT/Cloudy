//
//  FortniteHUDCustomization.swift
//  Cloudy
//
//  Created by Joonwoo Kim on 2021-01-25.
//  Copyright © 2021 Nomad5. All rights reserved.
//

import UIKit

class FortniteHUDCustomization: UIViewController {

    @IBOutlet var slider:                   UISlider!
    @IBOutlet var switchViewButton:         UIButton!
    @IBOutlet var combatHUDView:            UIView!
    @IBOutlet var buildingHUDView:          UIView!
    @IBOutlet var editHUDView:              UIView!
    @IBOutlet var editViewLabel:            UILabel!
    @IBOutlet var saveButton:               UIButton!
    @IBOutlet var doneButton:               UIButton!
    @IBOutlet var HUDSettingsView:          UIView!
    @IBOutlet var pullDownHUDButton:        UIButton!
    @IBOutlet var buttonSettingLabel:       UILabel!
    @IBOutlet var HUDSettingsTopConstraint: NSLayoutConstraint!


    var listOfCombatHUDButtons = ["Aim", "Crouch Down", "Edit Reset", "Emote Wheel", "Floor Selected", "Inventory", "Interact", "Jump", "Ping", "Pyramid Selected", "Shoot Big", "Shoot", "Stair Selected", "Switch To Build", "Use", "Wall Selected", "Reload", "Slot Pickaxe", "Cycle Weapons Down", "Cycle Weapons Up"]

    var listOfBuildingHUDButtons = ["Edit Reset", "Emote Wheel", "Floor Selected", "Jump", "Ping", "Pyramid Selected", "Repair", "Reset", "Rotate", "Shoot Big", "Shoot", "Stair Selected", "Switch To Combat", "Use", "Wall Selected"]

    var listOfEditHUDButtons = ["Confirm", "Edit", "Ping", "Reset", "Rotate", "Shoot Big", "Shoot", "Switch To Combat"]

    var HUDCombatButtonX:      [CGFloat] = []
    var HUDCombatButtonY:      [CGFloat] = []
    var HUDCombatButtonWidth:  [CGFloat] = []
    var HUDCombatButtonHeight: [CGFloat] = []


    var HUDBuildingButtonX:      [CGFloat] = []
    var HUDBuildingButtonY:      [CGFloat] = []
    var HUDBuildingButtonWidth:  [CGFloat] = []
    var HUDBuildingButtonHeight: [CGFloat] = []

    var HUDEditButtonX:      [CGFloat] = []
    var HUDEditButtonY:      [CGFloat] = []
    var HUDEditButtonWidth:  [CGFloat] = []
    var HUDEditButtonHeight: [CGFloat] = []

    var buttonItems:         [UIView] = []
    var buildingButtonItems: [UIView] = []
    var editingButtonItems:  [UIView] = []

    var tagSelected = 256

    var combatView   = true
    var editView     = false
    var buildingView = false
    var pulledDown   = true


    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        var x_axis:CGFloat = 0.0
        var y_axis:CGFloat = 50.0
        
        let defaults = UserDefaults.standard
        var buttonTag = 0
        var index = 0
        for buttonImages in combatButtonType.allCases {
            let button = UIView.init()
            let image = UIImageView.init()
            image.image = UIImage(named: buttonImages.rawValue.appending(".png"))!
            image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            
            let HUDCombatButtonXSaved = defaults.array(forKey: savedHUDLayoutRects.combatHUDRectX)
            let HUDCombatButtonYSaved = defaults.array(forKey: savedHUDLayoutRects.combatHUDRectY)
            let HUDCombatButtonWidthSaved = defaults.array(forKey: savedHUDLayoutRects.combatHUDRectWidth)
            let HUDCombatButtonHeightSaved = defaults.array(forKey: savedHUDLayoutRects.combatHUDRectHeight)
            
            if HUDCombatButtonXSaved?.isEmpty == false  {
                button.frame = CGRect(x: HUDCombatButtonXSaved![buttonTag] as! CGFloat, y: HUDCombatButtonYSaved![buttonTag] as! CGFloat, width: HUDCombatButtonWidthSaved![buttonTag] as! CGFloat, height: HUDCombatButtonHeightSaved![buttonTag] as! CGFloat)
            } else {
                button.frame = CGRect(x: x_axis, y: y_axis, width: 50, height: 50)
            }
            if buttonTag == 0 {
                button.tag = 300
            } else {
                button.tag = buttonTag
            }
            button.addSubview(image)
            
            image.translatesAutoresizingMaskIntoConstraints = false
            let topConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
            let leftConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
            let rightConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
            button.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
            
            buttonItems.append(button)
            combatHUDView.addSubview(button)
            x_axis += 50
            
            if x_axis >= UIWindow.init().frame.width - 50 {
                y_axis += 50
                x_axis = 0
            }
            buttonTag += 1
            index += 1
        }
        
        var indexInBuildHUDButton = 0
        index = 0
        for buttonImages in buildButtonType.allCases {
            
            print(indexInBuildHUDButton)
            let button = UIView.init()
            let image = UIImageView.init()
            
            let defaults = UserDefaults.standard
            
            image.image = UIImage(named: buttonImages.rawValue.appending(".png"))!
            image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            
            let HUDBuildingButtonXSaved = defaults.array(forKey: savedHUDLayoutRects.buildHUDRectX)
            let HUDBuildingButtonYSaved = defaults.array(forKey: savedHUDLayoutRects.buildHUDRectY)
            let HUDBuildingButtonWidthSaved = defaults.array(forKey: savedHUDLayoutRects.buildHUDRectWidth)
            let HUDBuildingButtonHeightSaved = defaults.array(forKey: savedHUDLayoutRects.buildHUDRectHeight)
            
            if HUDBuildingButtonXSaved?.isEmpty == false {
                button.frame = CGRect(x: HUDBuildingButtonXSaved![indexInBuildHUDButton] as! CGFloat, y: HUDBuildingButtonYSaved![indexInBuildHUDButton] as! CGFloat, width: HUDBuildingButtonWidthSaved![indexInBuildHUDButton] as! CGFloat, height: HUDBuildingButtonHeightSaved![indexInBuildHUDButton] as! CGFloat)
            } else {
                button.frame = CGRect(x: x_axis, y: y_axis, width: 50, height: 50)
            }
            if buttonTag == 0 {
                button.tag = 300
            } else {
                button.tag = buttonTag
            }
            button.addSubview(image)
            
            image.translatesAutoresizingMaskIntoConstraints = false
            let topConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
            let leftConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
            let rightConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
            button.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
            
            buildingButtonItems.append(button)
            buildingHUDView.addSubview(button)
            x_axis += 50
            index += 1
            buttonTag += 1
            indexInBuildHUDButton += 1
            if x_axis >= UIWindow.init().frame.width - 50 {
                y_axis += 50
                x_axis = 0
            }
        }
        
        
        var indexInEditHUD = 0
        index = 0
        for buttonImages in editButtonType.allCases {
            let button = UIView.init()
            let image = UIImageView.init()
            
            let defaults = UserDefaults.standard
            image.image = UIImage(named: buttonImages.rawValue.appending(".png"))!
            image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            
            let HUDEditButtonXSaved = defaults.array(forKey: savedHUDLayoutRects.editHUDRectX)
            let HUDEditButtonYSaved = defaults.array(forKey: savedHUDLayoutRects.editHUDRectY)
            let HUDEditButtonWidthSaved = defaults.array(forKey: savedHUDLayoutRects.editHUDRectWidth)
            let HUDEditButtonHeightSaved = defaults.array(forKey: savedHUDLayoutRects.editHUDRectHeight)
            
            if HUDEditButtonXSaved?.isEmpty == false {
                print(buttonTag - 39)
                button.frame = CGRect(x: HUDEditButtonXSaved![indexInEditHUD] as! CGFloat, y: HUDEditButtonYSaved![indexInEditHUD] as! CGFloat, width: HUDEditButtonWidthSaved![indexInEditHUD] as! CGFloat, height: HUDEditButtonHeightSaved![indexInEditHUD] as! CGFloat)
            } else {
                button.frame = CGRect(x: x_axis, y: y_axis, width: 50, height: 50)
            }
            if buttonTag == 0 {
                button.tag = 300
            } else {
                button.tag = buttonTag
            }
            button.addSubview(image)
            
            image.translatesAutoresizingMaskIntoConstraints = false
            let topConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
            let leftConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
            let rightConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
            button.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
            
            editingButtonItems.append(button)
            editHUDView.addSubview(button)
            x_axis += 50
            index += 1
            buttonTag += 1
            indexInEditHUD += 1
            if x_axis >= UIWindow.init().frame.width - 50 {
                y_axis += 50
                x_axis = 0
            }
        }

        self.view.tag = 256
        slider.tag = 257
        buildingHUDView.tag = 500
        combatHUDView.tag = 600
        editHUDView.tag = 900
        switchViewButton.tag = 700
        saveButton.tag = 800
        doneButton.tag = 1000
        HUDSettingsView.tag = 1100
        pullDownHUDButton.tag = 1200
        buttonSettingLabel.tag = 1300

        buildingHUDView.alpha = 0
        editHUDView.alpha = 0
        combatHUDView.alpha = 0

        HUDSettingsView.layer.cornerRadius = 10.0
        HUDSettingsView.clipsToBounds = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIView.animate(withDuration: 0.5) {
                self.combatHUDView.alpha = 1
            }
        }

    }


    @IBAction func pullDownHUDSettings() {
        if pulledDown {
            HUDSettingsTopConstraint.constant = -242
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            })
            let size  = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular, scale: .default)
            let image = UIImage(systemName: "chevron.compact.down", withConfiguration: size)
            pullDownHUDButton.setImage(image, for: .normal)
            pulledDown = false
        } else {
            HUDSettingsTopConstraint.constant = -40
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            })
            let size  = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular, scale: .default)
            let image = UIImage(systemName: "chevron.compact.up", withConfiguration: size)
            pullDownHUDButton.setImage(image, for: .normal)
            pulledDown = true
        }
    }

    @IBAction func switchCombatAndBuilding() {

        if combatView {
            self.view.bringSubviewToFront(self.buildingHUDView)
            self.view.bringSubviewToFront(self.slider)
            self.view.bringSubviewToFront(self.switchViewButton)
            self.view.bringSubviewToFront(self.editViewLabel)
            self.view.bringSubviewToFront(self.saveButton)
            self.view.bringSubviewToFront(self.doneButton)
            self.view.bringSubviewToFront(HUDSettingsView)

            self.combatHUDView.alpha = 0
            self.buildingHUDView.alpha = 1
            editViewLabel.text = "Building HUD"

            combatView = false
            buildingView = true
            editView = false
        } else if buildingView {
            self.view.bringSubviewToFront(self.editHUDView)
            self.view.bringSubviewToFront(self.slider)
            self.view.bringSubviewToFront(self.switchViewButton)
            self.view.bringSubviewToFront(self.editViewLabel)
            self.view.bringSubviewToFront(self.saveButton)
            self.view.bringSubviewToFront(self.doneButton)
            self.view.bringSubviewToFront(HUDSettingsView)

            self.combatHUDView.alpha = 0
            self.buildingHUDView.alpha = 0
            self.editHUDView.alpha = 1

            editViewLabel.text = "Editing HUD"

            combatView = false
            buildingView = false
            editView = true
        } else if editView {
            self.view.bringSubviewToFront(self.combatHUDView)
            self.view.bringSubviewToFront(self.slider)
            self.view.bringSubviewToFront(self.switchViewButton)
            self.view.bringSubviewToFront(self.editViewLabel)
            self.view.bringSubviewToFront(self.saveButton)
            self.view.bringSubviewToFront(self.doneButton)
            self.view.bringSubviewToFront(HUDSettingsView)

            self.combatHUDView.alpha = 1
            self.buildingHUDView.alpha = 0
            self.editHUDView.alpha = 0

            editViewLabel.text = "Combat HUD"

            combatView = true
            buildingView = false
            editView = false
        }

    }

    @IBAction func saveHUD() {
        HUDCombatButtonX.removeAll()
        HUDCombatButtonY.removeAll()
        HUDCombatButtonWidth.removeAll()
        HUDCombatButtonHeight.removeAll()

        HUDBuildingButtonX.removeAll()
        HUDBuildingButtonY.removeAll()
        HUDBuildingButtonWidth.removeAll()
        HUDBuildingButtonHeight.removeAll()


        for buttons in buttonItems {
            HUDCombatButtonX.append(buttons.frame.minX)
            HUDCombatButtonY.append(buttons.frame.minY)
            HUDCombatButtonWidth.append(buttons.frame.width)
            HUDCombatButtonHeight.append(buttons.frame.height)
        }

        var i = 0

        for buttons in buildingButtonItems {
            print(i)
            i += 1
            HUDBuildingButtonX.append(buttons.frame.minX)
            HUDBuildingButtonY.append(buttons.frame.minY)
            HUDBuildingButtonWidth.append(buttons.frame.width)
            HUDBuildingButtonHeight.append(buttons.frame.height)
        }

        for buttons in editingButtonItems {
            HUDEditButtonX.append(buttons.frame.minX)
            HUDEditButtonY.append(buttons.frame.minY)
            HUDEditButtonWidth.append(buttons.frame.width)
            HUDEditButtonHeight.append(buttons.frame.height)
        }


        let defaults = UserDefaults.standard
        defaults.set(HUDCombatButtonX, forKey: savedHUDLayoutRects.combatHUDRectX)
        defaults.set(HUDCombatButtonY, forKey: savedHUDLayoutRects.combatHUDRectY)
        defaults.set(HUDCombatButtonWidth, forKey: savedHUDLayoutRects.combatHUDRectWidth)
        defaults.set(HUDCombatButtonHeight, forKey: savedHUDLayoutRects.combatHUDRectHeight)
        
        defaults.set(HUDBuildingButtonX, forKey: savedHUDLayoutRects.buildHUDRectX)
        defaults.set(HUDBuildingButtonY, forKey: savedHUDLayoutRects.buildHUDRectY)
        defaults.set(HUDBuildingButtonWidth, forKey: savedHUDLayoutRects.buildHUDRectWidth)
        defaults.set(HUDBuildingButtonHeight, forKey: savedHUDLayoutRects.buildHUDRectHeight)
        
        defaults.set(HUDEditButtonX, forKey: savedHUDLayoutRects.editHUDRectX)
        defaults.set(HUDEditButtonY, forKey: savedHUDLayoutRects.editHUDRectY)
        defaults.set(HUDEditButtonWidth, forKey: savedHUDLayoutRects.editHUDRectWidth)
        defaults.set(HUDEditButtonHeight, forKey: savedHUDLayoutRects.editHUDRectHeight)


    }

    @IBAction func sliderValueChanged(sender: UISlider) {
        var currentValue = Int(sender.value)

        if tagSelected <= 117 || tagSelected == 300 {
            print("passed")
            let viewPassed = self.view.viewWithTag(self.tagSelected)
            viewPassed?.frame.size.height = (50 * CGFloat(sender.value + 1.0))
            viewPassed?.frame.size.width = (50 * CGFloat(sender.value + 1.0))
        }

    }


    @IBAction func dismissHUDController() {
        HUDSettingsView.alpha = 0
        self.dismiss(animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            var location = editView ? touch.location(in: self.buildingHUDView) : touch.location(in: self.combatHUDView)

            if combatView {
                location = touch.location(in: self.combatHUDView)
            } else if buildingView {
                location = touch.location(in: self.buildingHUDView)
            } else if editView {
                location = touch.location(in: self.editHUDView)
            }

            if (touch.view!.tag <= 117 || touch.view!.tag == 300) && touch.view! != slider {
                location.x -= touch.view!.frame.width / 2
                location.y -= touch.view!.frame.height / 2
                touch.view!.frame = CGRect.init(x: location.x, y: location.y, width: touch.view!.frame.width, height: touch.view!.frame.height)

            } else {
                return
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            var location = editView ? touch.location(in: self.buildingHUDView) : touch.location(in: self.combatHUDView)

            if combatView {
                location = touch.location(in: self.combatHUDView)
            } else if buildingView {
                location = touch.location(in: self.buildingHUDView)
            } else if editView {
                location = touch.location(in: self.editHUDView)
            }

            if (touch.view!.tag <= 117 || touch.view!.tag == 300) && touch.view! != slider {
                location.x -= touch.view!.frame.width / 2
                location.y -= touch.view!.frame.height / 2
                touch.view!.frame = CGRect.init(x: location.x, y: location.y, width: touch.view!.frame.width, height: touch.view!.frame.height)
                tagSelected = touch.view!.tag

            } else {
                return
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }


}
