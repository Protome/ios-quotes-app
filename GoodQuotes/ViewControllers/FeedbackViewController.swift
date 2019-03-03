//
//  FeedbackViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 03/03/2019.
//  Copyright © 2019 Protome. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class FeedbackViewController: UIViewController {
    
    @IBOutlet weak var MessageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MessageButton.layer.cornerRadius = 8
        MessageButton.layer.borderColor = MessageButton.tintColor.cgColor
        MessageButton.layer.borderWidth = 1
    }
    
    @IBAction func SendFeedbackMessage(_ sender: Any) {
        sendEmail()
    }
}
extension FeedbackViewController: MFMailComposeViewControllerDelegate {
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["kieran@quotey.app"])
            mail.setSubject("Feedback")
            
            present(mail, animated: true)
        } else {
            print("something went wrong")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
