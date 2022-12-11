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

class OpenLibraryService: OpenLibraryServiceProtocol {
    static var sharedInstance: OpenLibraryServiceProtocol = OpenLibraryService()
    
    var ongoingRequest: DataTask<JSON>?
    
    func searchForBook(title: String, author: String) async -> Book? {
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
            let response = await AF.request(url).serializingDecodable(JSON.self).response
            switch response.result {
            case .success(let json):
                let numFound = json["numFound"].intValue
                
                if numFound == 0 { return nil }
                
                if numFound > 0 {
                    let closestResult =  json["docs"].arrayValue.first { json in
                        let closestBook = Book(json: json)
                        return Tools.levenshtein(aStr: title, bStr: closestBook.title) < title.count/3 && Tools.levenshtein(aStr: author, bStr: closestBook.author.name) < 3 && !closestBook.id.isEmpty
                    }
                    
                    if let bookJson = closestResult {
                        let book = Book(json: bookJson)
                        return book
                    }
                    else if let bookJson = json["docs"].arrayValue.first {
                        let book = Book(json: bookJson)
                        return book
                    }
                }
            case .failure(let error):
                print(error)
                return nil
            }
        }
        
        return nil
    }
    
    func wideSearchForBook(query: String) async -> Book? {
        var components = URLComponents(string: "https://openlibrary.org/search.json")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query)]
        if let url = components?.url
        {
            let response = await AF.request(url).serializingDecodable(JSON.self).response
            switch response.result {
            case .success(let json):
                let numFound = json["numFound"].intValue
                
                if numFound == 0 { return nil }
                
                if numFound > 0 {
                    let closestResult =  json["docs"].arrayValue.first { json in
                        let closestBook = Book(json: json)
                        return Tools.levenshtein(aStr: query, bStr: closestBook.title) < query.count/3 || Tools.levenshtein(aStr: query, bStr: closestBook.author.name) < query.count/3
                    }
                    
                    if let bookJson = closestResult {
                        let book = Book(json: bookJson)
                        return book
                    }
                    else if let bookJson = json["docs"].arrayValue.first {
                        let book = Book(json: bookJson)
                        return book
                    }
                }
            case .failure(let error):
                print(error)
                return nil
            }
        }
        return nil
    }
    
    func searchForBooks(title: String?, author: String?, query: String?) async -> ([Book], Bool) {
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
            ongoingRequest = AF.request(url).serializingDecodable(JSON.self)
            
            let response = await ongoingRequest!.response
            switch response.result
            {
            case .success(let json):
                let numFound = json["numFound"].intValue
                if numFound == 0 { return ([Book](), false) }
                if numFound > 0 {
                    let bookResults = json["docs"].arrayValue.map({ return Book(json: $0)})
                    return(bookResults, false)
                }
            case .failure(let error):
                print(error)
                return ([Book](), true)
            }
        }
        
        return ([Book](), true)
    }
}
