//
//  MWPushNotificationsStep.swift
//  MWPushNotificationsPlugin
//
//  Created by Xavi Moll on 9/12/20.
//

import Foundation
import MobileWorkflowCore

public class MWPushNotificationsStep: ORKStep {
    
    override init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func stepViewControllerClass() -> AnyClass {
        return MWPushNotificationsViewController.self
    }
}

extension MWPushNotificationsStep: MobileWorkflowStep {
    public static func build(step: StepInfo, services: MobileWorkflowServices) throws -> ORKStep {
        let newStep = MWPushNotificationsStep(identifier: step.data.identifier)
        #warning("This should be done by default on the MobileWorkflowStep, but for some reason the .text was always nil")
        newStep.text = step.data.content["text"] as? String
        return newStep
    }
}
