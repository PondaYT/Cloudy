// Copyright (c) 2020 Nomad5. All rights reserved.

import UIKit
import WebKit

/// Listen to changed settings in menu
protocol MenuActionsHandler {
    func updateOnScreenController(with value: OnScreenControlsLevel)
    func updateTouchFeedbackType(with value: TouchFeedbackType)
    func injectCustom(code: String)
    func updateScalingFactor(with value: Int)
    func initializeViews()
}

/// The main view controller
/// TODO way too big, refactor asap
class RootViewController: UIViewController, MenuActionsHandler {

    /// Factory method
    static func create(with launchUrl: URL?) -> RootViewController {
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RootViewController") as! RootViewController
        newViewController.injectedWebsite = launchUrl
        return newViewController
    }

    /// Containers
    @IBOutlet var containerWebView:            UIView!
    @IBOutlet var containerOnScreenController: UIView!
    
    @IBOutlet var combatHUDView: UIView!
    @IBOutlet var buildingHUDView: UIView!
    @IBOutlet var menuButton: UIButton!
    

    @IBOutlet var webviewConstraints: [NSLayoutConstraint]!

    /// The hacked webView
    private var webView:         FullScreenWKWebView?

    /// Optional launch url
    private var injectedWebsite: URL?

    /// The model to handle url navigation
    private let navigator:       Navigator       = Navigator()

    /// The menu controller
    private var menu:            MenuController? = nil

    /// The bridge between controller and web view
    private let webViewControllerBridge          = WebViewControllerBridge()

    /// The stream view that holds the on screen controls
    private var streamView:      StreamView?
    
    
    
    var listOfCombatHUDButtons = ["Aim", "Autorun", "Confirm", "Crouch Down", "Crouch Up", "Cycle Weapons Down", "Cycle Weapons Up", "Edit Crosshair", "Edit Reset", "Edit", "Emote Wheel", "Exit", "Floor Selected", "Floor Unselected", "Inventory", "Jump", "Mic Muted", "Mic Unmuted", "Move Joystick", "Move Outer", "Open Chest", "Open Door", "Ping", "Pyramid Selected", "Pyramid Unselected", "Quick Chat", "Quick Heal", "Repair", "Reset", "Rotate", "Shoot Big", "Shoot", "Stair Selected", "Stair Unselected", "Switch To Build", "Switch To Combat", "Throw", "Use", "Wall Selected", "Wall Unselected"]
    
    var listOfBuildingHUDButtons = ["Aim", "Autorun", "Confirm", "Crouch Down", "Crouch Up", "Cycle Weapons Down", "Cycle Weapons Up", "Edit Crosshair", "Edit Reset", "Edit", "Emote Wheel", "Exit", "Floor Selected", "Floor Unselected", "Inventory", "Jump", "Mic Muted", "Mic Unmuted", "Move Joystick", "Move Outer", "Open Chest", "Open Door", "Ping", "Pyramid Selected", "Pyramid Unselected", "Quick Chat", "Quick Heal", "Repair", "Reset", "Rotate", "Shoot Big", "Shoot", "Stair Selected", "Stair Unselected", "Switch To Build", "Switch To Combat", "Throw", "Use", "Wall Selected", "Wall Unselected"]
    
    var HUDCombatButtonX:[CGFloat] = []
    var HUDCombatButtonY:[CGFloat] = []
    var HUDCombatButtonWidth:[CGFloat] = []
    var HUDCombatButtonHeight:[CGFloat] = []
    
    var HUDBuildingButtonX:[CGFloat] = []
    var HUDBuildingButtonY:[CGFloat] = []
    var HUDBuildingButtonWidth:[CGFloat] = []
    var HUDBuildingButtonHeight:[CGFloat] = []
    
    

    /// Expose the web controller for navigation
    var webController: WebController? {
        webView
    }

    /// Touch feedback generator
    private lazy var touchFeedbackGenerator: TouchFeedbackGenerator = {
        AVFoundationVibratingFeedbackGenerator()
    }()

    /// The alert helper
    lazy var alerter: Alerter = {
        Alerter(viewController: self)
    }()

    /// The purchase helper
    lazy var purchaseHelper = {
        PurchaseHelper(with: alerter)
    }()


    /// By default hide the status bar
    override var prefersStatusBarHidden:                      Bool {
        true
    }

    /// Hide bottom bar on x devices
    override var prefersHomeIndicatorAutoHidden:              Bool {
        true
    }

    /// Defer edge swiping animations
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        [.all]
    }

    /// The configuration used for the wk webView
    private func createWebViewConfig() -> WKWebViewConfiguration {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        let config = WKWebViewConfiguration()
        config.preferences = preferences
        config.allowsInlineMediaPlayback = UserDefaults.standard.allowInlineMedia
        config.allowsAirPlayForMediaPlayback = false
        config.allowsPictureInPictureMediaPlayback = false
        config.mediaTypesRequiringUserActionForPlayback = []
        config.applicationNameForUserAgent = "Version/14.0.2 Safari/605.1.15"
        if UserDefaults.standard.actAsStandaloneApp {
            config.userContentController.addUserScript(.standalone)
        }
        config.userContentController.addScriptMessageHandler(webViewControllerBridge, contentWorld: WKContentWorld.page, name: "controller")
        if UserDefaults.standard.injectControllerScripts {
            config.userContentController.addUserScript(.controller)
        }
        return config
    }

    /// View layout already done
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        initializeViews()
        checkDonationReminder()
    }

    /// Initialize all the required views (webview, onscreen controls and menu)
    func initializeViews() {
        createWebview()
        createOnScreenControls()
        createMenu()
    }

    /// Update visibility of onscreen controller
    func updateOnScreenController(with value: OnScreenControlsLevel) {
        containerOnScreenController.alpha = value == .off ? 0 : 1
        webViewControllerBridge.controlsSource = value == .off ? .external : .onScreen
        streamView?.updateOnScreenControls()
    }

    /// Update touch feedback change
    func updateTouchFeedbackType(with value: TouchFeedbackType) {
        touchFeedbackGenerator.setFeedbackType(value)
    }

    /// Update the scaling factor
    func updateScalingFactor(with value: Int) {
        webviewConstraints.forEach { $0.constant = CGFloat(value) }
    }

    /// Handle code injection
    func injectCustom(code: String) {
        webView?.inject(scripts: [code])
    }

    /// Tapped on the menu item
    @IBAction func onMenuButtonPressed(_ sender: Any) {
        menu?.show()
    }

    /// Create the web view
    private func createWebview() {
        // cleanup first
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        webView?.removeFromSuperview()
        webView = nil
        // create new
        let newWebView = FullScreenWKWebView(frame: view.bounds, configuration: createWebViewConfig())
        newWebView.translatesAutoresizingMaskIntoConstraints = false
        containerWebView.addSubview(newWebView)
        newWebView.fillParent()
        newWebView.uiDelegate = self
        newWebView.navigationDelegate = self
        newWebView.allowsBackForwardNavigationGestures = false
        newWebView.navigateTo(url: injectedWebsite ?? navigator.initialWebsite)
        webView = newWebView
    }

    /// Create the menu view controller
    private func createMenu() {
        // already existing?
        if let menuViewController = menu as? MenuViewController {
            view.bringSubviewToFront(menuViewController.view)
            return
        }
        // create new
        let menuViewController = MenuViewController.create()
        menu = menuViewController
        menuViewController.view.alpha = 0
        menuViewController.webController = webView
        menuViewController.overlayController = self
        menuViewController.menuActionsHandler = self
        menuViewController.purchaseHelper = purchaseHelper
        menuViewController.alerter = alerter
        menuViewController.view.frame = view.bounds
        menuViewController.willMove(toParent: self)
        addChild(menuViewController)
        view.addSubview(menuViewController.view)
        menuViewController.didMove(toParent: self)
    }

    /// Create the on screen controls
    private func createOnScreenControls() {
        // remove first
        streamView?.cleanup()
        streamView?.removeFromSuperview()
        streamView = nil
        // create new
        let streamConfig      = StreamConfiguration()
        // Controller support
        let controllerSupport = ControllerSupport(config: streamConfig,
                                                  presenceDelegate: self,
                                                  controllerDataReceiver: webViewControllerBridge)
        // stream view
        let newStreamView     = StreamView(frame: containerOnScreenController.bounds)
        newStreamView.setupStreamView(controllerSupport,
                                      interactionDelegate: self,
                                      config: streamConfig,
                                      hapticFeedback: touchFeedbackGenerator)
        newStreamView.showOnScreenControls()
        containerOnScreenController.addSubview(newStreamView)
        newStreamView.fillParent()
        streamView = newStreamView
        updateOnScreenController(with: UserDefaults.standard.onScreenControlsLevel)
        updateScalingFactor(with: UserDefaults.standard.webViewScale)
        
        
        
        
        
        
        /*
        var x_axis:CGFloat = 0.0
        var y_axis:CGFloat = 50.0
        
        let defaults = UserDefaults.standard
        
        var buttonTag = 0
        for buttonImages in listOfCombatHUDButtons {
            let button = UIButton.init()
            
            let HUDCombatButtonXSaved = defaults.array(forKey: "reKairosCombatHUDRectX")
            let HUDCombatButtonYSaved = defaults.array(forKey: "reKairosCombatHUDRectY")
            let HUDCombatButtonWidthSaved = defaults.array(forKey: "reKairosCombatHUDRectWidth")
            let HUDCombatButtonHeightSaved = defaults.array(forKey: "reKairosCombatHUDRectHeight")
            
            button.setImage(self.resizeImage(UIImage(named: "\(buttonImages).png")!, targetSize: CGSize(width: HUDCombatButtonWidthSaved![buttonTag] as! CGFloat, height: HUDCombatButtonHeightSaved![buttonTag] as! CGFloat)), for: .normal)
            
            if HUDCombatButtonXSaved?.isEmpty == false {
                button.frame = CGRect(x: HUDCombatButtonXSaved![buttonTag] as! CGFloat, y: HUDCombatButtonYSaved![buttonTag] as! CGFloat, width: HUDCombatButtonWidthSaved![buttonTag] as! CGFloat, height: HUDCombatButtonHeightSaved![buttonTag] as! CGFloat)
            } else {
                button.frame = CGRect(x: x_axis, y: y_axis, width: 50, height: 50)
            }
            
            // button.addTarget(self, action:#selector(pressed), for: .touchUpInside)
            
            combatHUDView.addSubview(button)
            x_axis += 50
            buttonTag += 1
            if x_axis >= UIWindow.init().frame.width - 50 {
                y_axis += 50
                x_axis = 0
            }
        }
        
        
        for buttonImages in listOfBuildingHUDButtons {
            let button = UIButton.init()
            
            let defaults = UserDefaults.standard
            
            let HUDBuildingButtonXSaved = defaults.array(forKey: "reKairosBuildingHUDRectX")
            let HUDBuildingButtonYSaved = defaults.array(forKey: "reKairosBuildingHUDRectY")
            let HUDBuildingButtonWidthSaved = defaults.array(forKey: "reKairosBuildingHUDRectWidth")
            let HUDBuildingButtonHeightSaved = defaults.array(forKey: "reKairosBuildingHUDRectHeight")
            
            button.setImage(self.resizeImage(UIImage(named: "\(buttonImages).png")!, targetSize: CGSize(width: HUDBuildingButtonWidthSaved![buttonTag - 40] as! CGFloat, height: HUDBuildingButtonHeightSaved![buttonTag - 40] as! CGFloat)), for: .normal)
            
            if HUDBuildingButtonXSaved?.isEmpty == false {
                print(buttonTag - 39)
                button.frame = CGRect(x: HUDBuildingButtonXSaved![buttonTag - 40] as! CGFloat, y: HUDBuildingButtonYSaved![buttonTag - 40] as! CGFloat, width: HUDBuildingButtonWidthSaved![buttonTag - 40] as! CGFloat, height: HUDBuildingButtonHeightSaved![buttonTag - 40] as! CGFloat)
            } else {
                button.frame = CGRect(x: x_axis, y: y_axis, width: 50, height: 50)
            }
            
            // button.addTarget(self, action:#selector(pressed), for: .touchUpInside)
            
            buildingHUDView.addSubview(button)
            x_axis += 50
            buttonTag += 1
            if x_axis >= UIWindow.init().frame.width - 50 {
                y_axis += 50
                x_axis = 0
            }
        }
        
        self.view.tag = 256
        buildingHUDView.tag = 500
        combatHUDView.tag = 600
        
        buildingHUDView.alpha = 0
        
        self.view.bringSubviewToFront(self.combatHUDView)
        */
        self.view.bringSubviewToFront(menuButton)
        self.view.bringSubviewToFront(showHUD)
        
    }
    
    @IBOutlet var showHUD: UISwitch!
    
    @IBAction func showFortniteHUD(_ sender: UISwitch) {
        
        if showHUD.isOn {
            //self.view.bringSubviewToFront(self.buildingHUDView)
            //self.view.bringSubviewToFront(self.combatHUDView)
            //self.view.bringSubviewToFront(self.showHUD)
            streamView!.hideControllerButtons()
        } else {
           // self.view.sendSubviewToBack(self.buildingHUDView)
            //self.view.sendSubviewToBack(self.combatHUDView)
            streamView!.showControllerButtons()
        }
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

extension RootViewController: UserInteractionDelegate {
    open func userInteractionBegan() {
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.containerOnScreenController.alpha = 1.0
        }
    }

    open func userInteractionEnded() {
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.containerOnScreenController.alpha = 0.2
        }
    }
}

extension RootViewController: InputPresenceDelegate {
    open func gamepadPresenceChanged() {
        Log.d("gamepadPresenceChanged")
    }

    open func mousePresenceChanged() {
        Log.d("gamepadPresenceChanged")
    }
}

/// Show an web overlay
extension RootViewController: OverlayController {

    /// Show an overlay
    func showOverlay(for address: String?) {
        // early exit
        guard let address = address,
              let url = URL(string: address),
              let config = webView?.configuration else {
            return
        }
        // forward
        _ = createModalWebView(for: URLRequest(url: url), configuration: config)
    }

    /// Internally we create a modal web view and present it
    private func createModalWebView(for urlRequest: URLRequest, configuration: WKWebViewConfiguration) -> WKWebView? {
        // create modal web view
        let modalViewController = UIViewController()
        let modalWebView        = WKWebView(frame: .zero, configuration: configuration)
        modalViewController.view = modalWebView
        modalWebView.customUserAgent = Navigator.Config.UserAgent.chromeDesktop
        modalWebView.load(urlRequest)
        // the navigation view controller with its close button
        let modalNavigationController = UINavigationController(rootViewController: modalViewController)
        modalViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close",
                                                                                style: .done,
                                                                                target: self,
                                                                                action: #selector(self.onOverlayClosePressed))
        present(modalNavigationController, animated: true)
        return modalWebView
    }

    /// Close the overlay
    @objc func onOverlayClosePressed(sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

/// WebView delegates
/// TODO extract this to a separate module with proper abstraction
extension RootViewController: WKNavigationDelegate, WKUIDelegate {

    /// When a page finished loading, inject the controller override script
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // update url
        menu?.updateAddressBar(with: AddressBarInfo(url: webView.url?.absoluteString,
                                                    canGoBack: webView.canGoBack,
                                                    canGoForward: webView.canGoForward))
        // save last visited url
        UserDefaults.standard.lastVisitedUrl = webView.url
    }

    /// Handle popups
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            if navigator.shouldOpenPopup(for: navigationAction.request.url?.absoluteString) {
                let modalWebView = createModalWebView(for: navigationAction.request, configuration: configuration)
                modalWebView?.customUserAgent = webView.customUserAgent
                return modalWebView
            } else {
                webView.load(navigationAction.request)
                return nil
            }
        }
        return nil
    }

    /// After successfully logging in, forward user to stadia
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let navigation = navigator.getNavigation(for: navigationAction.request.url?.absoluteString)
        Log.i("navigation -> \(navigationAction.request.url?.absoluteString ?? "nil") -> \(navigation)")
        webView.customUserAgent = navigation.userAgent
        webViewControllerBridge.exportType = navigation.bridgeType
        decisionHandler(.allow)
    }

}

/// Donation reminding logic
extension RootViewController {
    private func checkDonationReminder() {
        #if APPSTORE
            // has donated already
            if UserDefaults.standard.didDonateAlready {
                return
            }
            // not enough starts
            if UserDefaults.standard.appOpenCount < 5 {
                UserDefaults.standard.appOpenCount = UserDefaults.standard.appOpenCount + 1
                return
            }
            // app open count is due to a reminding alert
            UserDefaults.standard.appOpenCount = 0
            alerter.showAlert(for: .remindToDonate,
                              positiveAction: Alerter.Action(text: "Sure") { [weak self] in
                                  self?.purchaseHelper.showProducts()
                              },
                              negativeAction: Alerter.Action(text: "Nope") {
                              })
        #endif
    }
}
