//
//  MWPushNotificationsStep.swift
//  MWPushNotificationsPlugin
//
//  Created by Xavi Moll on 9/12/20.
//

import Foundation
import MobileWorkflowCore

public class MWPushNotificationsStep: MWStep {
    
    let services: StepServices
    
    init(identifier: String, services: StepServices) {
        self.services = services
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func instantiateViewController() -> StepViewController {
        MWPushNotificationsViewController(step: self)
    }
}

extension MWPushNotificationsStep: BuildableStep {
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        let newStep = MWPushNotificationsStep(identifier: stepInfo.data.identifier, services: services)
        newStep.text = stepInfo.data.content["text"] as? String
        return newStep
    }
}
