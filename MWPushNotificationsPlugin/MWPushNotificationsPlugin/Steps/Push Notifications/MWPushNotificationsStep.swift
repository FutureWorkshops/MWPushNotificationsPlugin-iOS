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

public class NotificationsUserPermissionMetadata: StepMetadata {
    enum CodingKeys: CodingKey {
        case text
        case enableText
        case imageURL
        case skipText
    }
    
    let text: String
    let enableText: Bool?
    let imageURL: String?
    let skipText: String?
    
    init(id: String, title: String, text: String, enableText: Bool?, imageURL: String?, skipText: String?, next: PushLinkMetadata?, links: [LinkMetadata]) {
        self.text = text
        self.enableText = enableText
        self.imageURL = imageURL
        self.skipText = skipText
        super.init(id: id, type: "io.mobileworkflow.NotificationPermission", title: title, next: next, links: links)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.enableText = try container.decodeIfPresent(Bool.self, forKey: .enableText)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        self.skipText = try container.decodeIfPresent(String.self, forKey: .skipText)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.text, forKey: .text)
        try container.encodeIfPresent(self.enableText, forKey: .enableText)
        try container.encodeIfPresent(self.imageURL, forKey: .imageURL)
        try container.encodeIfPresent(self.skipText, forKey: .skipText)
        try super.encode(to: encoder)
    }
}

public extension StepMetadata {
    static func notificationsUserPermission(
        id: String,
        title: String,
        text: String,
        enableText: Bool? = nil,
        imageURL: String? = nil,
        skipText: String? = nil,
        next: PushLinkMetadata? = nil,
        links: [LinkMetadata] = []
    ) -> NotificationsUserPermissionMetadata {
        return NotificationsUserPermissionMetadata(id: id, title: title, text: text, enableText: enableText, imageURL: imageURL, skipText: skipText, next: next, links: links)
    }
}
