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
    
    var listOfBasicHUDButtons = ["Aim", "Autorun", "Confirm", "Crouch Down", "Crouch Up", "Cycle Weapons Down", "Cycle Weapons Up", "Edit Crosshair", "Edit Reset", "Edit", "Emote Wheel", "Exit", "Floor Selected", "Floor Unselected", "Inventory", "Jump", "Mic Muted", "Mic Unmuted", "Move Joystick", "Move Outer", "Open Chest", "Open Door", "Ping", "Pyramid Selected", "Pyramid Unselected", "Quick Chat", "Quick Heal", "Repair", "Reset", "Rotate", "Shoot Big", "Shoot", "Stair Selected", "Stair Unselected", "Switch To Build", "Switch To Combat", "Throw", "Use", "Wall Selected", "Wall Unselected"]
    
    var HUDButtonRect:[CGRect] = []
    var HUDButtonHeight:[NSLayoutConstraint] = []
    var HUDButtonWidth:[NSLayoutConstraint] = []
    var buttonItems:[UIView] = []
    
    var tagSelected = 256
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var x_axis:CGFloat = 0.0
        var y_axis:CGFloat = 50.0
        
        var buttonTag = 0
        for buttonImages in listOfBasicHUDButtons {
            let button = UIView.init()
            let image = UIImageView.init()
            image.image = self.resizeImage(UIImage(named: "\(buttonImages).png")!, targetSize: CGSize(width: 100, height: 100))
            image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            button.frame = CGRect(x: x_axis, y: y_axis, width: 50, height: 50)
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
            view.addSubview(button)
            x_axis += 50
            buttonTag += 1
            if x_axis >= UIWindow.init().frame.width - 50 {
                y_axis += 50
                x_axis = 0
            }
        }
        
        self.view.tag = 256
        slider.tag = 257
    }
    
    @objc func printSomething() {
        print("presed")
    }
    
    @IBAction func saveHUD() {
        HUDButtonRect.removeAll()
        for buttons in buttonItems {
            HUDButtonRect.append(buttons.frame)
        }
        
        for rects in HUDButtonRect {
            print(rects)
        }
        
        //SAVE USER DEFAULTS IN HERE
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        var currentValue = Int(sender.value)
        
        if tagSelected <= 39 || tagSelected == 300 {
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
            var location = touch.location(in: self.view)
            if (touch.view!.tag <= 39 || touch.view!.tag == 300) && touch.view! != slider {
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
            var location = touch.location(in: self.view)
            if (touch.view!.tag <= 39 || touch.view!.tag == 300)  && touch.view! != slider {
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
