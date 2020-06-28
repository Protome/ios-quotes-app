//
//  Pages.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 28/06/2020.
//  Copyright © 2020 Protome. All rights reserved.
//

import Foundation
import SwiftyXMLParser

struct Pages  {
    var currentPage: Int
    var numPages: Int
    var lastItem: Int
    var total: Int
    var nextPage: Int {
        return currentPage + 1 > numPages ? numPages : currentPage + 1
    }
    var hasMoreToLoad: Bool {
        return total > lastItem
    }
    
    init(xml: XML.Accessor) {
        currentPage = Int(xml.attributes["currentpage"] ?? "1") ?? 1
        numPages = Int(xml.attributes["numpages"] ?? "1") ?? 1
        lastItem = Int(xml.attributes["end"] ?? "1") ?? 1
        total = Int(xml.attributes["total"] ?? "1") ?? 1
    }
}
