//
//  MWPushNotificationsViewController.swift
//  MWPushNotificationsPlugin
//
//  Created by Xavi Moll on 9/12/20.
//

import UIKit
import UserNotifications
import MobileWorkflowCore

public class MWPushNotificationsViewController: ORKStepViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            DispatchQueue.main.async {
                if success {
                    UIApplication.shared.registerForRemoteNotifications()
                } else if let error = error {
                    assertionFailure(error.localizedDescription)
                } else {
                    assertionFailure("Failed and had no errors.")
                }
            }
        }
    }
    
}
