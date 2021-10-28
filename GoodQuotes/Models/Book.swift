//
//  GoodreadsBook.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 17/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import SwiftyXMLParser
import SwiftyJSON

struct Book: Codable {

    var goodreadsId: String
    var id: String
    var isbn: String
    var title: String
    var author: Author
    var publicationYear: Int?
    var imageUrl: String
    var averageRating: Double
    
    enum CodingKeys: String, CodingKey {
        case goodreadsId
        case id
        case isbn
        case title
        case author
        case imageUrl
        case averageRating
        case publicationYear
    }
    
    init(xml: XML.Accessor) {
        goodreadsId = xml["best_book", "id"].text ?? ""
        id = ""
        isbn = ""
        title = xml["best_book", "title"].text ?? ""
        author = Author(xml: xml["best_book", "author"])
        imageUrl = xml["best_book", "image_url"].text ?? ""
        averageRating = xml["average_rating"].double ?? 0
        publicationYear = nil
    }
    
    init(bookXml: XML.Accessor) {
        goodreadsId = bookXml["id"].text ?? ""
        id = ""
        isbn = ""
        title = bookXml["title"].text ?? ""
        author = Author(xml: bookXml["authors", "author"])
        imageUrl = bookXml["image_url"].text ?? ""
        averageRating = 0
        publicationYear = nil
    }
    
    init(json: JSON) {
        id = json["cover_edition_key"].stringValue
        let isbnNumbers = json["isbn"].arrayValue
        isbn = isbnNumbers.first?.stringValue ?? ""
        title = json["title"].stringValue
        author = Author(keysJson: json["author_key"].arrayValue, authorJson: json["author_name"].arrayValue)
        imageUrl = "https://covers.openlibrary.org/b/OLID/\(id)-M.jpg"
        averageRating = 0
        goodreadsId = json["id_goodreads"].arrayValue.first?.stringValue ?? ""
        publicationYear = json["first_publish_year"].intValue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(author, forKey: .author)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(averageRating, forKey: .averageRating)
        
        do {
            try container.encode(goodreadsId, forKey: .goodreadsId)
            try container.encode(isbn, forKey: .isbn)
            try container.encode(publicationYear, forKey: .publicationYear)
        }
        catch {
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(Author.self, forKey: .author)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        averageRating = try container.decode(Double.self, forKey: .averageRating)
        
        do {
            goodreadsId = try container.decode(String.self, forKey: .goodreadsId)
            isbn = try container.decode(String.self, forKey: .isbn)
            publicationYear = try container.decode(Int.self, forKey: .publicationYear)
        }
        catch {
            goodreadsId = ""
            isbn = ""
        }
    }

}
