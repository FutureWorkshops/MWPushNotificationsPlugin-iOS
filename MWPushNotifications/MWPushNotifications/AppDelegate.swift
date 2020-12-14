//
//  AppDelegate.swift
//  MWPushNotifications
//
//  Copyright © Future Workshops. All rights reserved.
//

import UIKit
import MobileWorkflowCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AuthRedirector {

    weak var authFlowResumer: AuthFlowResumer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        connectingSceneSession.userInfo = [SceneDelegate.SessionUserInfoKey.authRedirectHandler: self.authRedirectHandler()]
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return self.handleAuthRedirect(for: url)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        #warning("Temporary workaround to send the APNS token to the Plugin")
        NotificationCenter.default.post(name: NSNotification.Name("MWPushNotification.apnsToken"), object: nil, userInfo: ["apns_token":token])
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        assertionFailure(error.localizedDescription)
    }

}
