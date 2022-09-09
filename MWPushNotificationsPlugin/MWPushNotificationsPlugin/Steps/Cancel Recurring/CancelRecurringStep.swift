//
//  CancelRecurringStep.swift
//  MWPushNotificationsPlugin
//
//  Created by Pedro Sebastião on 30/08/2022.
//

import Foundation
import MobileWorkflowCore

public class CancelRecurringStep: MWStep, InstructionStep {
    
    public let imageURL: String?
    public let image: UIImage? = nil
    
    public let session: Session
    public let services: StepServices
    
    init(identifier: String,
         text: String? = nil,
         imageURL: String? = nil,
         session: Session,
         services: StepServices) {
        self.imageURL = imageURL
        self.session = session
        self.services = services
        super.init(identifier: identifier, text: text)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func instantiateViewController() -> StepViewController {
        CancelRecurringStepViewController(instructionStep: self)
    }
}

extension CancelRecurringStep: BuildableStep {
    
    public static var mandatoryCodingPaths: [CodingKey] = []
    
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        let text = stepInfo.data.content["text"] as? String
        let imageURL = stepInfo.data.content["imageURL"] as? String
        
        let newStep = CancelRecurringStep(identifier: stepInfo.data.identifier,
                                          text: text,
                                          imageURL: imageURL,
                                          session: stepInfo.session,
                                          services: services)
    
        return newStep
    }
}
