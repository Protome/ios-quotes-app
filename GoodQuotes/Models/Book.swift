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
    
    init(xml: XML.Accessor) {
        id = xml["id"].text ?? ""
        title = xml["title"].text ?? ""
        author = Author(xml: xml["author"])
        imageUrl = xml["image_url"].text ?? ""
    }
}
