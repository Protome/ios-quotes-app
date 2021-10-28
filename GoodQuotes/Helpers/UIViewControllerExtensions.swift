//
//  SafariUrlHelper.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 27/10/2021.
//  Copyright © 2021 Protome. All rights reserved.
//

import Foundation
import SafariServices

extension UIViewController {
    func OpenUrlInSafari(url: URL) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        
        let safariVc = SFSafariViewController(url: url, configuration: config)
        safariVc.modalPresentationStyle = .pageSheet
        present(safariVc, animated: true)
    }
    
    @IBAction func closeModal(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
