//
//  RecurringStep.swift
//  MWPushNotificationsPlugin
//
//  Created by Pedro Sebastião on 30/08/2022.
//

import Foundation
import MobileWorkflowCore

public class RecurringStep: MWStep, InstructionStep {
    
    public let imageURL: String?
    public let image: UIImage? = nil
    
    public let recurrenceRule: String
    public let notificationTitle: String?
    public let notificationText: String?
    
    public let session: Session
    public let services: StepServices
    
    init(identifier: String,
         text: String? = nil,
         imageURL: String? = nil,
         recurrenceRule: String,
         notificationTitle: String? = nil,
         notificationText: String? = nil,
         session: Session,
         services: StepServices) {
        self.imageURL = imageURL
        self.recurrenceRule = recurrenceRule
        self.notificationTitle = notificationTitle
        self.notificationText = notificationText
        self.session = session
        self.services = services
        super.init(identifier: identifier, text: text)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func instantiateViewController() -> StepViewController {
        RecurringStepViewController(instructionStep: self)
    }
}

extension RecurringStep: BuildableStep {
    
    public static var mandatoryCodingPaths: [CodingKey] { ["recurrenceRule"] }
    
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        let text = stepInfo.data.content["text"] as? String
        let imageURL = stepInfo.data.content["imageURL"] as? String
        let recurrenceRule = stepInfo.data.content["recurrenceRule"] as! String // validation is handled before by `mandatoryCodingPaths`
        let notificationTitle = stepInfo.data.content["notificationTitle"] as? String
        let notificationText = stepInfo.data.content["notificationText"] as? String
        
        let newStep = RecurringStep(identifier: stepInfo.data.identifier,
                                    text: text,
                                    imageURL: imageURL,
                                    recurrenceRule: recurrenceRule,
                                    notificationTitle: notificationTitle,
                                    notificationText: notificationText,
                                    session: stepInfo.session,
                                    services: services)
    
        return newStep
    }
}
