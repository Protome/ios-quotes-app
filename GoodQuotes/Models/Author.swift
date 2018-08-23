//
//  Author.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 17/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import SwiftyXMLParser

struct Author {
    var id: String
    var name: String
    
    init(xml: XML.Accessor) {
        id = xml["id"].text ?? ""
        name = xml["name"].text ?? ""
    }
}
