//
//  RecurringService.swift
//  MWPushNotificationsPlugin
//
//  Created by Pedro Sebastião on 30/08/2022.
//

import Foundation
import MobileWorkflowCore

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
            return try await self.performRecurring(task: task, session: session) as! T.Response
        } else if let task = task as? RecurringCancelTask {
            return try await self.performCancel(task: task, session: session) as! T.Response
        } else {
            throw ServiceError.cannotPerformTask
        }
    }
    
    func performRecurring(task: RecurringCreateTask, session: ContentProvider) async throws -> RecurringCreateTask.Response {
        guard let rrule = RRule(rrule: task.input.recurrenceRule) else {
            throw ParseError.invalidStepData(cause: "Invalid RRULE")
        }
        
        let triggers = rrule.notificationTriggers().prefix(10)
        
        let notificationCenter: UNUserNotificationCenter = .current()
        
        if triggers.count > 0 {
            notificationCenter.removeAllPendingNotificationRequests()
        } else {
            return true
        }
        
        
        return try await withThrowingTaskGroup(of: Bool.self) { group in
            for trigger in triggers {
                var notificationContent = UNMutableNotificationContent()
                notificationContent.title = task.input.notificationTitle ?? ""
                notificationContent.body = task.input.notificationText ?? ""
                
                let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString,
                                                                content: notificationContent,
                                                                trigger: trigger)
                
                group.addTask {
                    try await withCheckedThrowingContinuation { continuation in
                        notificationCenter.add(notificationRequest) { error in
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else {
                                continuation.resume(returning: true)
                            }
                        }
                    }
                }
            }
            
            var response = true
            for try await taskResponse in group {
                response = taskResponse && response
            }
            return response
        }
    }
    
    func performCancel(task: RecurringCancelTask, session: ContentProvider) async throws -> RecurringCancelTask.Response {
        let notificationCenter: UNUserNotificationCenter = .current()
        notificationCenter.removeAllPendingNotificationRequests()
        return true
    }
    
}
