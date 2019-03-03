//
//  TextOnlyResultCell.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 02/03/2019.
//  Copyright © 2019 Protome. All rights reserved.
//

import Foundation
import UIKit

class TextOnlyResultCell: UITableViewCell {
    static var Nib = UINib(nibName: String(describing: TextOnlyResultCell.self), bundle: nil)
    static var Identifier = String(describing: TextOnlyResultCell.self)
    
    @IBOutlet weak var CellBackground: UIView!
    @IBOutlet weak var DescriptionLabel: UILabel!
    
    func SetupCell(text: String) {
        DescriptionLabel.text = text
        CellBackground.backgroundColor = UIColor.white
        CellBackground.layer.cornerRadius = 4
        AddShadow()
    }
    
    private func AddShadow() {
        CellBackground.layer.masksToBounds = false
        CellBackground.layer.shadowColor = UIColor.black.cgColor
        CellBackground.layer.shadowOpacity = 0.2
        CellBackground.layer.shadowOffset = CGSize(width: 2, height: 4)
    }
}
