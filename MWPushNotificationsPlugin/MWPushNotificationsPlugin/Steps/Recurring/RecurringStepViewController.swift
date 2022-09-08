//
//  RecurringStepViewController.swift
//  MWPushNotificationsPlugin
//
//  Created by Pedro Sebastião on 30/08/2022.
//

import Foundation
import MobileWorkflowCore

public class RecurringStepViewController: MWInstructionStepViewController {
    
    private var recurringStep: RecurringStep {
        self.mwStep as! RecurringStep
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureWithTitle(
            self.recurringStep.title ?? "NO_TITLE",
            body: self.recurringStep.text ?? "NO_TEXT",
            primaryConfig: .init(isEnabled: true, style: .primary, title: L10n.Recurring.doneButtonTitle, action: { [weak self] in
                guard let strongSelf = self else { return }
            }),
            secondaryConfig: nil
        )
        
    }
    
    
}
