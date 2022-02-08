//
//  MWPushNotificationsResult.swift
//  MWPushNotificationsPlugin
//
//  Created by Xavi Moll on 14/12/20.
//

import Foundation
import MobileWorkflowCore

class MWPushNotificationsResult: StepResult, Codable {
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case status
        case token
        case tokenType = "token_type"
    }
    
    var identifier: String
    let status: String
    let token: String
    let tokenType: String
    
    init(identifier: String, status: String, token: String, tokenType: String = "apns") {
        self.identifier = identifier
        self.status = status
        self.token = token
        self.tokenType = tokenType
    }
}

extension MWPushNotificationsResult: ValueProvider {
    func fetchValue(for path: String) -> Any? {
        if path == CodingKeys.status.rawValue {
            return self.status
        } else if path == CodingKeys.token.rawValue {
            return self.token
        } else if path == CodingKeys.tokenType.rawValue {
            return self.tokenType
        } else {
            return nil
        }
    }
    
    func fetchProvider(for path: String) -> ValueProvider? {
        return nil
    }
}

extension MWPushNotificationsResult: JSONRepresentable {
    var jsonContent: String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
