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

class GoodreadsService {
    static var sharedInstance = GoodreadsService()
    
    var isLoggedIn = LoginState.LoggedOut {
        didSet {
            NotificationCenter.default.post(name: .loginStateChanged, object: nil)
        }
    }
    
    var oauthswift: OAuthSwift?
    var id: String?
    var ongoingRequest: DataRequest?
    
    func loginToGoodreadsAccount(sender: UIViewController, completion:  (() -> ())?) {
        let oauthswift = OAuth1Swift(
            consumerKey:        Bundle.main.localizedString(forKey: "goodreads_key", value: nil, table: "Secrets"),
            consumerSecret:     Bundle.main.localizedString(forKey: "goodreads_secret", value: nil, table: "Secrets"),
            requestTokenUrl:    "https://www.goodreads.com/oauth/request_token",
            authorizeUrl:       "https://www.goodreads.com/oauth/authorize?mobile=1",
            accessTokenUrl:     "https://www.goodreads.com/oauth/access_token"
        )
        
        self.oauthswift=oauthswift
        oauthswift.allowMissingOAuthVerifier = true
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: sender, oauthSwift: self.oauthswift!)
        
        let authToken = AuthStorageService.readAuthToken()
        let authSecret = AuthStorageService.readTokenSecret()
        
        if authToken.isEmpty || authSecret.isEmpty{
            let _ = oauthswift.authorize(
                withCallbackURL: URL(string: "Quotey://oauth-callback/goodreads")!,
                success: { credential, response, parameters in
                    AuthStorageService.saveAuthToken(credential.oauthToken)
                    AuthStorageService.saveTokenSecret(credential.oauthTokenSecret)
                    self.isLoggedIn = .LoggedIn
                    self.loginToUser(oauthswift, completion: completion)
            },
                failure: { error in
                    self.oauthswift = nil
                    print( "ERROR ERROR: \(error.localizedDescription)", terminator: "")
            })
        }
        else {
            oauthswift.client.credential.oauthToken = authToken
            oauthswift.client.credential.oauthTokenSecret = authSecret
            self.isLoggedIn = .LoggedIn
            loginToUser(oauthswift, completion: completion)
        }
    }
    
    func logoutOfGoodreadsAccount() {
        AuthStorageService.removeAuthToken()
        AuthStorageService.removeTokenSecret()
        oauthswift = nil
        isLoggedIn = .LoggedOut
    }
    
    func loginToUser(_ oauthswift: OAuth1Swift, completion: (() -> ())?) {
        let _ = oauthswift.client.get(
            "https://www.goodreads.com/api/auth_user",
            success: { response in
                let xml = try! XML.parse(response.string!)
                guard let id = xml["GoodreadsResponse", "user"].attributes["id"] else {
                    return
                }
                self.id = id
                
                completion?()
        }, failure: { error in
            print(error)
        })
    }
    
    func loadShelves(sender: UIViewController, completion: (([Shelf]) -> ())?) {
        guard let _ = self.id else {
            loginToGoodreadsAccount(sender: sender) {
                self.loadShelves(sender: sender, completion: completion)
            }
            return
        }
        
        var components = URLComponents(string: "https://www.goodreads.com/shelf/list.xml")
        components?.queryItems = [
            URLQueryItem(name: "key", value:"\(Bundle.main.localizedString(forKey: "goodreads_key", value: nil, table: "Secrets"))"),
            URLQueryItem(name: "user_id", value:"\(id ?? "")")]
        if let url = components?.url
        {
            Alamofire.request(url).response { response in
                let xml = XML.parse(response.data!)
                let shelves = xml["GoodreadsResponse", "shelves", "user_shelf"].map {
                    return Shelf(id: $0["id"].text, name: $0["name"].text, book_count: $0["book_count"].int) }
                
                completion?(shelves)
            }
        }
    }
    
    func searchForBook(title: String, author: String, completion:  @escaping (Book) -> ())
    {
        var components = URLComponents(string: "https://www.goodreads.com/search/index.xml")
        components?.queryItems = [
            URLQueryItem(name: "key", value:"\(Bundle.main.localizedString(forKey: "goodreads_key", value: nil, table: "Secrets"))"),
            URLQueryItem(name: "q", value:"\(title)+\(author)")]
        if let url = components?.url
        {
            Alamofire.request(url).response { response in
                let xml = XML.parse(response.data!)
                let results = xml["GoodreadsResponse", "search", "results", "work"]
                let bestResult = Book(xml: results[0])
                
                completion(bestResult)
            }
        }
    }
    
    func searchForBooks(title: String, page: Int, completion:  @escaping ([Book], Int) -> ())
    {
        var components = URLComponents(string: "https://www.goodreads.com/search/index.xml")
        components?.queryItems = [
            URLQueryItem(name: "key", value:"\(Bundle.main.localizedString(forKey: "goodreads_key", value: nil, table: "Secrets"))"),
            URLQueryItem(name: "q", value:title),
            URLQueryItem(name: "page", value:"\(page)")]
        if let url = components?.url
        {
            ongoingRequest?.cancel()
            ongoingRequest = Alamofire.request(url).response { response in
                guard response.error == nil else {
                    return
                }
                
                let xml = XML.parse(response.data!)
                let searchResults = xml["GoodreadsResponse", "search"]
                let totalResults = searchResults["total-results"].double ?? 0
                let pages = ceil(totalResults/18)
                let results = xml["GoodreadsResponse", "search", "results", "work"]
                let bookResults =  results.map({  return Book(xml: $0) })
                
                completion(bookResults, Int(pages))
            }
        }
    }
    
    func addBookToShelf(sender: UIViewController, bookId: String, completion: @escaping () -> ())
    {
        guard let oauthswift = oauthswift, self.isLoggedIn == LoginState.LoggedIn else {
            loginToGoodreadsAccount(sender: sender) { self.addBookToShelf(sender: sender, bookId: bookId, completion: completion) }
            return
        }
        
        let userDefaults = UserDefaultsService()
        let shelfName = userDefaults.loadDefaultShelf() ?? "to-read"
        let parameters = ["name" : shelfName,
                          "book_id" : bookId]
        
        let _ = oauthswift.client.post("https://www.goodreads.com/shelf/add_to_shelf.xml",
                                       parameters: parameters,
                                       headers: nil,
                                       body: nil,
                                       success: { response in
                                        completion()
        }, failure: { error in
            completion()
            print(error)
        })
    }
    
    func getBooksFromShelf(sender: UIViewController, shelf: Shelf, page: Int, completion: (([Book], Pages) -> ())?)
    {
        guard let _ = self.id else {
            loginToGoodreadsAccount(sender: sender) {
                self.getBooksFromShelf(sender: sender, shelf: shelf, page: page, completion: completion)
            }
            return
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
            Alamofire.request(url).response { response in
                let xml = XML.parse(response.data!)
                let books = xml["GoodreadsResponse", "books", "book"].map {
                    return Book(bookXml: $0)
                }
                
                let booksXml = xml["GoodreadsResponse", "books"]
                let pages = Pages(xml: booksXml)
                
                completion?(books, pages)
            }
        }
    }
}
