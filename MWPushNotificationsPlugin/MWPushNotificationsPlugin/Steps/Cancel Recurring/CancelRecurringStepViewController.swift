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
        
        self.configureWithTitle(
            self.cancelRecurringStep.title ?? "NO_TITLE",
            body: self.cancelRecurringStep.text ?? "NO_TEXT",
            primaryConfig: .init(isEnabled: true, style: .primary, title: L10n.CancelRecurring.doneButtonTitle, action: { [weak self] in
                guard let strongSelf = self else { return }
            }),
            secondaryConfig: nil
        )
        
    }
    
    
}
