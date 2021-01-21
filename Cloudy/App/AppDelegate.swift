// Copyright (c) 2020 Nomad5. All rights reserved.

import UIKit
import AVFoundation

#if NON_APPSTORE
    import Firebase
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize firebase
        #if NON_APPSTORE
            FirebaseApp.configure()
        #endif
        // Start observing in app purchases
        IAPManager.shared.startObserving()
        // request mic permissions TODO disabled for now
//        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
//        AVCaptureDevice.requestAccess(for: .video) { _ in }
//        AVCaptureDevice.requestAccess(for: .audio) { _ in }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        IAPManager.shared.stopObserving()
    }
}

