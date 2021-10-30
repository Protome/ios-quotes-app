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
}
