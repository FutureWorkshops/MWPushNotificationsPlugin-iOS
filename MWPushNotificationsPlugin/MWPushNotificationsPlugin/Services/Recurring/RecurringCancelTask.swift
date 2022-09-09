//
//  RecurringCancelTask.swift
//  MWPushNotificationsPlugin
//
//  Created by Pedro Sebastião on 30/08/2022.
//

import Foundation
import MobileWorkflowCore

struct RecurringCancelTask: AsyncTask {
    typealias Response = Bool
    typealias Input = Void
    let input: Self.Input
    
    init() {
        
    }
}

