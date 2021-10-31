//
//  OpenLibraryService.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 27/10/2021.
//  Copyright © 2021 Protome. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftUI

class OpenLibraryService {
    static var sharedInstance = OpenLibraryService()
    
    var ongoingRequest: DataRequest?
    
    func searchForBook(title: String, author: String, completion:  @escaping (Book?) -> ())
    {
        var titleQuery = title
        if title.contains("(") {
            let titleSplit = title.components(separatedBy: "(")
            titleQuery = titleSplit.first ?? titleQuery
        }
        
        let authorQuery = author.withoutSpecialCharacters(separator: " ")
        
        var components = URLComponents(string: "https://openlibrary.org/search.json")
        components?.queryItems = [
            URLQueryItem(name: "author", value: authorQuery),
            URLQueryItem(name: "title", value: titleQuery)]
        if let url = components?.url
        {
            Alamofire.request(url).responseJSON { response in
                if let jsonResponse = response.result.value {
                    let json = JSON(jsonResponse)
                    let numFound = json["numFound"].intValue
                    
                    if numFound == 0 { completion(nil) }
                    
                    if numFound > 0 {
                        let closestResult =  json["docs"].arrayValue.first { json in
                            let closestBook = Book(json: json)
                            return Tools.levenshtein(aStr: title, bStr: closestBook.title) < title.count/3 && Tools.levenshtein(aStr: author, bStr: closestBook.author.name) < 3
                        }
                        
                        if let bookJson = closestResult {
                            let book = Book(json: bookJson)
                            completion(book)
                        }
                        else if let bookJson = json["docs"].arrayValue.first {
                            let book = Book(json: bookJson)
                            completion(book)
                        }
                    }
                }
            }
        }
    }
    
    func wideSearchForBook(query: String, completion:  @escaping (Book?) -> ())
    {
        var components = URLComponents(string: "https://openlibrary.org/search.json")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query)]
        if let url = components?.url
        {
            Alamofire.request(url).responseJSON { response in
                if let jsonResponse = response.result.value {
                    let json = JSON(jsonResponse)
                    let numFound = json["numFound"].intValue
                    
                    if numFound == 0 { completion(nil) }
                    
                    if numFound > 0 {
                        let closestResult =  json["docs"].arrayValue.first { json in
                            let closestBook = Book(json: json)
                            return Tools.levenshtein(aStr: query, bStr: closestBook.title) < query.count/3 || Tools.levenshtein(aStr: query, bStr: closestBook.author.name) < query.count/3
                        }
                        
                        if let bookJson = closestResult {
                            let book = Book(json: bookJson)
                            completion(book)
                        }
                        else if let bookJson = json["docs"].arrayValue.first {
                            let book = Book(json: bookJson)
                            completion(book)
                        }
                    }
                }
            }
        }
    }
    
    func searchForBooks(title: String?, author: String?, query: String?, completion:  @escaping ([Book], Bool) -> ())
    {
        var components = URLComponents(string: "https://openlibrary.org/search.json")
        
        if let title = title {
            components?.queryItems = [URLQueryItem(name: "title", value:title)]
        }
        
        if let author = author {
            components?.queryItems = [URLQueryItem(name: "author", value:author)]
        }
        
        if let query = query {
            components?.queryItems = [URLQueryItem(name: "q", value:query)]
        }
        
        if let url = components?.url
        {
            ongoingRequest?.cancel()
            
            ongoingRequest = Alamofire.request(url).response { response in
                guard response.error == nil, let responseData = response.data else {
                    completion([Book](), true)
                    return
                }
                
                do {
                    let json = try JSON(data: responseData)
                    
                    let numFound = json["numFound"].intValue
                    
                    if numFound == 0 { completion([Book](), false) }
                    
                    if numFound > 0 {
                        let bookResults = json["docs"].arrayValue.map({ return Book(json: $0)})
                        completion(bookResults, false)
                    }
                } catch {
                    completion([Book](), false)
                    return
                }
            }
        }
    }
}
