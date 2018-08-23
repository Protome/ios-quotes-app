//
//  GoodreadsShelf.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 16/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation

struct Shelf {
    var id: String
    var name: String
    var book_count: Int
    
    init(id: String?, name: String?, book_count: Int?)
    {
        self.id = id ?? ""
        self.name = name ?? ""
        self.book_count = book_count ?? 0
    }
}
