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
    @objc func enqueue(controllerData: [CloudyController], for type: ControlsSource)
}

/// Main module that connects the web views controller scripts to the native controller handling
class WebViewControllerBridge: NSObject, WKScriptMessageHandlerWithReply, ControllerDataReceiver {

    /// Alias for the reply type back to the webView
    typealias ReplyHandlerType = (Any?, String?) -> Void

    private var controllerDataQueue: [ControlsSource: [CloudyController]] = [.external: [], .onScreen: []]
    private var controllerData:      [ControlsSource: CloudyController]   = [:]
    private var controllerSnapshots: [ControlsSource: CloudyController]   = [:]

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
        // check if we have a queue for the current control source
        if let currentControllerQueue = controllerDataQueue[controlsSource],
           !currentControllerQueue.isEmpty {
            let stringifiedQueue = currentControllerQueue.map { $0.toJson(for: exportType) }
            controllerDataQueue[controlsSource]?.removeAll()
            replyHandler(stringifiedQueue, nil)
            return
        }
        // early exit for regular controller
        guard let currentCloudyController = getControllerData(for: controlsSource) else {
            replyHandler(nil, nil)
            return
        }
        // did something change since the last snapshot?
        if let lastControllerState = controllerSnapshots[controlsSource],
           lastControllerState =~ currentCloudyController {
            replyHandler(nil, nil)
            return
        }
        // update and save
        controllerSnapshots[controlsSource] = currentCloudyController
        replyHandler(currentCloudyController.toJson(for: exportType), nil)
    }

    /// Helper to get the controller data to process
    private func getControllerData(for type: ControlsSource) -> CloudyController? {
        switch type {
            case .onScreen:
                return controllerData[.onScreen]
            case .external:
                #if !APPSTORE
                    return GCController.controllers().first?.extendedGamepad?.toCloudyController()
                #else
                    return nil
                #endif
        }
    }

    /// Receive the controller data
    func submit(controllerData: CloudyController, for type: ControlsSource) {
        self.controllerData[type] = controllerData
    }

    /// Enqueue some commands
    func enqueue(controllerData: [CloudyController], for type: ControlsSource) {
        self.controllerDataQueue[type]?.append(contentsOf: controllerData)
    }
}
