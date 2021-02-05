// Copyright (c) 2020 Nomad5. All rights reserved.

import Foundation
import WebKit

/// Infix operator declaration
infix operator =~: ComparisonPrecedence

@objc enum ControlsSource: Int {
    case onScreen
    case external
}

/// Protocol to handle incoming cloudy controller sources
@objc protocol ControllerDataReceiver {
    @objc func submit(controllerData: CloudyController, for type: ControlsSource)
}

/// Main module that connects the web views controller scripts to the native controller handling
class WebViewControllerBridge: NSObject, WKScriptMessageHandlerWithReply, ControllerDataReceiver {

    /// Alias for the reply type back to the webWiew
    typealias ReplyHandlerType = (Any?, String?) -> Void

    private var controllerData:                 [ControlsSource: CloudyController] = [:]

    /// Remember last controller snapshot
    private var lastExternalControllerSnapshot: CloudyController?                  = nil
    private var lastTouchControllerSnapShot:    CloudyController?                  = nil

    /// current export type
    var exportType:     CloudyController.JsonType = .regular

    /// the controls source to use
    var controlsSource: ControlsSource            = .external

    /// Handle user content controller with proper native controller data reply
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage,
                               replyHandler: @escaping ReplyHandlerType) {
        // only execute if the correct message was received
        guard message.name == FullScreenWKWebView.messageHandlerName else {
            Log.e("Unknown message received: \(message)")
            replyHandler(nil, nil)
            return
        }
        // return value depending on configuration
        switch (controlsSource) {
            case .onScreen:
                handleTouchController(with: replyHandler)
            case .external:
                handleRegularController(with: replyHandler)
        }
    }

    /// Handle regular external controller
    private func handleRegularController(with replyHandler: @escaping ReplyHandlerType) {
        #if NON_APPSTORE
            // early exit
            guard let currentControllerState = GCController.controllers().first?.extendedGamepad,
                  let currentCloudyController = currentControllerState.toCloudyController() else {
                replyHandler(nil, nil)
                return
            }
            // proceed
            if let lastControllerState = lastExternalControllerSnapshot,
               lastControllerState =~ currentCloudyController {
                replyHandler(nil, nil)
                return
            }
            // update and save
            lastExternalControllerSnapshot = currentCloudyController
            replyHandler(currentCloudyController.toJson(for: exportType), nil)
        #else
            replyHandler(nil, nil)
        #endif
    }

    /// Handle touch controller
    private func handleTouchController(with replyHandler: @escaping ReplyHandlerType) {
        // early exit
        guard let currentControllerData = controllerData[.onScreen] else {
            replyHandler(nil, nil)
            return
        }
        // nothing changed, skip
        if let lastControllerData = lastTouchControllerSnapShot,
           lastControllerData =~ currentControllerData {
            replyHandler(nil, nil)
            return
        }
        // update and save
        lastTouchControllerSnapShot = currentControllerData
        replyHandler(currentControllerData.toJson(for: exportType), nil)
    }

    /// Receive the controller data
    func submit(controllerData: CloudyController, for type: ControlsSource) {
        self.controllerData[type] = controllerData
    }
}
