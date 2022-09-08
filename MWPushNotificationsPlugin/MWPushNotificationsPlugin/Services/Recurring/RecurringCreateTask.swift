//
//  RecurringCreateTask.swift
//  MWPushNotificationsPlugin
//
//  Created by Pedro Sebastião on 30/08/2022.
//

import Foundation
import MobileWorkflowCore

struct RecurringCreateTask: AsyncTask {
    struct Input {
        let recurrenceRule: String
        let notificationTitle: String?
        let notificationText: String?
    }
    
    typealias Response = Bool
    
    let input: Self.Input
}

