//
//  QuoteService.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 09/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class QuoteService: QuoteServiceProtocol {
    let baseUrl = "https://quoteyapi.herokuapp.com/api/v1/quotey/"
    //    let baseUrl = "http://192.168.0.5:8080/api/v1/quotey/"
    
    func getRandomQuote() async -> Quote {
        let defaultsService = UserDefaultsService()
        let searchType = defaultsService.loadCurrentFilterType()
        
        switch searchType {
        case .None: return await getFullyRandomQuote()
        case .Book:
            let searchTerm = defaultsService.loadBook()
            return await getBookQuote(book: searchTerm!)
            
        case .Search:
            let searchTerm = defaultsService.loadSearch()
            return await getAuthorQuote(author: searchTerm ?? "")
        case .Tag:
            //TODO: Implement this
            return await getFullyRandomQuote()
        }
    }
    
    internal func getFullyRandomQuote() async -> Quote
    {
        let randomPage = Int(arc4random_uniform(UInt32(100)))
        let author = randomAuthor()
        let quotes = await getAllQuotesForStringAtPage(query: "\(author)", pageNumber: randomPage)
        
        if quotes.count == 0 {
            return await self.getRandomQuote()
        }
        else {
            let random = Int(arc4random_uniform(UInt32(quotes.count)))
            return quotes[random]
        }
    }
    
    internal func getAuthorQuote(author: String) async -> Quote {
        let editedAuthor = author.components(separatedBy: .whitespaces).joined(separator: "+")
        let pages = await getTotalPageNumberForString(query: editedAuthor)
        let randomPage = Int(arc4random_uniform(UInt32(pages)))
        let quotes = await getAllQuotesForStringAtPage(query: editedAuthor, pageNumber: randomPage)
        if quotes.count == 0 {
            return await getFullyRandomQuote()
        }
        else {
            let random = Int(arc4random_uniform(UInt32(quotes.count)))
            return quotes[random]
        }
    }
    
    internal func getTagQuotes(filter: String) async -> Quote {
        let randomPage = Int(arc4random_uniform(UInt32(100)))
        let quotes = await getAllQuotesForTagAtPage(tag: filter, pageNumber: randomPage)
        if quotes.count == 0 {
            return await getFullyRandomQuote()
        }
        else {
            let random = Int(arc4random_uniform(UInt32(quotes.count)))
            return quotes[random]
        }
    }
    
    internal func getBookQuote(book: Book) async -> Quote {
        let editedTitle = book.title.components(separatedBy: .whitespaces).joined(separator: "+")
        let editedAuthor = book.author.name.components(separatedBy: .whitespaces).joined(separator: "+")
        let query = "\(editedTitle)+\(editedAuthor)"
        
        let pagesNumber = await getTotalPageNumberForString(query: query)
        let randomPage = Int(arc4random_uniform(UInt32(pagesNumber)))
        let allQuotesForPage = await getAllQuotesForStringAtPage(query: query, pageNumber: randomPage)
        
        if allQuotesForPage.count == 0 {
            return await getFullyRandomQuote()
        }
        
        let filteredQuotes = allQuotesForPage.filter({ quote in
            let authorMatches = quote.author == book.author.name
            let titleMatches = quote.publication == book.title
            return authorMatches && titleMatches
        })
        
        let listToUse = filteredQuotes.count > 0 ? filteredQuotes : allQuotesForPage
        
        let random = Int(arc4random_uniform(UInt32(listToUse.count)))
        return listToUse[random]
    }
    
    internal func getAllQuotesForStringAtPage(query: String, pageNumber: Int) async -> [Quote]
    {
        let url = baseUrl + "\(query)/\(pageNumber)"
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let task = AF.request(encodedURL!).serializingDecodable(QuotesResponse.self)
        let response = await task.response
        
        switch response.result {
        case .success(let quoteResponse):
            return quoteResponse.quotes
        case .failure(let error):
            print (error)
            return [Quote]()
        }
    }
    
    internal func getTotalPageNumberForString(query: String) async -> Int
    {
        let url = baseUrl + query
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let response = await AF.request(encodedURL!).serializingDecodable(JSON.self).response
        
        switch response.result {
        case .success(let json):
            return json["total_pages"].intValue
        case .failure(let error):
            print (error)
            return 0
        }
    }
    
    internal func getAllQuotesForTagAtPage(tag: String, pageNumber: Int) async -> [Quote]
    {
        let response = await AF.request(baseUrl + "\(tag)/\(pageNumber)").serializingDecodable(QuotesResponse.self).response
        
        switch response.result {
        case .success(let quoteResponsee):
            return quoteResponsee.quotes
        case .failure(let error):
            print (error)
            return [Quote]()
        }
    }
    
    internal func randomAuthor() -> Character
    {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomNum = Int(arc4random_uniform(UInt32(allowedChars.count)))
        let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
        return allowedChars[randomIndex]
    }
}
