//
//  ShelfCell.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 11/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import UIKit

class ShelfCell: UITableViewCell
{
    @IBOutlet weak var SelectedTick: UIImageView!
    @IBOutlet weak var TagLabel: UILabel!
    @IBOutlet weak var BookCount: UILabel!
    var selectedShelf = false
    
    override func prepareForReuse() {
        SelectedTick?.isHidden = !selectedShelf
    }
    
    func setupCell(shelf: Shelf, selected: Bool)
    {
        TagLabel.text = shelf.name
        BookCount?.text = "\(shelf.book_count) books"
        selectedShelf = selected
        SelectedTick?.isHidden = !selected
    }
    
    func setSelected(selected: Bool) {
        selectedShelf = selected
        SelectedTick?.isHidden = !selected
    }
}
