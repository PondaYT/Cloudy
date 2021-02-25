//  Copyright © 2021 Nomad5. All rights reserved.

import UIKit

class FortniteHUDCustomization: UIViewController {

    #if REKAIROS
        /// Outlets to storyboard
        @IBOutlet var scalingSlider:               UISlider!
        @IBOutlet var switchModeButton:            UIButton!
        @IBOutlet var saveButton:                  UIButton!
        @IBOutlet var doneButton:                  UIButton!
        @IBOutlet var combatHUDView:               UIView!
        @IBOutlet var buildingHUDView:             UIView!
        @IBOutlet var editHUDView:                 UIView!
        @IBOutlet var currentModeLabel:            UILabel!
        @IBOutlet var selectedButtonLabel:         UILabel!
        @IBOutlet var settingsPanel:               UIView!
        @IBOutlet var pullDownSettingsPanelButton: UIButton!
        @IBOutlet var hudSettingsTopConstraint:    NSLayoutConstraint!

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

        func createButtons(parentView: UIView, buttonTag: Int, images: [String], keyX: String, keyY: String, keyWidth: String, keyHeight: String) -> (buttonTag: Int, buttons: [UIView]) {
            let defaults              = UserDefaults.standard
            var xAxis:       CGFloat  = 0.0
            var yAxis:       CGFloat  = 150.0
            var buttonTag             = buttonTag
            var buttonArray: [UIView] = []

            let savedX      = defaults.array(forKey: keyX)
            let savedY      = defaults.array(forKey: keyY)
            let savedWidth  = defaults.array(forKey: keyWidth)
            let savedHeight = defaults.array(forKey: keyHeight)

            images.enumerated().forEach { index, imageName in
                let button = UIView()
                let image  = UIImageView()
                image.image = UIImage(named: imageName.appending(".png"))!
                image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

                if savedX?.isEmpty == false {
                    button.frame = CGRect(x: savedX![index] as! CGFloat,
                                          y: savedY![index] as! CGFloat,
                                          width: savedWidth![index] as! CGFloat,
                                          height: savedHeight![index] as! CGFloat)
                } else {
                    button.frame = CGRect(x: xAxis, y: yAxis, width: 50, height: 50)
                }
                if buttonTag == 0 {
                    button.tag = 300
                } else {
                    button.tag = buttonTag
                }
                button.addSubview(image)
                image.placeOnParent()

                buttonArray.append(button)
                parentView.addSubview(button)
                xAxis += 50

                if xAxis >= UIWindow().frame.width - 50 {
                    yAxis += 50
                    xAxis = 0
                }
                buttonTag += 1
            }
            return (buttonTag, buttonArray)
        }

        /// View is now visible
        override func viewDidAppear(_ animated: Bool) {
            // combat views
            let combatViews = createButtons(parentView: combatHUDView,
                                            buttonTag: 0,
                                            images: FortniteButtonType.Combat.allCases.map { $0.rawValue },
                                            keyX: FortniteHUDPositionKeys.combatHUDRectX,
                                            keyY: FortniteHUDPositionKeys.combatHUDRectY,
                                            keyWidth: FortniteHUDPositionKeys.combatHUDRectWidth,
                                            keyHeight: FortniteHUDPositionKeys.combatHUDRectHeight)
            combatButtonItems = combatViews.buttons
            // building views
            let buildingViews = createButtons(parentView: buildingHUDView,
                                              buttonTag: combatViews.buttonTag,
                                              images: FortniteButtonType.Build.allCases.map { $0.rawValue },
                                              keyX: FortniteHUDPositionKeys.buildHUDRectX,
                                              keyY: FortniteHUDPositionKeys.buildHUDRectY,
                                              keyWidth: FortniteHUDPositionKeys.buildHUDRectWidth,
                                              keyHeight: FortniteHUDPositionKeys.buildHUDRectHeight)
            buildingButtonItems = buildingViews.buttons
            // edit views
            let editViews = createButtons(parentView: editHUDView,
                                          buttonTag: buildingViews.buttonTag,
                                          images: FortniteButtonType.Edit.allCases.map { $0.rawValue },
                                          keyX: FortniteHUDPositionKeys.editHUDRectX,
                                          keyY: FortniteHUDPositionKeys.editHUDRectY,
                                          keyWidth: FortniteHUDPositionKeys.editHUDRectWidth,
                                          keyHeight: FortniteHUDPositionKeys.editHUDRectHeight)
            editingButtonItems = editViews.buttons
            // some tag voodoo
            view.tag = 256
            scalingSlider.tag = 257
            buildingHUDView.tag = 500
            combatHUDView.tag = 600
            editHUDView.tag = 900
            switchModeButton.tag = 700
            saveButton.tag = 800
            doneButton.tag = 1000
            settingsPanel.tag = 1100
            pullDownSettingsPanelButton.tag = 1200
            selectedButtonLabel.tag = 1300

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
            hudSettingsTopConstraint.constant = pulledDown ? Constants.PullDownView.topConstraintPulledUp : Constants.PullDownView.topConstraintPulledDown
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            })
            pullDownSettingsPanelButton.setImage(pulledDown ? Constants.PullDownView.imagePullDown : Constants.PullDownView.imagePullUp, for: .normal)
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
            currentModeLabel.text = nextModeConfig.title
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
                if (touch.view!.tag <= 117 || touch.view!.tag == 300) && touch.view! != scalingSlider {
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
                if (touch.view!.tag <= 117 || touch.view!.tag == 300) && touch.view! != scalingSlider {
                    location.x -= touch.view!.frame.width / 2
                    location.y -= touch.view!.frame.height / 2
                    touch.view!.frame = CGRect.init(x: location.x, y: location.y, width: touch.view!.frame.width, height: touch.view!.frame.height)
                    tagSelected = touch.view!.tag
                } else {
                    return
                }
            }
        }

    #endif
}
