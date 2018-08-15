//
//  AuthorEntryViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 11/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import UIKit

class AuthorEntryViewController: UIViewController
{
    @IBOutlet weak var AuthorTextField: UITextField!
    
    weak var delegate: AuthorEntryViewControllerDelegate?
    
    override func viewDidLoad() {
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func SelectAuthor(_ sender: Any) {
        if(!AuthorTextField.text!.isEmpty)
        {
            delegate?.authorSelected(author: AuthorTextField.text!)
            navigationController?.popViewController(animated: true)
        }
    }
}

protocol AuthorEntryViewControllerDelegate: class
{
    func authorSelected(author: String)
}
