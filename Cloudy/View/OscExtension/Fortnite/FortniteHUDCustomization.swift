//  Copyright © 2021 Nomad5. All rights reserved.

import UIKit

class FortniteHUDCustomization: UIViewController {

    /// Outlets to storyboard
    @IBOutlet var slider:                   UISlider!
    @IBOutlet var switchViewButton:         UIButton!
    @IBOutlet var combatHUDView:            UIView!
    @IBOutlet var buildingHUDView:          UIView!
    @IBOutlet var editHUDView:              UIView!
    @IBOutlet var editViewLabel:            UILabel!
    @IBOutlet var saveButton:               UIButton!
    @IBOutlet var doneButton:               UIButton!
    @IBOutlet var settingsPanel:            UIView!
    @IBOutlet var pullDownHUDButton:        UIButton!
    @IBOutlet var buttonSettingLabel:       UILabel!
    @IBOutlet var HUDSettingsTopConstraint: NSLayoutConstraint!

    /// All buttons
    private var combatButtonItems:   [UIView]         = []
    private var buildingButtonItems: [UIView]         = []
    private var editingButtonItems:  [UIView]         = []

    /// Current mode
    private var currentMode:         FortniteHUD.Mode = .combat

    /// Views per mode
    private lazy var viewsPerMode: [FortniteHUD.Mode: UIView] = [.combat: combatHUDView,
                                                                 .build: buildingHUDView,
                                                                 .editFromCombat: editHUDView]

    /// Some constants
    struct Constants {
        struct PullDownView {
            static let topConstraintPulledUp   = CGFloat(-242.0)
            static let topConstraintPulledDown = CGFloat(-40.0)
            static let imagePullUp             = UIImage(systemName: "chevron.compact.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular, scale: .default))
            static let imagePullDown           = UIImage(systemName: "chevron.compact.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular, scale: .default))
        }
    }

    /// Struct for mode configuration
    struct ModeConfig {
        let viewsToBringToFront: [UIView]
        let title:               String
        let nextMode:            FortniteHUD.Mode
    }

    private lazy var modeTransitionConfig: [FortniteHUD.Mode: ModeConfig] = [
        .editFromCombat: ModeConfig(viewsToBringToFront: [combatHUDView, settingsPanel],
                                    title: "Combat HUD",
                                    nextMode: .combat),
        .combat: ModeConfig(viewsToBringToFront: [buildingHUDView, settingsPanel],
                            title: "Building HUD",
                            nextMode: .build),
        .build: ModeConfig(viewsToBringToFront: [editHUDView, settingsPanel],
                           title: "Editing HUD",
                           nextMode: .editFromCombat)]

    /// Is editing panel pulled down
    private var pulledDown  = true

    /// TODO, what is this tag for?
    private var tagSelected = 256

    /// View is now visible
    override func viewDidAppear(_ animated: Bool) {
        var x_axis: CGFloat = 0.0
        var y_axis: CGFloat = 50.0

        let defaults  = UserDefaults.standard
        var buttonTag = 0
        var index     = 0
        for buttonImages in FortniteButtonType.Combat.allCases {
            let button = UIView()
            let image  = UIImageView()
            image.image = UIImage(named: buttonImages.rawValue.appending(".png"))!
            image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

            let HUDCombatButtonXSaved      = defaults.array(forKey: FortniteHUDPositionKeys.combatHUDRectX)
            let HUDCombatButtonYSaved      = defaults.array(forKey: FortniteHUDPositionKeys.combatHUDRectY)
            let HUDCombatButtonWidthSaved  = defaults.array(forKey: FortniteHUDPositionKeys.combatHUDRectWidth)
            let HUDCombatButtonHeightSaved = defaults.array(forKey: FortniteHUDPositionKeys.combatHUDRectHeight)

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
            let topConstraint    = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
            let leftConstraint   = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
            let rightConstraint  = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
            button.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])

            combatButtonItems.append(button)
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
        for buttonImages in FortniteButtonType.Build.allCases {

            print(indexInBuildHUDButton)
            let button = UIView.init()
            let image  = UIImageView.init()

            let defaults = UserDefaults.standard

            image.image = UIImage(named: buttonImages.rawValue.appending(".png"))!
            image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

            let HUDBuildingButtonXSaved      = defaults.array(forKey: FortniteHUDPositionKeys.buildHUDRectX)
            let HUDBuildingButtonYSaved      = defaults.array(forKey: FortniteHUDPositionKeys.buildHUDRectY)
            let HUDBuildingButtonWidthSaved  = defaults.array(forKey: FortniteHUDPositionKeys.buildHUDRectWidth)
            let HUDBuildingButtonHeightSaved = defaults.array(forKey: FortniteHUDPositionKeys.buildHUDRectHeight)

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
            let topConstraint    = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
            let leftConstraint   = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
            let rightConstraint  = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
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
        for buttonImages in FortniteButtonType.Edit.allCases {
            let button = UIView.init()
            let image  = UIImageView.init()

            let defaults = UserDefaults.standard
            image.image = UIImage(named: buttonImages.rawValue.appending(".png"))!
            image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

            let HUDEditButtonXSaved      = defaults.array(forKey: FortniteHUDPositionKeys.editHUDRectX)
            let HUDEditButtonYSaved      = defaults.array(forKey: FortniteHUDPositionKeys.editHUDRectY)
            let HUDEditButtonWidthSaved  = defaults.array(forKey: FortniteHUDPositionKeys.editHUDRectWidth)
            let HUDEditButtonHeightSaved = defaults.array(forKey: FortniteHUDPositionKeys.editHUDRectHeight)

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
            let topConstraint    = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
            let leftConstraint   = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
            let rightConstraint  = NSLayoutConstraint(item: image, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
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
        settingsPanel.tag = 1100
        pullDownHUDButton.tag = 1200
        buttonSettingLabel.tag = 1300

        buildingHUDView.alpha = 0
        editHUDView.alpha = 0
        combatHUDView.alpha = 0

        settingsPanel.layer.cornerRadius = 10.0
        settingsPanel.clipsToBounds = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIView.animate(withDuration: 0.5) {
                self.combatHUDView.alpha = 1
            }
        }

    }

    /// Pull down extra panel
    @IBAction func pullDownHUDSettings() {
        HUDSettingsTopConstraint.constant = pulledDown ? Constants.PullDownView.topConstraintPulledUp : Constants.PullDownView.topConstraintPulledDown
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        })
        pullDownHUDButton.setImage(pulledDown ? Constants.PullDownView.imagePullDown : Constants.PullDownView.imagePullUp, for: .normal)
        pulledDown = !pulledDown
    }

    /// Switch editing mode
    @IBAction func switchCombatAndBuilding() {
        guard let nextModeConfig = modeTransitionConfig[currentMode] else {
            Log.e("Error parsing next mode")
            return
        }
        currentMode = nextModeConfig.nextMode
        nextModeConfig.viewsToBringToFront.forEach { view.bringSubviewToFront($0) }
        viewsPerMode.forEach { mode, view in view.alpha = mode == currentMode ? 1 : 0 }
        editViewLabel.text = nextModeConfig.title
    }

    /// Get values from views and save it to user defaults
    @IBAction func saveHUD() {
        let defaults = UserDefaults.standard
        defaults.set(combatButtonItems.map { $0.frame.minX }, forKey: FortniteHUDPositionKeys.combatHUDRectX)
        defaults.set(combatButtonItems.map { $0.frame.minY }, forKey: FortniteHUDPositionKeys.combatHUDRectY)
        defaults.set(combatButtonItems.map { $0.frame.width }, forKey: FortniteHUDPositionKeys.combatHUDRectWidth)
        defaults.set(combatButtonItems.map { $0.frame.height }, forKey: FortniteHUDPositionKeys.combatHUDRectHeight)

        defaults.set(buildingButtonItems.map { $0.frame.minX }, forKey: FortniteHUDPositionKeys.buildHUDRectX)
        defaults.set(buildingButtonItems.map { $0.frame.minY }, forKey: FortniteHUDPositionKeys.buildHUDRectY)
        defaults.set(buildingButtonItems.map { $0.frame.width }, forKey: FortniteHUDPositionKeys.buildHUDRectWidth)
        defaults.set(buildingButtonItems.map { $0.frame.height }, forKey: FortniteHUDPositionKeys.buildHUDRectHeight)

        defaults.set(editingButtonItems.map { $0.frame.minX }, forKey: FortniteHUDPositionKeys.editHUDRectX)
        defaults.set(editingButtonItems.map { $0.frame.minY }, forKey: FortniteHUDPositionKeys.editHUDRectY)
        defaults.set(editingButtonItems.map { $0.frame.width }, forKey: FortniteHUDPositionKeys.editHUDRectWidth)
        defaults.set(editingButtonItems.map { $0.frame.height }, forKey: FortniteHUDPositionKeys.editHUDRectHeight)
    }

    /// Scaling slider changed
    @IBAction func sliderValueChanged(sender: UISlider) {
        if tagSelected <= 117 || tagSelected == 300 {
            print("passed")
            let viewPassed = self.view.viewWithTag(self.tagSelected)
            viewPassed?.frame.size.height = (50 * CGFloat(sender.value + 1.0))
            viewPassed?.frame.size.width = (50 * CGFloat(sender.value + 1.0))
        }
    }

    /// Close editing view
    @IBAction func dismissHUDController() {
        settingsPanel.alpha = 0
        self.dismiss(animated: true, completion: nil)
    }

    /// Handle touch start
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // get location
            var location: CGPoint = .zero
            switch currentMode {
                case .combat:
                    location = touch.location(in: combatHUDView)
                case .build:
                    location = touch.location(in: buildingHUDView)
                case .editFromCombat, .editFromBuild:
                    location = touch.location(in: editHUDView)
            }
            // TODO what is this tag stuff?
            if (touch.view!.tag <= 117 || touch.view!.tag == 300) && touch.view! != slider {
                location.x -= touch.view!.frame.width / 2
                location.y -= touch.view!.frame.height / 2
                touch.view!.frame = CGRect.init(x: location.x, y: location.y, width: touch.view!.frame.width, height: touch.view!.frame.height)
            } else {
                return
            }
        }
    }

    /// Handle pressed move
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // get location
            var location: CGPoint = .zero
            switch currentMode {
                case .combat:
                    location = touch.location(in: combatHUDView)
                case .build:
                    location = touch.location(in: buildingHUDView)
                case .editFromCombat, .editFromBuild:
                    location = touch.location(in: editHUDView)
            }
            // TODO what is this tag stuff?
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

}
