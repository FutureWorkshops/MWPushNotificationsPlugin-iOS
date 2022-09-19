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
    
    public func perform<T>(task: T, session: ContentProvider, respondOn: DispatchQueue, completion: @escaping (Result<T.Response, Error>) -> Void) where T : AsyncTask {
        if let task = task as? RecurringCreateTask,
           let completion = completion as? ((Result<RecurringCreateTask.Response, Error>) -> Void) {
            self.perform(task: task, session: session, respondOn: respondOn, completion: completion)
        } else if let task = task as? RecurringCancelTask,
                  let completion = completion as? ((Result<RecurringCancelTask.Response, Error>) -> Void) {
            self.perform(task: task, session: session, respondOn: respondOn, completion: completion)
        } else {
            self.notify(result: .failure(ServiceError.cannotPerformTask), on: respondOn, completion: completion)
        }
    }
    
    func perform(task: RecurringCreateTask, session: ContentProvider, respondOn: DispatchQueue, completion: @escaping (Result<RecurringCreateTask.Response, Error>) -> Void) {
        
        guard let rrule = RRule(rrule: task.input.recurrenceRule) else {
            self.notify(result: .failure(ParseError.invalidStepData(cause: "Invalid RRULE")), on: respondOn, completion: completion)
            return
        }
        
        let triggers = rrule.notificationTriggers().prefix(10)
        
        let notificationCenter: UNUserNotificationCenter = .current()
        
        if triggers.count > 0 {
            notificationCenter.removeAllPendingNotificationRequests()
        }
        
        for trigger in triggers {
            var notificationContent = UNMutableNotificationContent()
            notificationContent.title = task.input.notificationTitle ?? ""
            notificationContent.body = task.input.notificationText ?? ""
            
            let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString,
                                                            content: notificationContent,
                                                            trigger: trigger)
            notificationCenter.add(notificationRequest) { error in
                if let error = error {
                    self.notify(result: .failure(error), on: respondOn, completion: completion)
                } else {
                    print("added notification trigger at \(trigger.dateComponents)")
                }
            }
        }
        
        self.notify(result: .success(true), on: respondOn, completion: completion)
    }
    
    func perform(task: RecurringCancelTask, session: ContentProvider, respondOn: DispatchQueue, completion: @escaping (Result<RecurringCancelTask.Response, Error>) -> Void) {
        
        let notificationCenter: UNUserNotificationCenter = .current()
        notificationCenter.removeAllPendingNotificationRequests()
        
        self.notify(result: .success(true), on: respondOn, completion: completion)
    }
    
}
