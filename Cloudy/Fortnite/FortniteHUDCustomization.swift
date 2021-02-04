//
//  FortniteHUDCustomization.swift
//  Cloudy
//
//  Created by Joonwoo Kim on 2021-01-25.
//  Copyright © 2021 Nomad5. All rights reserved.
//

import UIKit

class FortniteHUDCustomization: UIViewController {
    
    @IBOutlet var slider: UISlider!
    @IBOutlet var switchViewButton: UIButton!
    @IBOutlet var combatHUDView: UIView!
    @IBOutlet var buildingHUDView: UIView!
    @IBOutlet var editHUDView: UIView!
    @IBOutlet var editViewLabel: UILabel!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    
    var listOfCombatHUDButtons = ["Aim", "Crouch Down", "Edit Reset", "Emote Wheel", "Floor Selected", "Inventory", "Interact", "Jump", "Ping", "Pyramid Selected", "Shoot Big", "Shoot", "Stair Selected", "Switch To Build", "Use", "Wall Selected"]
    
    var listOfBuildingHUDButtons = ["Edit Reset",  "Emote Wheel",  "Floor Selected", "Jump", "Ping", "Pyramid Selected", "Repair", "Reset", "Rotate", "Shoot Big", "Shoot", "Stair Selected", "Switch To Combat", "Use", "Wall Selected"]
    
    var listOfEditHUDButtons = ["Confirm", "Edit", "Ping", "Reset", "Rotate", "Shoot Big", "Shoot", "Switch To Combat"]
    
    var HUDCombatButtonX:[CGFloat] = []
    var HUDCombatButtonY:[CGFloat] = []
    var HUDCombatButtonWidth:[CGFloat] = []
    var HUDCombatButtonHeight:[CGFloat] = []
    
    var HUDBuildingButtonX:[CGFloat] = []
    var HUDBuildingButtonY:[CGFloat] = []
    var HUDBuildingButtonWidth:[CGFloat] = []
    var HUDBuildingButtonHeight:[CGFloat] = []
    
    var HUDEditButtonX:[CGFloat] = []
    var HUDEditButtonY:[CGFloat] = []
    var HUDEditButtonWidth:[CGFloat] = []
    var HUDEditButtonHeight:[CGFloat] = []
    
    var buttonItems:[UIView] = []
    var buildingButtonItems:[UIView] = []
    var editingButtonItems:[UIView] = []
    
    var tagSelected = 256
    
    var combatView = true
    var editView = false
    var buildingView = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var x_axis:CGFloat = 0.0
        var y_axis:CGFloat = 50.0
        
        let defaults = UserDefaults.standard
        var buttonTag = 0
        var combatButtonExcludeIndex = 0
        for buttonImages in listOfCombatHUDButtons {
            print(buttonImages)
            let button = UIView.init()
            let image = UIImageView.init()
            image.image = UIImage(named: "\(buttonImages).png")!
            image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            
            let HUDCombatButtonXSaved = defaults.array(forKey: "reKairosCombatHUDRectX")
            let HUDCombatButtonYSaved = defaults.array(forKey: "reKairosCombatHUDRectY")
            let HUDCombatButtonWidthSaved = defaults.array(forKey: "reKairosCombatHUDRectWidth")
            let HUDCombatButtonHeightSaved = defaults.array(forKey: "reKairosCombatHUDRectHeight")
            
            if HUDCombatButtonXSaved?.isEmpty == false {
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
        }
        
        
        for buttonImages in listOfBuildingHUDButtons {
            let button = UIView.init()
            let image = UIImageView.init()
            
            let defaults = UserDefaults.standard
            
            image.image = UIImage(named: "\(buttonImages).png")!
            image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            
            let HUDBuildingButtonXSaved = defaults.array(forKey: "reKairosBuildingHUDRectX")
            let HUDBuildingButtonYSaved = defaults.array(forKey: "reKairosBuildingHUDRectY")
            let HUDBuildingButtonWidthSaved = defaults.array(forKey: "reKairosBuildingHUDRectWidth")
            let HUDBuildingButtonHeightSaved = defaults.array(forKey: "reKairosBuildingHUDRectHeight")
            
            if HUDBuildingButtonXSaved?.isEmpty == false {
                print(buttonTag - 39)
                button.frame = CGRect(x: HUDBuildingButtonXSaved![buttonTag - 40] as! CGFloat, y: HUDBuildingButtonYSaved![buttonTag - 40] as! CGFloat, width: HUDBuildingButtonWidthSaved![buttonTag - 40] as! CGFloat, height: HUDBuildingButtonHeightSaved![buttonTag - 40] as! CGFloat)
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
            buttonTag += 1
            if x_axis >= UIWindow.init().frame.width - 50 {
                y_axis += 50
                x_axis = 0
            }
        }
        
        for buttonImages in listOfEditHUDButtons {
            let button = UIView.init()
            let image = UIImageView.init()
            
            let defaults = UserDefaults.standard
            
            image.image = UIImage(named: "\(buttonImages).png")!
            image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            
            let HUDEditButtonXSaved = defaults.array(forKey: "reKairosEditHUDRectX")
            let HUDEditButtonYSaved = defaults.array(forKey: "reKairosEditHUDRectY")
            let HUDEditButtonWidthSaved = defaults.array(forKey: "reKairosEditHUDRectWidth")
            let HUDEditButtonHeightSaved = defaults.array(forKey: "reKairosEditHUDRectHeight")
            
            if HUDEditButtonXSaved?.isEmpty == false {
                print(buttonTag - 39)
                button.frame = CGRect(x: HUDEditButtonXSaved![buttonTag - 40] as! CGFloat, y: HUDEditButtonYSaved![buttonTag - 40] as! CGFloat, width: HUDEditButtonWidthSaved![buttonTag - 40] as! CGFloat, height: HUDEditButtonHeightSaved![buttonTag - 40] as! CGFloat)
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
            buttonTag += 1
            if x_axis >= UIWindow.init().frame.width - 50 {
                y_axis += 50
                x_axis = 0
            }
        }
        
        self.view.tag = 256
        slider.tag = 257
        buildingHUDView.tag = 500
        combatHUDView.tag = 600
        switchViewButton.tag = 700
        saveButton.tag = 800
        doneButton.tag = 800
        
        buildingHUDView.alpha = 0
        
    }
    
    @IBAction func switchCombatAndBuilding() {
        
        if combatView {
            self.view.bringSubviewToFront(self.buildingHUDView)
            self.view.bringSubviewToFront(self.slider)
            self.view.bringSubviewToFront(self.switchViewButton)
            self.view.bringSubviewToFront(self.editViewLabel)
            self.view.bringSubviewToFront(self.saveButton)
            self.view.bringSubviewToFront(self.doneButton)
            
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
          
            self.combatHUDView.alpha = 1
            self.buildingHUDView.alpha = 0
            self.editHUDView.alpha = 0
            
            editViewLabel.text = "Combat HUD"
            
            combatView = true
            buildingView = false
            editView = false
        }
        
    }
    
    @objc func printSomething() {
        print("presed")
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
        
        for buttons in buildingButtonItems {
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
        defaults.set(HUDCombatButtonX, forKey: "reKairosCombatHUDRectX")
        defaults.set(HUDCombatButtonY, forKey: "reKairosCombatHUDRectY")
        defaults.set(HUDCombatButtonWidth, forKey: "reKairosCombatHUDRectWidth")
        defaults.set(HUDCombatButtonHeight, forKey: "reKairosCombatHUDRectHeight")
        
        defaults.set(HUDBuildingButtonX, forKey: "reKairosBuildingHUDRectX")
        defaults.set(HUDBuildingButtonY, forKey: "reKairosBuildingHUDRectY")
        defaults.set(HUDBuildingButtonWidth, forKey: "reKairosBuildingHUDRectWidth")
        defaults.set(HUDBuildingButtonHeight, forKey: "reKairosBuildingHUDRectHeight")
        
        defaults.set(HUDEditButtonX, forKey: "reKairosEditHUDRectX")
        defaults.set(HUDEditButtonY, forKey: "reKairosEditHUDRectY")
        defaults.set(HUDEditButtonWidth, forKey: "reKairosEditHUDRectWidth")
        defaults.set(HUDEditButtonHeight, forKey: "reKairosEditHUDRectHeight")
        
        
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        var currentValue = Int(sender.value)
        
        if tagSelected <= 117 || tagSelected == 300 {
            print("passed")
            let viewPassed = self.view.viewWithTag(self.tagSelected)
            viewPassed?.frame.size.height = (50*CGFloat(sender.value + 1.0))
            viewPassed?.frame.size.width = (50*CGFloat(sender.value + 1.0))
        }
        
    }
    
    
    @IBAction func dismissHUDController() {
        
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
                location.x -= touch.view!.frame.width/2
                location.y -= touch.view!.frame.height/2
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
            
            if (touch.view!.tag <= 117 || touch.view!.tag == 300)  && touch.view! != slider {
                location.x -= touch.view!.frame.width/2
                location.y -= touch.view!.frame.height/2
                touch.view!.frame = CGRect.init(x: location.x, y: location.y, width: touch.view!.frame.width, height: touch.view!.frame.height)
                tagSelected = touch.view!.tag
                
            } else {
                return
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
