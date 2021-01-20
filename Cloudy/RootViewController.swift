// Copyright (c) 2020 Nomad5. All rights reserved.

import UIKit
import WebKit

/// Extend web kit view to not have any insets, thus full fullscreen
class FullScreenWKWebView: WKWebView {
    override var safeAreaInsets: UIEdgeInsets {
        .zero
    }
}

/// Listen to changed settings in menu
protocol MenuActionsHandler {
        func updateOnScreenController(with value: OnScreenControlsLevel)
        func updateTouchFeedbackType(with value: TouchFeedbackType)
        func injectCustom(code: String)
    func updateScalingFactor(with value: Int)
}

/// The main view controller
/// TODO way too big, refactor asap
class RootViewController: UIViewController, MenuActionsHandler {

    /// Containers
    @IBOutlet var containerWebView:            UIView!
    @IBOutlet var containerOnScreenController: UIView!

    @IBOutlet var webviewContstraints: [NSLayoutConstraint]!

    /// The hacked webView
    private var  webView:                                     FullScreenWKWebView!
    private let  navigator:                                   Navigator       = Navigator()

    /// The menu controller
    private var  menu:                                        MenuController? = nil

    /// The bridge between controller and web view
        private let webViewControllerBridge = WebViewControllerBridge()

        /// The stream view that holds the on screen controls
        private var streamView: StreamView?

        /// Touch feedback generator
        private lazy var touchFeedbackGenerator: TouchFeedbackGenerator = {
            AVFoundationVibratingFeedbackGenerator()
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
    private lazy var webViewConfig: WKWebViewConfiguration = {
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
            config.userContentController.addUserScript(WKUserScript(source: Scripts.standaloneOverride,
                                                                    injectionTime: .atDocumentEnd,
                                                                    forMainFrameOnly: true))
        }
            config.userContentController.addScriptMessageHandler(webViewControllerBridge, contentWorld: WKContentWorld.page, name: "controller")
            if UserDefaults.standard.injectControllerScripts {
                config.userContentController.addUserScript(WKUserScript(source: Scripts.controllerOverride(),
                                                                        injectionTime: .atDocumentEnd,
                                                                        forMainFrameOnly: true))
            }
        return config
    }()

    /// View will be shown shortly
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure webView
        webView = FullScreenWKWebView(frame: view.bounds, configuration: webViewConfig)
        webView.translatesAutoresizingMaskIntoConstraints = false
        containerWebView.addSubview(webView)
        webView.fillParent()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        // initial
        if let lastVisitedUrl = UserDefaults.standard.lastVisitedUrl {
            webView.navigateTo(url: lastVisitedUrl)
        } else {
            #if NON_APPSTORE
                webView.navigateTo(url: Navigator.Config.Url.googleStadia)
            #else
                webView.navigateTo(url: Navigator.Config.Url.google)
            #endif
        }
        // menu view controller
        let menuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menu = menuViewController
        menuViewController.view.alpha = 0
        menuViewController.webController = webView
        menuViewController.overlayController = self
        menuViewController.menuActionsHandler = self
        menuViewController.view.frame = view.bounds
        menuViewController.willMove(toParent: self)
        addChild(menuViewController)
        view.addSubview(menuViewController.view)
        menuViewController.didMove(toParent: self)
    }

    /// View layout already done
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            // stream config
            let streamConfig      = StreamConfiguration()
            // Controller support
            let controllerSupport = ControllerSupport(config: streamConfig,
                                                      presenceDelegate: self,
                                                      controllerDataReceiver: webViewControllerBridge)
            // stream view
            let streamView        = StreamView(frame: containerOnScreenController.bounds)
            streamView.setupStreamView(controllerSupport, interactionDelegate: self, config: streamConfig, hapticFeedback: touchFeedbackGenerator)
            streamView.showOnScreenControls()
            containerOnScreenController.addSubview(streamView)
            streamView.fillParent()
            self.streamView = streamView
            updateOnScreenController(with: UserDefaults.standard.onScreenControlsLevel)
        updateScalingFactor(with: UserDefaults.standard.webViewScale)
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
        webviewContstraints.forEach { $0.constant = CGFloat(value) }
    }

    /// Handle code injection
    func injectCustom(code: String) {
        webView.inject(scripts: [code])
    }

    /// Tapped on the menu item
    @IBAction func onMenuButtonPressed(_ sender: Any) {
        menu?.show()
    }
}

    extension RootViewController: UserInteractionDelegate {
        open func userInteractionBegan() {
            Log.d("userInteractionBegan")
        }

        open func userInteractionEnded() {
            Log.d("userInteractionEnded")
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
              let url = URL(string: address) else {
            return
        }
        // forward
        _ = createModalWebView(for: URLRequest(url: url), configuration: webViewConfig)
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
        decisionHandler(.allow)
    }

}
