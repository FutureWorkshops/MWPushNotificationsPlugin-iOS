//
//  L10n.swift
//  MWPushNotificationsPlugin
//
//  Created by Pedro Sebastião on 08/09/2022.
//

import Foundation


enum L10n {
    enum PushNotification {
        static let generalError = "Unable to register for Push Notifcations."
        static let deniedTitle = "Push Notifications"
        static let deniedText = "You have currently opted out of receiving Push Notifications. You can update this preference in Settings."
        static let deniedCancelTitle = "Skip"
        static let deniedConfirmTitle = "Settings"
        static let enableButtonTitle = "Enable"
        static let skipButtonTitle = "Skip"
    }
    
    enum Recurring {
        static let doneButtonTitle = "Done"
    }
    
}
