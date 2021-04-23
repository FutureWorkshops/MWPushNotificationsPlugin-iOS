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

class SceneDelegate: MWSceneDelegate {

    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        self.dependencies.plugins = [MWPushNotificationsPlugin.self]
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
}
