//
//  MWPushNotificationsViewController.swift
//  MWPushNotificationsPlugin
//
//  Created by Xavi Moll on 9/12/20.
//

import UIKit
import UserNotifications
import Combine
import MobileWorkflowCore

enum L10n {
    enum PushNotification {
        static let generalError = "Unable to register for Push Notifcations."
    }
}

enum MWPushNotificationsError: LocalizedError {
    case registrationTimeout
    
    var errorDescription: String? {
        switch self {
        case .registrationTimeout:
            return L10n.PushNotification.generalError
        }
    }
    
    var localizedDescription: String {
        return self.errorDescription ?? L10n.PushNotification.generalError
    }
}

public class MWPushNotificationsViewController: MobileWorkflowButtonViewController {
    
    private var registration: Cancellable?
    
    private var pushNotificationsStep: MWPushNotificationsStep {
        guard let pushNotificationsStep = self.step as? MWPushNotificationsStep else {
            preconditionFailure("Unexpected step type. Expecting \(String(describing: MWPushNotificationsStep.self)), got \(String(describing: type(of: self.step)))")
        }
        return pushNotificationsStep
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureWithTitle(self.pushNotificationsStep.title ?? "NO_TITLE", body: self.pushNotificationsStep.text ?? "NO_TEXT", buttonTitle: "Enable") {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        self?.register()
                    } else if let error = error {
                        self?.show(error)
                    } else {
                        assertionFailure("Failed and had no errors.")
                    }
                }
            }
        }
    }
    
    private func register() {
        self.registration = self.pushNotificationsStep.services.eventService.apnsTokenPublisher()
            .timeout(5.0, scheduler: DispatchQueue.global(), customError: { MWPushNotificationsError.registrationTimeout })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.show(error)
                }
                self?.registration = nil
            } receiveValue: { [weak self] data in
                guard let token = data else { return }
                self?.didReceiveToken(token)
            }
    }
    
    private func didReceiveToken(_ token: Data) {
        let stringToken = token.map({ String(format: "%02x", $0) }).joined()
        let result = MWPushNotificationsResult(identifier: self.pushNotificationsStep.identifier, apnsToken: stringToken)
        self.addResult(result)
        self.goForward()
    }
}
