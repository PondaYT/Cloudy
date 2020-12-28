// Copyright (c) 2020 Nomad5. All rights reserved.

import Foundation

struct Scripts {

    /// Override that its a standalone app
    static let standaloneOverride = "Object.defineProperty(navigator, 'standalone', {get:function(){return true;}});"

    #if NON_APPSTORE
        /// The script to be injected into the webview
        /// It's overwriting the navigator.getGamepads function
        /// to make the connection with the native GCController solid
        static func controllerOverride() -> String {
            """
            var emulatedGamepad = {
                id: "\(UserDefaults.standard.controllerId.chromeFormat())",
                index: 0,
                connected: true,
                timestamp: 0.0,
                mapping: "standard",
                axes: [0.0, 0.0, 0.0, 0.0],
                buttons: new Array(17).fill().map((m) => {
                     return { pressed: false, touched: false, value: 0 }
                })
            }


            navigator.getGamepads = function() {
                window.webkit.messageHandlers.controller.postMessage({}).then((controllerData) => {
                    if (controllerData === null || controllerData === undefined) return;
                    try {
                        var data = JSON.parse(controllerData);
                        for(let i = 0; i < data.axes.length; i++) {
                            emulatedGamepad.axes[i] = data.axes[i];
                        }
                        for(let i = 0; i < data.buttons.length; i++) {
                            emulatedGamepad.buttons[i].pressed = data.buttons[i].pressed;
                            emulatedGamepad.buttons[i].touched = data.buttons[i].touched;
                            emulatedGamepad.buttons[i].value   = data.buttons[i].value;
                        }
                        emulatedGamepad.timestamp = performance.now();
                             emulatedGamepad.id        = data.id;
                             // console.log(emulatedGamepad);
                    } catch(e) { 
                        console.error("something went wrong: " + e);  
                    }
                });
                return [emulatedGamepad, null, null, null];
            };
            """
        }
    #endif
}
