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
        static let deniedTitle = "Push Notifications"
        static let deniedText = "You have currently opted out of receiving Push Notifications. You can update this preference in Settings."
        static let deniedCancelTitle = "Skip"
        static let deniedConfirmTitle = "Settings"
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
    
    private var registration: AnyCancellable?
    private var pendingDidBecomeActive: AnyCancellable?
    
    private var pushNotificationsStep: MWPushNotificationsStep {
        guard let pushNotificationsStep = self.step as? MWPushNotificationsStep else {
            preconditionFailure("Unexpected step type. Expecting \(String(describing: MWPushNotificationsStep.self)), got \(String(describing: type(of: self.step)))")
        }
        return pushNotificationsStep
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureWithTitle(self.pushNotificationsStep.title ?? "NO_TITLE", body: self.pushNotificationsStep.text ?? "NO_TEXT", buttonTitle: "Enable") {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.show(error)
                    } else if granted {
                        self?.register(currentStatus: .authorized)
                    } else {
                        self?.userDeniedPermission(currentStatus: .denied)
                    }
                }
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.determineCurrentStatus(completion: self.resolveStatusBeforeUserAction)
    }
    
    private func determineCurrentStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    private func resolveStatusBeforeUserAction(_ status: UNAuthorizationStatus) {
        switch status {
        case .authorized:
            self.register(currentStatus: status) // obtain/re-obtain token
        case .denied:
            self.showConfirmationAlert(
                title: L10n.PushNotification.deniedTitle,
                message: L10n.PushNotification.deniedText,
                cancelTitle: L10n.PushNotification.deniedCancelTitle,
                confirmTitle: L10n.PushNotification.deniedConfirmTitle,
                actionHandler: { [weak self] didConfirm in
                    if didConfirm {
                        self?.openSettings()
                    } else {
                        self?.userDeniedPermission(currentStatus: status)
                    }
                })
        case .notDetermined, .provisional, .ephemeral:
            fallthrough
        @unknown default:
            break // wait for user to tap button
        }
    }
    
    private func resolveStatusAfterUserAction(_ status: UNAuthorizationStatus) {
        switch status {
        case .authorized, .provisional, .ephemeral:
            self.register(currentStatus: status) // obtain/re-obtain token
        case .denied, .notDetermined:
            fallthrough
        @unknown default:
            self.userDeniedPermission(currentStatus: status)
        }
    }
    
    private func userDeniedPermission(currentStatus: UNAuthorizationStatus) {
        self.register(currentStatus: currentStatus) // obtain token anyway - notifications will be delivered silently and the user may enable them later
    }
    
    private func register(currentStatus: UNAuthorizationStatus) {
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
                self?.didReceiveToken(token, currentStatus: currentStatus)
            }
    }
    
    private func openSettings() {
        self.pendingDidBecomeActive = self.pushNotificationsStep.services.eventService.didBecomeActivePublisher()
            .sink { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.determineCurrentStatus(completion: strongSelf.resolveStatusAfterUserAction)
            }
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func didReceiveToken(_ token: Data, currentStatus: UNAuthorizationStatus) {
        let stringToken = token.map({ String(format: "%02x", $0) }).joined()
        let result = MWPushNotificationsResult(identifier: self.pushNotificationsStep.identifier, status: currentStatus.name, token: stringToken)
        self.addResult(result)
        self.goForward()
    }
}

private extension UNAuthorizationStatus {
    
    var name: String {
        switch self {
        case .authorized: return "authorized"
        case .denied: return "denied"
        case .ephemeral: return "ephemeral"
        case .notDetermined: return "notDetermined"
        case .provisional: return "provisional"
        @unknown default:
            return "unknown"
        }
    }
}
