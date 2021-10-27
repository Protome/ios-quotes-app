//
//  Author.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 17/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import SwiftyXMLParser
import SwiftyJSON

struct Author: Codable  {
    var id: String
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    init(xml: XML.Accessor) {
        id = xml["id"].text ?? ""
        name = xml["name"].text ?? ""
    }
    
    init(keysJson: [JSON], authorJson: [JSON]) {
        id = keysJson.first?.stringValue ?? ""
        let authors = authorJson as? [String]
        name = authors?.joined(separator: ", ") ?? ""
    }
    
    init() {
        id = ""
        name = ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
}
