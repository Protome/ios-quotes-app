//
//  GoodreadsService.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 15/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import SwiftyXMLParser
import Alamofire
import OAuthSwift
import OAuthSwiftAlamofire

//Currently using a mix of Swift Concurrency and CompletionHandlers due to OAuthSwift. Need to looking "Continuations"
class GoodreadsService: GoodreadsServiceProtocol {  
    static var sharedInstance: GoodreadsServiceProtocol = GoodreadsService()
    
    var isLoggedIn = LoginState.LoggedOut {
        didSet {
            NotificationCenter.default.post(name: .loginStateChanged, object: nil)
        }
    }
    
    var oauthswift: OAuth1Swift?
    var id: String?
    var ongoingRequest: DataTask<Data>?
    
    func logoutOfGoodreadsAccount() {
        AuthStorageService.removeAuthToken()
        AuthStorageService.removeTokenSecret()
        oauthswift = nil
        isLoggedIn = .LoggedOut
    }
    
    func loadShelves(sender: NSObject) async -> [Shelf]? {
        guard let _ = self.id else {
            await loginToGoodreads(sender: sender)
            return await self.loadShelves(sender: sender)
        }
        
        var components = URLComponents(string: "https://www.goodreads.com/shelf/list.xml")
        components?.queryItems = [
            URLQueryItem(name: "key", value:"\(Bundle.main.localizedString(forKey: "goodreads_key", value: nil, table: "Secrets"))"),
            URLQueryItem(name: "user_id", value:"\(id ?? "")")]
        if let url = components?.url
        {
            let response = await AF.request(url, interceptor: oauthswift!.requestInterceptor).serializingData().response
            switch response.result {
            case .success(let data):
                let xml = XML.parse(data)
                let shelves = xml["GoodreadsResponse", "shelves", "user_shelf"].map {
                    return Shelf(id: $0["id"].text, name: $0["name"].text, book_count: $0["book_count"].int) }
                
                return shelves
            case .failure(let error):
                print(error)
                return nil
            }
        }
        return nil
    }
    
    func searchForBook(title: String, author: String) async -> Book? {
        var components = URLComponents(string: "https://www.goodreads.com/search/index.xml")
        components?.queryItems = [
            URLQueryItem(name: "key", value:"\(Bundle.main.localizedString(forKey: "goodreads_key", value: nil, table: "Secrets"))"),
            URLQueryItem(name: "q", value:"\(title)+\(author.withoutSpecialCharacters(separator: ""))")]
        
        if let url = components?.url
        {
            var task = AF.request(url).serializingData()
            if let oauthswift = oauthswift {
                task = AF.request(url, interceptor: oauthswift.requestInterceptor).serializingData()
            }
            
            let response = await task.response
            switch response.result {
            case .success(let data):
                let xml = XML.parse(data)
                let results = xml["GoodreadsResponse", "search", "results", "work"]
                
                let closestResult =  results.first { xml in
                    let closestBook = Book(xml: xml)
                    return closestBook.title == title && Tools.levenshtein(aStr: author, bStr: closestBook.author.name) < 3
                }
                
                return Book(xml: closestResult ?? results[0])
            case .failure(let error):
                print(error)
                return nil
            }
        }
        return nil
    }
    
    func searchForBooks(title: String, page: Int) async -> ([Book], Int) {
        var components = URLComponents(string: "https://www.goodreads.com/search/index.xml")
        components?.queryItems = [
            URLQueryItem(name: "key", value:"\(Bundle.main.localizedString(forKey: "goodreads_key", value: nil, table: "Secrets"))"),
            URLQueryItem(name: "q", value:title),
            URLQueryItem(name: "page", value:"\(page)")]
        if let url = components?.url
        {
            ongoingRequest?.cancel()
            ongoingRequest = AF.request(url, interceptor: oauthswift!.requestInterceptor).serializingData()
            
            let response = await ongoingRequest!.response
            
            let xml = XML.parse(response.data!)
            let searchResults = xml["GoodreadsResponse", "search"]
            let totalResults = searchResults["total-results"].double ?? 0
            let pages = ceil(totalResults/18)
            let results = xml["GoodreadsResponse", "search", "results", "work"]
            let bookResults =  results.map({  return Book(xml: $0) })
            
            return (bookResults, Int(pages))
        }
        return ([Book](), 0)
    }
    
    func addBookToShelf(sender: NSObject, bookId: String, completion: @escaping () -> ()) {
        guard let oauthswift = oauthswift, self.isLoggedIn == LoginState.LoggedIn else {
            Task { await loginToGoodreadsAccount(sender: sender)
                self.addBookToShelf(sender: sender, bookId: bookId, completion: completion)
            }
            return
        }
        
        let userDefaults = UserDefaultsService()
        let shelfName = userDefaults.loadDefaultShelf() ?? "to-read"
        let parameters = ["name" : shelfName,
                          "book_id" : bookId]
        
        let _ = oauthswift.client.post("https://www.goodreads.com/shelf/add_to_shelf.xml", parameters: parameters, headers: nil, body: nil) { result in
            switch result {
            case .success(_):
                completion()
            case.failure(let error):
                completion()
                print(error)
            }
        }
    }
    
    func getBooksFromShelf(sender: NSObject, shelf: Shelf, page: Int) async -> (books: [Book], pages: Pages)? {
        guard let _ = self.id else {
            await loginToGoodreadsAccount(sender: sender)
            return await self.getBooksFromShelf(sender: sender, shelf: shelf, page: page)
        }
        let urlString = "https://www.goodreads.com/review/list/\(id!).xml"
        var components = URLComponents(string: urlString)
        components?.queryItems = [
            URLQueryItem(name: "key", value: "\(Bundle.main.localizedString(forKey: "goodreads_key", value: nil, table: "Secrets"))"),
            URLQueryItem(name: "shelf", value: shelf.name),
            URLQueryItem(name: "per_page", value: String(describing: 50)),
            URLQueryItem(name: "page", value: String(describing: page)),
        ]
        
        if let url = components?.url
        {
            let response = await AF.request(url, interceptor: oauthswift!.requestInterceptor).serializingData().response
            switch response.result {
            case .success(let data):
                let xml = XML.parse(data)
                let books = xml["GoodreadsResponse", "books", "book"].map {
                    return Book(bookXml: $0)
                }
                
                let booksXml = xml["GoodreadsResponse", "books"]
                let pages = Pages(xml: booksXml)
                
                return (books, pages)
            case .failure(let error):
                print(error)
                return nil
            }
        }
        return nil
    }
    
    func loginToGoodreads(sender: NSObject) async -> Void {
        await loginToGoodreadsAccount(sender: sender)
        if let oauthswift = oauthswift {
            await loginToUser(oauthswift)
        }
    }
    
    internal func loginToGoodreadsAccount(sender: NSObject) async -> Void {
        return await withCheckedContinuation { continuation in
            let oauthswift = OAuth1Swift(
                consumerKey:        Bundle.main.localizedString(forKey: "goodreads_key", value: nil, table: "Secrets"),
                consumerSecret:     Bundle.main.localizedString(forKey: "goodreads_secret", value: nil, table: "Secrets"),
                requestTokenUrl:    "https://www.goodreads.com/oauth/request_token",
                authorizeUrl:       "https://www.goodreads.com/oauth/authorize?mobile=1",
                accessTokenUrl:     "https://www.goodreads.com/oauth/access_token"
            )
            
            self.oauthswift=oauthswift
            oauthswift.allowMissingOAuthVerifier = true
            oauthswift.authorizeURLHandler = SafariURLHandler(viewController: sender as! UIViewController, oauthSwift: self.oauthswift!)
            
            let authToken = AuthStorageService.readAuthToken()
            let authSecret = AuthStorageService.readTokenSecret()
            
            if authToken.isEmpty || authSecret.isEmpty{
                let _ = oauthswift.authorize(
                    withCallbackURL: "Quotey://oauth-callback/goodreads") { result in
                        switch result {
                        case .success(let (credential, _, _)):
                            AuthStorageService.saveAuthToken(credential.oauthToken)
                            AuthStorageService.saveTokenSecret(credential.oauthTokenSecret)
                            self.isLoggedIn = .LoggedIn
                        case .failure(let error):
                            self.oauthswift = nil
                            print( "ERROR ERROR: \(error.localizedDescription)", terminator: "")
                        }
                    }
            }
            else {
                oauthswift.client.credential.oauthToken = authToken
                oauthswift.client.credential.oauthTokenSecret = authSecret
                self.isLoggedIn = .LoggedIn
            }
            
            continuation.resume()
        }
    }
    
    internal func loginToUser(_ oauthswift: OAuth1Swift) async -> Void {
        return await withCheckedContinuation { continuation in
            let _ = oauthswift.client.get(
                "https://www.goodreads.com/api/auth_user") { result in
                    switch result {
                    case .success(let response):
                        let xml = try! XML.parse(response.string!)
                        guard let id = xml["GoodreadsResponse", "user"].attributes["id"] else {
                            return
                        }
                        self.id = id
                    case .failure(let error):
                        print(error)
                    }
                    
                    continuation.resume()
                }
        }
    }
}
