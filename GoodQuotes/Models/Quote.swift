//
//  Quote.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 09/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Quote
{
    let quote: String
    let author: String
    let publication: String
    
    init(jsonObject: JSON) {
        quote = jsonObject["quote"].string ?? ""
        author = jsonObject["author"].string ?? ""
        publication = jsonObject["publication"].string ?? ""
    }
}
