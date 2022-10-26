//
//  RecurringService.swift
//  MWPushNotificationsPlugin
//
//  Created by Pedro Sebastião on 30/08/2022.
//

import Foundation
import MobileWorkflowCore
import UserNotifications

internal class RecurringService: NSObject {
    
    public enum ServiceError: Error {
        case cannotPerformTask
    }
    
    internal var services: StepServices? = nil
}


extension RecurringService: AsyncTaskService {
    
    func configure(stepServices: StepServices?) {
        self.services = stepServices
    }
    
    public func canPerform<T>(task: T) -> Bool where T : AsyncTask {
        return task is RecurringCreateTask
        || task is RecurringCancelTask
    }
    
    func perform<T>(task: T, session: ContentProvider) async throws -> T.Response where T : AsyncTask {
        if let task = task as? RecurringCreateTask {
            return try await self.perform(createTask: task, session: session) as! T.Response
        } else if let task = task as? RecurringCancelTask {
            return try await self.perform(cancelTask: task, session: session) as! T.Response
        } else {
            throw ServiceError.cannotPerformTask
        }
    }
    
    func perform(createTask task: RecurringCreateTask, session: ContentProvider) async throws -> RecurringCreateTask.Response {
        guard let rrule = RRule(rrule: task.input.recurrenceRule) else {
            throw ParseError.invalidStepData(cause: "Invalid RRULE")
        }
        
        let triggers = rrule.notificationTriggers()
        
        guard triggers.count > 0 else {
            // rule did not produce any triggers
            return
        }
        
        let notificationCenter: UNUserNotificationCenter = .current()
        
        notificationCenter.removeAllPendingNotificationRequests()
        
        let notificationTitle = session.resolve(value: task.input.notificationTitle ?? "")
        let notificationBody = session.resolve(value: task.input.notificationText ?? "")
        
        for trigger in triggers {
            var notificationContent = UNMutableNotificationContent()
            notificationContent.title = notificationTitle
            notificationContent.body = notificationBody
            notificationContent.sound = .default
            
            let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString,
                                                            content: notificationContent,
                                                            trigger: trigger)
            
            try await notificationCenter.add(notificationRequest)
        }
    }
    
    func perform(cancelTask task: RecurringCancelTask, session: ContentProvider) async throws -> RecurringCancelTask.Response {
        let notificationCenter: UNUserNotificationCenter = .current()
        notificationCenter.removeAllPendingNotificationRequests()
        return true
    }
    
}

