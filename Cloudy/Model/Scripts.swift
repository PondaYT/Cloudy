// Copyright (c) 2020 Nomad5. All rights reserved.

import Foundation

struct Scripts {

    /// Override that its a standalone app
    static let standaloneOverride = "Object.defineProperty(navigator, 'standalone', {get:function(){return true;}});"

    /// The script to be injected into the webview
    /// It's overwriting the navigator.getGamepads function
    /// to make the connection with the native GCController solid
    /// https://jsfiddle.net/mlostek/2g3f7kmy/100/
    // clang-format off
    static func controllerOverride() -> String { """
                                                 /// The default gamepad
                                                 var emulatedGamepad = {
                                                   id: "\(UserDefaults.standard.controllerId.chromeFormat())",
                                                   index: 0,
                                                   connected: true,
                                                   timestamp: 0.0,
                                                   mapping: "standard",
                                                   axes: [0.0, 0.0, 0.0, 0.0],
                                                   buttons: new Array(17).fill().map((m) => {
                                                     return {
                                                       pressed: false,
                                                       touched: false,
                                                       value: 0
                                                     }
                                                   })
                                                 };
                                                                                                  
                                                 /// The gamepad queue for a specific sequence 
                                                 var emulatedGamepadQueue = [];

                                                 /// Parse the json value 
                                                 function parseControllerJson(controllerJson) {
                                                   try {
                                                     var controllerObject = JSON.parse(controllerJson);
                                                     controllerObject.timestamp = performance.now();
                                                     return controllerObject;
                                                   } catch (error) {
                                                     console.error("something went wrong: " + error);
                                                   }
                                                 }

                                                 /// New data incoming
                                                 function handleNativeControllerData(controllerData) {
                                                   // early exit
                                                   if (controllerData === null || controllerData === undefined) return;
                                                   // If there is an array, enqueue
                                                   if (Array.isArray(controllerData)) {
                                                     controllerData.forEach((controllerElement) => {
                                                       let controllerObject = parseControllerJson(controllerElement);
                                                       emulatedGamepadQueue.push(controllerObject);
                                                     });
                                                     return;
                                                   }
                                                   // if its a single value, simply set that
                                                   emulatedGamepad = parseControllerJson(controllerData);
                                                 }

                                                 /// Retrieve the correct gamepad values
                                                 function getCorrectGamepad() {
                                                   if (emulatedGamepadQueue.length > 0) {
                                                     return emulatedGamepadQueue.shift();
                                                   }
                                                   return emulatedGamepad;
                                                 }

                                                 /// ORIGINAL NAVIGATOR FUNCTION THAT IS CALLED FROM THE PLATFORM
                                                 navigator.getGamepads = function() {
                                                   window.webkit.messageHandlers.controller.postMessage({}).then(handleNativeControllerData);
                                                   let currentGamepad = getCorrectGamepad();
                                                   return [currentGamepad, null, null, null];
                                                 };
                                                 """ }
    // clang-format on
}
