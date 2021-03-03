// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import GoogleMobileAds

class GoogleAdSensitives {

    /// Get the ad unit id for the fullscreen ads
    lazy var AdUnitIdFullscreen: String = {
        guard let idFileUrl = Bundle.main.url(forResource: "ID-FullscreenAd", withExtension: "txt", subdirectory: "Sensitive/AdMob"),
              let id = try? String(contentsOf: idFileUrl) else {
            Log.e("No sensitive data found for the fullscreen adUnitId. Returning test id")
            return "ca-app-pub-3940256099942544/4411468910"
        }
        return id
    }()

    /// Get the ad unit id for the native ads
    lazy var AdUnitIdNative: String = {
        guard let idFileUrl = Bundle.main.url(forResource: "ID-NativeAd", withExtension: "txt", subdirectory: "Sensitive/AdMob"),
              let id = try? String(contentsOf: idFileUrl) else {
            Log.e("No sensitive data found for the fullscreen adUnitId. Returning test id")
            return "ca-app-pub-3940256099942544/3986624511"
        }
        return id
    }()
}