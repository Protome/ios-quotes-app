//
//  TagCellView.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 11/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import UIKit

class TagCellView: UITableViewCell
{
    @IBOutlet weak var SelectedTick: UIImageView!
    @IBOutlet weak var TagLabel: UILabel!
    var customTag:Tags?
    
    func setupCell(tag: Tags, selected: Bool)
    {
        customTag = tag
        TagLabel.text = tag.rawValue
        isSelected = selected
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        SelectedTick.isHidden = !selected
    }
}
