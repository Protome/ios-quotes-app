//
//  QuoteServiceProtocol.swift
//  GoodQuotes
//
//  Created by Kieran on 06/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import Foundation

protocol QuoteServiceProtocol {
    func getRandomQuote(completion: @escaping (Quote) -> ())
    func getFullyRandomQuote(completion: @escaping (Quote) -> ())
    func getAuthorQuote(author: String, completion: @escaping (Quote) -> ())
    func getTagQuotes(filter: String, completion: @escaping (Quote) -> ())
    func getBookQuote(book: Book, completion: @escaping (Quote) -> ())
    func getAllQuotesForStringAtPage(query: String, pageNumber: Int, completion: @escaping ([Quote]) -> ())
    func getTotalPageNumberForString(query: String,  completion: @escaping (Int) -> ())
    func getAllQuotesForTagAtPage(tag: String, pageNumber: Int, completion: @escaping ([Quote]) -> ())
    func randomAuthor() -> Character
}
