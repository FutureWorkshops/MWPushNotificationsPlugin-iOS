//
//  SceneDelegate.swift
//  MWPushNotifications
//
//  Created by Xavi Moll on 9/12/20.
//  Copyright © 2020 Future Workshops. All rights reserved.
//

import UIKit
import MWPushNotificationsPlugin
import MobileWorkflowCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    enum SessionUserInfoKey {
        static let authRedirectHandler = "authRedirectHandler"
    }
    
    var window: UIWindow?
    private var urlSchemeManagers: [URLSchemeManager] = []
    private var rootViewController: MobileWorkflowRootViewController!
    
    private var appDelegate: AppDelegate? { UIApplication.shared.delegate as? AppDelegate }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let eventService = EventServiceImplementation()
        self.appDelegate?.eventDelegate = eventService
        
        let networkService = NetworkServiceImplementation(authRedirectHandler: eventService.authRedirectHandler())
        
        let manager = AppConfigurationManager(
            withPlugins: [MWPushNotificationsPlugin.self],
            fileManager: FileManager.default,
            networkService: networkService,
            eventService: eventService
        )
        let preferredConfigurations = self.preferredConfigurations(urlContexts: connectionOptions.urlContexts)
        self.rootViewController = MobileWorkflowRootViewController(manager: manager, preferredConfigurations: preferredConfigurations)
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = self.rootViewController
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let context = self.urlSchemeManagers.firstValidConfiguration(from: URLContexts) else { return }
        self.rootViewController.loadAppConfiguration(context)
    }
}

extension SceneDelegate {
    
    private func preferredConfigurations(urlContexts: Set<UIOpenURLContext>) -> [AppConfigurationContext] {
        
        var preferredConfigurations = [AppConfigurationContext]()
        
        if let appPath = Bundle.main.path(forResource: "app", ofType: "json") {
            preferredConfigurations.append(.file(path: appPath, serverId: nil, workflowId: nil, sessionValues: nil))
        }
        
        return preferredConfigurations
    }
}
