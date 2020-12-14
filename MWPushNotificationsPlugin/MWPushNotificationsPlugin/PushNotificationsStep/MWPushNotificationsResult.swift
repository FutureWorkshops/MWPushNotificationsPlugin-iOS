//
//  MWPushNotificationsResult.swift
//  MWPushNotificationsPlugin
//
//  Created by Xavi Moll on 14/12/20.
//

import Foundation
import MobileWorkflowCore

fileprivate let kAPNSToken = "apnsToken"

final class MWPushNotificationsResult: ORKResult, Codable {
    
    let apnsToken: String
    
    init(identifier: String, apnsToken: String) {
        self.apnsToken = apnsToken
        super.init(identifier: identifier)
    }
    
    override func copy() -> Any {
        return MWPushNotificationsResult(identifier: self.identifier, apnsToken: self.apnsToken)
    }
    
    required init?(coder decoder: NSCoder) {
        guard let apnsToken = decoder.decodeObject(forKey: kAPNSToken) as? String else { return nil }
        self.apnsToken = apnsToken
        super.init(coder: decoder)
    }
    
    override func encode(with coder: NSCoder) {
        coder.encode(self.apnsToken, forKey: kAPNSToken)
        super.encode(with: coder)
    }
}

extension MWPushNotificationsResult: ValueProvider {
    var content: [AnyHashable : Codable] {
        return [self.identifier:[kAPNSToken:self.apnsToken]]
    }
    
    func fetchValue(for path: String) -> Any? {
        return self.apnsToken
    }
    
    func fetchProvider(for path: String) -> ValueProvider? {
        return self.apnsToken
    }
}

extension MWPushNotificationsResult: JSONRepresentable {
    var jsonContent: String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
