//
//  CancelRecurringStep.swift
//  MWPushNotificationsPlugin
//
//  Created by Pedro Sebastião on 30/08/2022.
//

import UIKit
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

public class NotificationsCancelRecurringMetadata: StepMetadata {
    enum CodingKeys: CodingKey {
        case text
        case imageURL
    }
    
    let text: String
    let imageURL: String?
    
    init(id: String, title: String, text: String, imageURL: String?, next: PushLinkMetadata?, links: [LinkMetadata]) {
        self.text = text
        self.imageURL = imageURL
        super.init(id: id, type: "io.app-rail.push-notifications.cancel-recurring", title: title, next: next, links: links)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.text, forKey: .text)
        try container.encodeIfPresent(self.imageURL, forKey: .imageURL)
        try super.encode(to: encoder)
    }
}

public extension StepMetadata {
    static func notificationsCancelRecurring(
        id: String,
        title: String,
        text: String,
        imageURL: String? = nil,
        next: PushLinkMetadata? = nil,
        links: [LinkMetadata] = []
    ) -> NotificationsCancelRecurringMetadata {
        return NotificationsCancelRecurringMetadata(id: id, title: title, text: text, imageURL: imageURL, next: next, links: links)
    }
}
