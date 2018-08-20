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
    let baseUrl = "https://goodquotesapi.herokuapp.com"
    let authorPath = "/author"
    let tagPath = "/tag"
    let pageQuery = "page"
    
    func getRandomQuote(completion: @escaping (Quote) -> ())
    {
        let defaultsService = UserDefaultsService()
        let settings = defaultsService.loadFilters()
        
        if settings == nil || settings?.type == FilterType.None
        {
            getFullyRandomQuote(completion: completion)
            return
        }
        
        if settings?.type == FilterType.Tag {
            getTagQuotes(filter:settings!.filter, completion: completion)
            return
        }
        
        if settings?.type == FilterType.CustomTag {
            getAuthorQuote(author:settings!.filter, completion: completion)
            return
        }
    }
    
    internal func getFullyRandomQuote(completion: @escaping (Quote) -> ())
    {
        let randomPage = Int(arc4random_uniform(UInt32(100)))
        let author = randomAuthor()
        getAllQuotesForAuthorAtPage(author: "\(author)", pageNumber: randomPage) { quotes in
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
        
        getTotalPageNumberForAuthor(author: editedAuthor) { pages in
            let randomPage = Int(arc4random_uniform(UInt32(pages)))
            
            self.getAllQuotesForAuthorAtPage(author: editedAuthor, pageNumber: randomPage) { quotes in
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
    
    internal func getAllQuotesForAuthorAtPage(author: String, pageNumber: Int, completion: @escaping ([Quote]) -> ())
    {
        var components = URLComponents(string: baseUrl)
        components?.path="\(authorPath)/\(author)"
        components?.queryItems = [URLQueryItem(name: pageQuery, value:"\(pageNumber)")]
        
        if let url = components?.url
        {
            Alamofire.request(url).responseJSON { response in
                if let jsonResponse = response.result.value {
                    let json = JSON(jsonResponse)
                    let quotes = json["quotes"].map({return Quote(jsonObject: $1)})
                    completion(quotes)
                }
            }
        }
    }
    
    internal func getTotalPageNumberForAuthor(author: String,  completion: @escaping (Int) -> ())
    {
        var components = URLComponents(string: baseUrl)
        components?.path="\(authorPath)/\(author)"
        
        if let url = components?.url
        {
            Alamofire.request(url).responseJSON { response in
                if let jsonResponse = response.result.value {
                    let json = JSON(jsonResponse)
                    completion(json["total_pages"].intValue)
                }
            }
        }
    }
    
    internal func getAllQuotesForTagAtPage(tag: String, pageNumber: Int, completion: @escaping ([Quote]) -> ())
    {
        var components = URLComponents(string: baseUrl)
        components?.path="\(tagPath)/\(tag)"
        components?.queryItems = [URLQueryItem(name: pageQuery, value:"\(pageNumber)")]
        
        if let url = components?.url
        {
            Alamofire.request(url).responseJSON { response in
                if let jsonResponse = response.result.value {
                    let json = JSON(jsonResponse)
                    let quotes = json["quotes"].map({return Quote(jsonObject: $1)})
                    completion(quotes)
                }
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
