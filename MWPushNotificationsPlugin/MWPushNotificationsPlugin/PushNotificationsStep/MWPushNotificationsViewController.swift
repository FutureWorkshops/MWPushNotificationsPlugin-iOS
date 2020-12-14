//
//  MWPushNotificationsViewController.swift
//  MWPushNotificationsPlugin
//
//  Created by Xavi Moll on 9/12/20.
//

import UIKit
import UserNotifications
import MobileWorkflowCore

public class MWPushNotificationsViewController: MobileWorkflowButtonViewController {
    
    private var pushNotificationsStep: MWPushNotificationsStep {
        guard let pushNotificationsStep = self.step as? MWPushNotificationsStep else {
            preconditionFailure("Unexpected step type. Expecting \(String(describing: MWPushNotificationsStep.self)), got \(String(describing: type(of: self.step)))")
        }
        return pushNotificationsStep
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        #warning("Temporary workaround to retrieve the APNS token")
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRecieveNewAPNSTokenThrough(_:)), name: NSNotification.Name("MWPushNotification.apnsToken"), object: nil)
        
        self.configureWithTitle(self.pushNotificationsStep.title ?? "NO_TITLE", body: self.pushNotificationsStep.text ?? "NO_TEXT", buttonTitle: "Enable") {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
                DispatchQueue.main.async {
                    if success {
                        UIApplication.shared.registerForRemoteNotifications()
                    } else if let error = error {
                        self.show(error)
                    } else {
                        assertionFailure("Failed and had no errors.")
                    }
                }
            }
        }
    }
    
    @objc
    private func didRecieveNewAPNSTokenThrough(_ notification: Notification) {
        guard let token = notification.userInfo?["apns_token"] as? String else {
            preconditionFailure("You must've received a token by now.")
        }
        
        let result = MWPushNotificationsResult(identifier: self.pushNotificationsStep.identifier, apnsToken: token)
        self.addResult(result)
        self.goForward()
    }
    
}
