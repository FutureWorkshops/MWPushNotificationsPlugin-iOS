//
//  MWPushNotificationsStep.swift
//  MWPushNotificationsPlugin
//
//  Created by Xavi Moll on 9/12/20.
//

import Foundation
import MobileWorkflowCore
import UIKit

public class MWPushNotificationsStep: MWStep, InstructionStep {
    
    public var imageURL: String?
    public var image: UIImage? { nil }
    public let session: Session
    public let services: StepServices
    
    init(identifier: String, session: Session, services: StepServices) {
        self.session = session
        self.services = services
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func instantiateViewController() -> StepViewController {
        MWPushNotificationsViewController(instructionStep: self)
    }
}

extension MWPushNotificationsStep: BuildableStep {
    
    public static var mandatoryCodingPaths: [CodingKey] { [] }
    
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        let newStep = MWPushNotificationsStep(identifier: stepInfo.data.identifier, session: stepInfo.session, services: services)
        newStep.text = stepInfo.data.content["text"] as? String
        newStep.imageURL = stepInfo.data.content["imageURL"] as? String
        return newStep
    }
}
