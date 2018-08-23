//
//  AuthorEntryViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 11/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import UIKit

class CustomTagEntryViewController: UIViewController
{
    @IBOutlet weak var AuthorTextField: UITextField!
    
    weak var delegate: CustomTagEntryViewControllerDelegate?
    
    override func viewDidLoad() {
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func SelectAuthor(_ sender: Any) {
        if(!AuthorTextField.text!.isEmpty)
        {
            delegate?.customTagSelected(tag: AuthorTextField.text!.withoutSpecialCharacters)
            print(AuthorTextField.text!.withoutSpecialCharacters)
            navigationController?.popViewController(animated: true)
        }
    }
}

protocol CustomTagEntryViewControllerDelegate: class
{
    func customTagSelected(tag: String)
}
