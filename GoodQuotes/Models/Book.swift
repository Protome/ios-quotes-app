//
//  GoodreadsBook.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 17/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import SwiftyXMLParser

struct Book {
    var id: String
    var title: String
    var author: Author
    var imageUrl: String
    var averageRating: Double
    
    init(xml: XML.Accessor) {
        id = xml["best_book", "id"].text ?? ""
        title = xml["best_book", "title"].text ?? ""
        author = Author(xml: xml["best_book", "author"])
        imageUrl = xml["best_book", "image_url"].text ?? ""
        averageRating = xml["average_rating"].double ?? 0
        
    }
}
