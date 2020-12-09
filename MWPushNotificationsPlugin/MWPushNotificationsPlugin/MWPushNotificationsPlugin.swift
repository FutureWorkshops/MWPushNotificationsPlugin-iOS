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
