//
//  Quote.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 09/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation

struct QuotesResponse: Decodable {
    let quotes: [Quote]
}

struct Quote: Decodable
{
    let quote: String
    let author: String
    let publication: String
}
