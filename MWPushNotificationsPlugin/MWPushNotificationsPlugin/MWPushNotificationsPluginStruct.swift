//
//  MWPushNotificationsPlugin.swift
//  MWPushNotificationsPlugin
//
//  Created by Xavi Moll on 9/12/20.
//

import Foundation
import MobileWorkflowCore

public struct MWPushNotificationsPluginStruct: Plugin {
    
    public static var asyncTaskServices: [AsyncTaskService] = [RecurringService()]
    
    public static var allStepsTypes: [StepType] {
        return MWPushNotificationsStepType.allCases
    }
}

public enum MWPushNotificationsStepType: String, StepType, CaseIterable {
    
    case pushNotifications = "io.mobileworkflow.NotificationPermission"
    case recurring = "io.app-rail.push-notifications.recurring"
    case cancelRecurring = "io.app-rail.push-notifications.cancel-recurring"
    
    public var typeName: String {
        return self.rawValue
    }
    
    public var stepClass: BuildableStep.Type {
        switch self {
        case .pushNotifications: return MWPushNotificationsStep.self
        case .recurring: return RecurringStep.self
        case .cancelRecurring: return CancelRecurringStep.self
        }
    }
}
