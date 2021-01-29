// Copyright (c) 2020 Nomad5. All rights reserved.

import Foundation
import WebKit
import GameController

@objc enum ControlsSource: Int {
    case onScreen
    case external
}

/// Protocol to handle incoming cloudy controller sources
@objc protocol ControllerDataReceiver {
    @objc func submit(controllerData: CloudyController, for type: ControlsSource)
    @objc func enqueue(controllerData: [CloudyController], for type: ControlsSource)
}

/// Main module that connects the web views controller scripts to the native controller handling
class WebViewControllerBridge: NSObject, WKScriptMessageHandlerWithReply, ControllerDataReceiver {

    /// Alias for the reply type back to the webView
    typealias ReplyHandlerType = (Any?, String?) -> Void

    private var controllerDataQueue:            [ControlsSource: Queue<CloudyController>] = [.external: Queue(), .onScreen: Queue()]
    private var controllerData:                 [ControlsSource: CloudyController]        = [:]

    /// Remember last controller snapshot
    private var lastExternalControllerSnapshot: CloudyController?                         = nil
    private var lastTouchControllerSnapShot:    CloudyController?                         = nil

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

    /// Helper to get the controller data to process
    private func getControllerData(for type: ControlsSource) -> CloudyController? {
        if let queueElement = controllerDataQueue[type]?.dequeue() {
            return queueElement
        }
        switch type {
            case .onScreen:
                return controllerData[.onScreen]
            case .external:
                return GCController.controllers().first?.extendedGamepad?.toCloudyController()
        }
    }

    /// Handle regular external controller
    private func handleRegularController(with replyHandler: @escaping ReplyHandlerType) {
        // early exit
        guard let currentCloudyController = getControllerData(for: .external) else {
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
    }

    /// Handle touch controller
    private func handleTouchController(with replyHandler: @escaping ReplyHandlerType) {
        // early exit
        guard let currentControllerData = getControllerData(for: .onScreen) else {
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

    /// Enqueue some commands
    func enqueue(controllerData: [CloudyController], for type: ControlsSource) {
        self.controllerDataQueue[type]?.enqueue(controllerData)
    }
}
