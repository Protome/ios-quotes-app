//
//  QuoteServiceProtocol.swift
//  GoodQuotes
//
//  Created by Kieran on 06/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import Foundation

protocol QuoteServiceProtocol {
    func getRandomQuote() async -> Quote
    func getFullyRandomQuote() async -> Quote
    func getAuthorQuote(author: String) async -> Quote
    func getTagQuotes(filter: String) async -> Quote
    func getBookQuote(book: Book) async -> Quote
    func getAllQuotesForStringAtPage(query: String, pageNumber: Int) async -> [Quote]
    func getTotalPageNumberForString(query: String) async -> Int
    func getAllQuotesForTagAtPage(tag: String, pageNumber: Int) async -> [Quote]
    func randomAuthor() -> Character
}
