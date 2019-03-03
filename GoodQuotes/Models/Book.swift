//
//  GoodreadsBook.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 17/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import SwiftyXMLParser

struct Book: Codable {

    var id: String
    var title: String
    var author: Author
    var imageUrl: String
    var averageRating: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case author
        case imageUrl
        case averageRating
    }
    
    init(xml: XML.Accessor) {
        id = xml["best_book", "id"].text ?? ""
        title = xml["best_book", "title"].text ?? ""
        author = Author(xml: xml["best_book", "author"])
        imageUrl = xml["best_book", "image_url"].text ?? ""
        averageRating = xml["average_rating"].double ?? 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(author, forKey: .author)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(averageRating, forKey: .averageRating)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(Author.self, forKey: .author)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        averageRating = try container.decode(Double.self, forKey: .averageRating)
    }

}
