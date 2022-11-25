//
//  MWPushNotificationsStep.swift
//  MWPushNotificationsPlugin
//
//  Created by Xavi Moll on 9/12/20.
//

import Foundation
import MobileWorkflowCore
import UIKit

public class MWPushNotificationsStep: ObservableStep, InstructionStep {
    
    public let imageURL: String?
    public var image: UIImage? { nil }
    public let enableText: String?
    public let skipText: String?
    
    init(identifier: String, text: String?, imageURL: String?, enableText: String?, skipText: String?, session: Session, services: StepServices) {
        self.enableText = enableText
        self.skipText = skipText
        self.imageURL = imageURL
        super.init(identifier: identifier, session: session, services: services)
        self.text = text
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
        MWPushNotificationsStep(
            identifier: stepInfo.data.identifier,
            text: stepInfo.data.content["text"] as? String,
            imageURL: stepInfo.data.content["imageURL"] as? String,
            enableText: stepInfo.data.content["enableText"] as? String,
            skipText: stepInfo.data.content["skipText"] as? String,
            session: stepInfo.session,
            services: services
        )
    }
}
