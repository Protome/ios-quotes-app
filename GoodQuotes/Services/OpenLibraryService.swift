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

class OpenLibraryService {
    static var sharedInstance = OpenLibraryService()
    
    func searchForBook(title: String, author: String, completion:  @escaping (Book?) -> ())
    {
        var titleQuery = title
        if title.contains("(") {
            let titleSplit = title.components(separatedBy: "(")
            titleQuery = titleSplit.first ?? titleQuery
        }
        
        var components = URLComponents(string: "https://openlibrary.org/search.json")
        components?.queryItems = [
            URLQueryItem(name: "author", value: author),
            URLQueryItem(name: "title", value: titleQuery)]
        if let url = components?.url
        {
            Alamofire.request(url).responseJSON { response in
                if let jsonResponse = response.result.value {
                    let json = JSON(jsonResponse)
                    let numFound = json["numFound"].intValue
                    
                    if numFound == 0 { completion(nil) }
                    
                    if numFound > 0, let bookJson = json["docs"].arrayValue.first {
                        let book = Book(json: bookJson)
                        completion(book)
                    }
                }
            }
        }
    }
}
