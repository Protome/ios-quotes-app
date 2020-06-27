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
    var selectedTag = false
    
    var customTag:Tags?
    
    override func prepareForReuse() {
        SelectedTick?.isHidden = !selectedTag
    }
    
    func setupCell(tag: Tags, selected: Bool)
    {
        customTag = tag
        TagLabel.text = tag.rawValue
        selectedTag = selected
        SelectedTick?.isHidden = !selected
    }
    
    func setSelected(selected: Bool) {
        selectedTag = selected
        SelectedTick?.isHidden = !selected
    }
}
