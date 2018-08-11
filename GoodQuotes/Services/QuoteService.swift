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

class QuoteService {
    let baseUrl = "https://goodquotesapi.herokuapp.com"
    let authorPath = "/author"
    let tagPath = "/tag"
    let pageQuery = "page"
    
    func getRandomQuote(completion: @escaping (Quote) -> ())
    {
        let defaultsService = UserDefaultsService()
        let settings = defaultsService.loadFilters()
        
        let randomPage = Int(arc4random_uniform(UInt32(100)))
        if settings == nil || settings?.type == FilterType.None
        {
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
            return
        }
        
        if settings?.type == FilterType.Tag {
            getAllQuotesForTagAtPage(tag: settings!.filter, pageNumber: randomPage) { quotes in
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
