//
//  CancelRecurringStepViewController.swift
//  MWPushNotificationsPlugin
//
//  Created by Pedro Sebastião on 30/08/2022.
//

import Foundation
import MobileWorkflowCore

public class CancelRecurringStepViewController: MWInstructionStepViewController {
    
    private var cancelRecurringStep: CancelRecurringStep {
        self.mwStep as! CancelRecurringStep
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let bodyResolved = self.cancelRecurringStep.session.resolve(value: self.cancelRecurringStep.text ?? "NO_TEXT")
        
        self.configureWithTitle(
            self.cancelRecurringStep.title ?? "NO_TITLE",
            body: bodyResolved,
            primaryConfig: .init(isEnabled: true, style: .primary, title: L10n.CancelRecurring.doneButtonTitle, action: { [weak self] in
                guard let strongSelf = self else { return }
                
                let task = RecurringCancelTask()
                
                strongSelf.cancelRecurringStep.services.perform(task: task, session: strongSelf.cancelRecurringStep.session) { [weak self] result in
                    switch result {
                    case .success: self?.goForward()
                    case .failure(let error): Task { self?.show(error) }
                    }
                }
            }),
            secondaryConfig: nil
        )
        
    }
    
    
}
