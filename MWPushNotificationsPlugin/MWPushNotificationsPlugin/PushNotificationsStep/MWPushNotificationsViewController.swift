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
        static let enableButtonTitle = "Enable"
        static let skipButtonTitle = "Skip"
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

public class MWPushNotificationsViewController: MWInstructionStepViewController {
    
    private var registration: AnyCancellable?
    private var pendingDidBecomeActive: AnyCancellable?
    
    private var pushNotificationsStep: MWPushNotificationsStep {
        guard let pushNotificationsStep = self.mwStep as? MWPushNotificationsStep else {
            preconditionFailure("Unexpected step type. Expecting \(String(describing: MWPushNotificationsStep.self)), got \(String(describing: type(of: self.mwStep)))")
        }
        return pushNotificationsStep
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        self.configureWithTitle(
            self.pushNotificationsStep.title ?? "NO_TITLE",
            body: self.pushNotificationsStep.text ?? "NO_TEXT",
            primaryConfig: .init(isEnabled: true, style: .primary, title: L10n.PushNotification.enableButtonTitle, action: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.determineCurrentStatus(completion: strongSelf.resolveStatusBeforeRegistration)
            }),
            secondaryConfig: .init(isEnabled: true, style: .textOnly, title: L10n.PushNotification.skipButtonTitle, action: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.determineCurrentStatus(completion: strongSelf.resolveStatusAfterUserAction)
            })
        )
    }
    
    private func determineCurrentStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    private func resolveStatusBeforeRegistration(_ status: UNAuthorizationStatus) {
        switch status {
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
        case .notDetermined:
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
        case .authorized, .provisional, .ephemeral:
            fallthrough
        @unknown default:
            self.register(currentStatus: status)
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
        let publisher: AnyPublisher<Data?, Error> = self.pushNotificationsStep.services.eventService.publisher(for: .apnsTokenRegistered)
        self.showLoading()
        self.registration = publisher
            .timeout(3.0, scheduler: DispatchQueue.global(), customError: { MWPushNotificationsError.registrationTimeout })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.hideLoading()
                switch completion {
                case .finished: break
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    self?.goForward() // continue anyway
                }
                self?.registration = nil
            } receiveValue: { [weak self] data in
                guard let token = data else { return }
                self?.didReceiveToken(token, currentStatus: currentStatus)
            }
    }
    
    private func openSettings() {
        let publisher: AnyPublisher<Notification?, Error> = self.pushNotificationsStep.services.eventService.publisher(for: .notification(name: UIApplication.didBecomeActiveNotification))
        self.pendingDidBecomeActive = publisher
            .sink { [weak self] _ in
                self?.pendingDidBecomeActive = nil
            } receiveValue: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.determineCurrentStatus(completion: strongSelf.resolveStatusAfterUserAction)
            }
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func didReceiveToken(_ token: Data, currentStatus: UNAuthorizationStatus) {
        let stringToken = token.map({ String(format: "%02x", $0) }).joined()
        let result = MWPushNotificationsResult(identifier: self.pushNotificationsStep.identifier, status: currentStatus.name, token: stringToken)
        self.addStepResult(result)
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
