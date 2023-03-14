//
//  RecurringStep.swift
//  MWPushNotificationsPlugin
//
//  Created by Pedro Sebastião on 30/08/2022.
//

import UIKit
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

public class NotificationsRecurringMetadata: StepMetadata {
    enum CodingKeys: CodingKey {
        case notificationTitle
        case notificationText
        case recurrenceRule
        case text
        case imageURL
    }
    
    let notificationTitle: String
    let notificationText: String
    let recurrenceRule: String
    let text: String
    let imageURL: String?
    
    init(id: String, title: String, notificationTitle: String, notificationText: String, recurrenceRule: String, text: String, imageURL: String?, next: PushLinkMetadata?, links: [LinkMetadata]) {
        self.notificationTitle = notificationTitle
        self.notificationText = notificationText
        self.recurrenceRule = recurrenceRule
        self.text = text
        self.imageURL = imageURL
        super.init(id: id, type: "io.app-rail.push-notifications.recurring", title: title, next: next, links: links)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.notificationTitle = try container.decode(String.self, forKey: .notificationTitle)
        self.notificationText = try container.decode(String.self, forKey: .notificationText)
        self.recurrenceRule = try container.decode(String.self, forKey: .recurrenceRule)
        self.text = try container.decode(String.self, forKey: .text)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.notificationTitle, forKey: .notificationTitle)
        try container.encode(self.notificationText, forKey: .notificationText)
        try container.encode(self.recurrenceRule, forKey: .recurrenceRule)
        try container.encode(self.text, forKey: .text)
        try container.encodeIfPresent(self.imageURL, forKey: .imageURL)
        try super.encode(to: encoder)
    }
}

public extension StepMetadata {
    static func notificationsRecurring(
        id: String,
        title: String,
        notificationTitle: String,
        notificationText: String,
        recurrenceRule: String,
        text: String,
        imageURL: String? = nil,
        next: PushLinkMetadata? = nil,
        links: [LinkMetadata] = []
    ) -> NotificationsRecurringMetadata {
        return NotificationsRecurringMetadata(id: id, title: title, notificationTitle: notificationTitle, notificationText: notificationText, recurrenceRule: recurrenceRule, text: text, imageURL: imageURL, next: next, links: links)
    }
}
