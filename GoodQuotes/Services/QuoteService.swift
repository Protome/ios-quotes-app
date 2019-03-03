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

//TODO: This is a mess already, refactor it
class QuoteService {
    let baseUrl = "https://quoteyapi.herokuapp.com/api/v1/quotey/"
//    let baseUrl = "http://192.168.0.5:8080/api/v1/quotey/"
    
    func getRandomQuote(completion: @escaping (Quote) -> ())
    {
        let defaultsService = UserDefaultsService()
        let searchType = defaultsService.loadCurrentFilterType()
        
        switch searchType {
            case .None: getFullyRandomQuote(completion: completion)
            case .Book:
                let searchTerm = defaultsService.loadBook()
                getBookQuote(book: searchTerm!, completion: completion)
            
            case .Search:
                let searchTerm = defaultsService.loadSearch()
                getAuthorQuote(author: searchTerm ?? "", completion: completion)
            case .Tag: break
        }
    }
    
    internal func getFullyRandomQuote(completion: @escaping (Quote) -> ())
    {
        let randomPage = Int(arc4random_uniform(UInt32(100)))
        let author = randomAuthor()
        getAllQuotesForStringAtPage(query: "\(author)", pageNumber: randomPage) { quotes in
            if quotes.count == 0 {
                self.getRandomQuote(completion: { quote in
                    completion(quote)
                })
            }
            else {
                let random = Int(arc4random_uniform(UInt32(quotes.count)))
                completion(quotes[random])
            }
        }
    }
    
    internal func getAuthorQuote(author: String, completion: @escaping (Quote) -> ())
    {
        let editedAuthor = author.components(separatedBy: .whitespaces).joined(separator: "+")
        
        getTotalPageNumberForString(query: editedAuthor) { pages in
            let randomPage = Int(arc4random_uniform(UInt32(pages)))
            
            self.getAllQuotesForStringAtPage(query: editedAuthor, pageNumber: randomPage) { quotes in
                if quotes.count == 0 {
                    self.getFullyRandomQuote(completion: { quote in
                        completion(quote)
                    })
                }
                else {
                    let random = Int(arc4random_uniform(UInt32(quotes.count)))
                    completion(quotes[random])
                }
            }
        }
    }
    
    internal func getTagQuotes(filter: String, completion: @escaping (Quote) -> ())
    {
        let randomPage = Int(arc4random_uniform(UInt32(100)))
        getAllQuotesForTagAtPage(tag: filter, pageNumber: randomPage) { quotes in
            if quotes.count == 0 {
                self.getFullyRandomQuote(completion: { quote in
                    completion(quote)
                })
            }
            else {
                let random = Int(arc4random_uniform(UInt32(quotes.count)))
                completion(quotes[random])
            }
        }
    }
    
    internal func getBookQuote(book: Book, completion: @escaping (Quote) -> ())
    {
        let editedTitle = book.title.components(separatedBy: .whitespaces).joined(separator: "+")
        let editedAuthor = book.author.name.components(separatedBy: .whitespaces).joined(separator: "+")
        let query = "\(editedTitle)+\(editedAuthor)"
        
        getTotalPageNumberForString(query: query) { pages in
            let randomPage = Int(arc4random_uniform(UInt32(pages)))
            
            self.getAllQuotesForStringAtPage(query: query, pageNumber: randomPage) { quotes in
                if quotes.count == 0 {
                    self.getFullyRandomQuote(completion: { quote in
                        completion(quote)
                    })
                }
                else {
                    let filteredQuotes = quotes.filter({ quote in
                        let authorMatches = quote.author == book.author.name
                        let titleMatches = quote.publication == book.title
                        return authorMatches && titleMatches
                    })
                    
                    let listToUse = filteredQuotes.count > 0 ? filteredQuotes : quotes
                    
                    let random = Int(arc4random_uniform(UInt32(listToUse.count)))
                    completion(listToUse[random])
                }
            }
        }
    }
    
    internal func getAllQuotesForStringAtPage(query: String, pageNumber: Int, completion: @escaping ([Quote]) -> ())
    {
        let url = baseUrl + "\(query)/\(pageNumber)"
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        Alamofire.request(encodedURL!).responseJSON { response in
                if let jsonResponse = response.result.value {
                    let json = JSON(jsonResponse)
                    let quotes = json["quotes"].map({return Quote(jsonObject: $1)})
                    completion(quotes)
                }
            }
    }
    
    internal func getTotalPageNumberForString(query: String,  completion: @escaping (Int) -> ())
    {
        let url = baseUrl + query
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            Alamofire.request(encodedURL!).responseJSON { response in
                if let jsonResponse = response.result.value {
                    let json = JSON(jsonResponse)
                    completion(json["total_pages"].intValue)
                }
            }
    }
    
    internal func getAllQuotesForTagAtPage(tag: String, pageNumber: Int, completion: @escaping ([Quote]) -> ())
    {
            Alamofire.request(baseUrl + "\(tag)/\(pageNumber)").responseJSON { response in
                if let jsonResponse = response.result.value {
                    let json = JSON(jsonResponse)
                    let quotes = json["quotes"].map({return Quote(jsonObject: $1)})
                    completion(quotes)
                }
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
