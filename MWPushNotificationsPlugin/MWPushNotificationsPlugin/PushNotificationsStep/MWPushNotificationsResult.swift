//
//  MWPushNotificationsResult.swift
//  MWPushNotificationsPlugin
//
//  Created by Xavi Moll on 14/12/20.
//

import Foundation
import MobileWorkflowCore

fileprivate let kStatus = "status"
fileprivate let kToken = "token"

final class MWPushNotificationsResult: ORKResult, Codable {
    
    let status: String
    let token: String
    
    init(identifier: String, status: String, token: String) {
        self.status = status
        self.token = token
        super.init(identifier: identifier)
    }
    
    override func copy() -> Any {
        return MWPushNotificationsResult(identifier: self.identifier, status: self.status, token: self.token)
    }
    
    required init?(coder decoder: NSCoder) {
        guard let status = decoder.decodeObject(forKey: kStatus) as? String else { return nil }
        guard let token = decoder.decodeObject(forKey: kToken) as? String else { return nil }
        self.status = status
        self.token = token
        super.init(coder: decoder)
    }
    
    override func encode(with coder: NSCoder) {
        coder.encode(self.status, forKey: kStatus)
        coder.encode(self.token, forKey: kToken)
        super.encode(with: coder)
    }
}

extension MWPushNotificationsResult: ValueProvider {
    var content: [AnyHashable : Codable] {
        return [self.identifier: [kStatus: self.status, kToken: self.token]]
    }
    
    func fetchValue(for path: String) -> Any? {
        if path == kStatus {
            return self.status
        } else if path == kToken {
            return self.token
        } else {
            return nil
        }
    }
    
    func fetchProvider(for path: String) -> ValueProvider? {
        if path == kStatus {
            return self.status
        } else if path == kToken {
            return self.token
        } else {
            return nil
        }
    }
}

extension MWPushNotificationsResult: JSONRepresentable {
    var jsonContent: String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
