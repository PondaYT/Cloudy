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
class RootViewController: UIViewController, MenuActionsHandler, MainViewController {

    /// Dependency injections
    private var assembler:                 Assembler!
    private var alerter:                   Alerter!
    private var purchaseHelper:            IAPPurchaseHelper!
    private var onScreenControlsExtension: OscExtension?

    /// Main injection
    func inject(assembler: Assembler) {
        self.assembler = assembler
        alerter = assembler.resolve()
        purchaseHelper = assembler.resolve()
        onScreenControlsExtension = assembler.resolve()
    }

    /// Containers
    @IBOutlet var containerWebView:              UIView!
    @IBOutlet var containerHud:                  UIView!
    @IBOutlet var containerOnScreenController:   UIView!
    @IBOutlet var launchAnimation:               UIView!
    @IBOutlet var gameBar:                       UIView!

    /// Interactive views
    @IBOutlet var menuButton:                    UIButton!
    @IBOutlet var showOnScreenControlsExtension: UISwitch!
    @IBOutlet var fortniteHUDVisibilityButton:   UIButton!
    @IBOutlet var visibilitySwitchButton:        UIButton!
    @IBOutlet var tutorialSwitchButton:          UIButton!

    @IBOutlet var webviewConstraints: [NSLayoutConstraint]!
    
    /// Game bar pull out / push away constraint
    @IBOutlet var gameBarArrangement: NSLayoutConstraint!

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
    
    /// Determines if the app is already launched and should animate or not.
    private var launched                         = false
    
    /// Determines if fortnite HUD is visible or not
    private var fortniteHUDIsVisible             = true
    
    /// Determines if Game Bar is expanded or not
    private var expanded             = true

    /// Access to the main view controller
    var viewController: UIViewController {
        self
    }

    #if !APPSTORE
        /// The stream view that holds the on screen controls
        private var streamView: StreamView?

        /// Touch feedback generator
        private lazy var touchFeedbackGenerator: TouchFeedbackGenerator = {
            AVFoundationVibratingFeedbackGenerator()
        }()

    #endif

    /// Expose the web controller for navigation
    var webController:  WebController? {
        webView
    }

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
        #if NON_APPSTORE
            config.userContentController.addScriptMessageHandler(webViewControllerBridge, contentWorld: WKContentWorld.page, name: "controller")
            if UserDefaults.standard.injectControllerScripts {
                config.userContentController.addUserScript(.controller)
            }
        #endif
        return config
    }

    /// Invoked before view is visible
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #if APPSTORE
            containerHud.removeFromSuperview()
            
        #endif
        #if !REKAIROS
            showOnScreenControlsExtension.removeFromSuperview()
            launchAnimation.alpha = 0
            gameBar.alpha = 0
        #endif
        #if REKAIROS
            if !launched {
                containerWebView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            }
            self.view.bringSubviewToFront(launchAnimation)
            gameBar.layer.cornerRadius = 30
            fortniteHUDVisibilityButton.layer.cornerRadius = 55/2
            visibilitySwitchButton.layer.cornerRadius = 55/2
            tutorialSwitchButton.layer.cornerRadius = 55/2
        
            fortniteHUDVisibilityButton.clipsToBounds = true
            visibilitySwitchButton.clipsToBounds = true
            tutorialSwitchButton.clipsToBounds = true
        #endif
    }

    /// View layout already done
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        // NASTY HACK, if we are coming back from overlaying view controller,
        // it will not appear animated anymore
        if animated {
            initializeViews()
        } else {
            createOnScreenControls()
        }
        checkDonationReminder()
        
        #if REKAIROS
        if !launched {
            UIView.animate(withDuration: 2, delay: 1, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                    self.containerWebView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    self.launchAnimation.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
                    self.launchAnimation.alpha = 0
            })
            launched = true
        }
        #endif
    }

    /// Initialize all the required views (webview, onscreen controls and menu)
    func initializeViews() {
        createWebview()
        createOnScreenControls()
        createMenu()
    }

    /// Update visibility of onscreen controller
    func updateOnScreenController(with value: OnScreenControlsLevel) {
        containerHud.alpha = value == .off ? 0 : 1
        webViewControllerBridge.controlsSource = value == .off ? .external : .onScreen
        #if NON_APPSTORE
            streamView?.updateOnScreenControls()
        #endif
    }

    /// Update touch feedback change
    func updateTouchFeedbackType(with value: TouchFeedbackType) {
        #if NON_APPSTORE
            touchFeedbackGenerator.setFeedbackType(value)
        #endif
    }

    /// Update the scaling factor
    func updateScalingFactor(with value: Int) {
        webviewConstraints.forEach { $0.constant = CGFloat(value) }
    }

    /// Handle code injection
    func injectCustom(code: String) {
        webView?.inject(scripts: [code])
    }
    
    func expandGameBar() {
        gameBarArrangement.constant = 8
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func shrinkGameBar() {
        gameBarArrangement.constant = -180
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    
    @IBAction func changeGameBarVisibility() {
        if expanded {
            shrinkGameBar()
            expanded = false
        } else {
            expandGameBar()
            expanded = true
        }
    }
    
    @IBAction func presentTutorialView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            let fortniteLayoutToolViewController = storyboard.instantiateViewController(withIdentifier: "iPadFortniteTutorialView")
            self.present(fortniteLayoutToolViewController, animated: true, completion:nil)
        } else {
            let fortniteLayoutToolViewController = storyboard.instantiateViewController(withIdentifier: "iPhoneFortniteTutorialView")
            self.present(fortniteLayoutToolViewController, animated: true, completion:nil)
            
        }
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
        menuViewController.adService = assembler.resolve()
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
        #if !APPSTORE
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
                                          hapticFeedback: touchFeedbackGenerator,
                                          extensionDelegate: onScreenControlsExtension)
            newStreamView.showOnScreenControls()
            containerOnScreenController.addSubview(newStreamView)
            newStreamView.fillParent()
            streamView = newStreamView
            updateOnScreenController(with: UserDefaults.standard.onScreenControlsLevel)
            updateScalingFactor(with: UserDefaults.standard.webViewScale)
        #endif
    }

    /// Show the fortnite hud overlay
    /*
    @IBAction func mixinOnScreenControlsExtension(_ sender: UISwitch) {
        #if !APPSTORE
            streamView?.mixinControllerExtension(showOnScreenControlsExtension.isOn)
        #endif
    }*/
    
    @IBAction func mixinOnScreenControlsExtension() {
        #if !APPSTORE
        let controllerImage = UIImage(systemName: "gamecontroller.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .default))
        let HUDImage = UIImage(systemName: "circle.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 31, weight: .regular, scale: .default))
        fortniteHUDVisibilityButton.setImage(fortniteHUDIsVisible ? controllerImage : HUDImage, for: .normal)
        streamView?.mixinControllerExtension(fortniteHUDIsVisible)
        fortniteHUDIsVisible = !fortniteHUDIsVisible
        #endif
    }

}

extension RootViewController: UserInteractionDelegate {
    open func userInteractionBegan() {
        #if !REKAIROS
            UIView.animate(withDuration: 0.4) { [weak self] in
                self?.containerOnScreenController.alpha = 1.0
            }
        #endif
    }

    open func userInteractionEnded() {
        #if !REKAIROS
            UIView.animate(withDuration: 0.4) { [weak self] in
                self?.containerOnScreenController.alpha = 0.2
            }
        #endif
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
