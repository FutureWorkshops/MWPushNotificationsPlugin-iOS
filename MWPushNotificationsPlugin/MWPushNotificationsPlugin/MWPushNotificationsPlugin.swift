//
//  MWPushNotificationsPlugin.swift
//  MWPushNotificationsPlugin
//
//  Created by Xavi Moll on 9/12/20.
//

import Foundation
import MobileWorkflowCore

public struct MWPushNotificationsPlugin: MobileWorkflowPlugin {
    public static var allStepsTypes: [MobileWorkflowStepType] {
        return MWPushNotificationsStepType.allCases
    }
}

public enum MWPushNotificationsStepType: String, MobileWorkflowStepType, CaseIterable {
    
    case pushNotifications = "io.mobileworkflow.NotificationPermission"
    
    public var typeName: String {
        return self.rawValue
    }
    
    public var stepClass: MobileWorkflowStep.Type {
        switch self {
        case .pushNotifications: return MWPushNotificationsStep.self
        }
    }
}
