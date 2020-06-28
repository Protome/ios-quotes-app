//
//  BookSearchResultCell.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 02/03/2019.
//  Copyright © 2019 Protome. All rights reserved.
//

import Foundation
import UIKit

class BookSearchResultCell: UITableViewCell {
    
    @IBOutlet weak var CoverImageView: UIImageView!
    @IBOutlet weak var TitleLabelView: UILabel!
    @IBOutlet weak var AuthorLabelView: UILabel!
    @IBOutlet weak var CellBackground: UIView!
    @IBOutlet weak var BlurContainer: UIView!
    
    static var Nib = UINib(nibName: String(describing: BookSearchResultCell.self), bundle: nil)
    static var Identifier = String(describing: BookSearchResultCell.self)
    
    override func prepareForReuse() {
        CoverImageView?.image = nil
    }
    
    func SetupCell(book: Book) {
        CoverImageView.setImageFromUrl(book.imageUrl)
        TitleLabelView.text = book.title
        AuthorLabelView.text = book.author.name
        BlurContainer?.layer.cornerRadius = 4
        BlurContainer?.layer.masksToBounds = true
        AddShadow()
    }
    
    private func AddShadow() {
        CellBackground?.layer.masksToBounds = false
        CellBackground?.layer.shadowColor = UIColor.black.cgColor
        CellBackground?.layer.shadowOpacity = 0.2
        CellBackground?.layer.shadowOffset = CGSize(width: 2, height: 4)
    }

}
