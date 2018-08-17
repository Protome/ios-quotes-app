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
    var oauthswift: OAuthSwift?
    var id: String?
    
    func loginToGoodreadsAccount(sender: UIViewController, completion:  @escaping () -> ()) {
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
                    self.loginToUser(oauthswift, completion: completion)
            },
                failure: { error in
                    print( "ERROR ERROR: \(error.localizedDescription)", terminator: "")
            })
        }
        else {
            oauthswift.client.credential.oauthToken = authToken
            oauthswift.client.credential.oauthTokenSecret = authSecret
            
            loginToUser(oauthswift, completion: completion)
        }
    }
    
    func loginToUser(_ oauthswift: OAuth1Swift, completion: @escaping () -> ()) {
        let _ = oauthswift.client.get(
            "https://www.goodreads.com/api/auth_user",
            success: { response in
                let xml = try! XML.parse(response.string!)
                guard let id = xml["GoodreadsResponse", "user"].attributes["id"] else {
                    return
                }
                self.id = id
                
                completion()
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
    
    func searchForBook(title: String, completion:  @escaping (Book) -> ())
    {
        var components = URLComponents(string: "https://www.goodreads.com/search/index.xml")
        components?.queryItems = [
            URLQueryItem(name: "key", value:"\(Bundle.main.localizedString(forKey: "goodreads_key", value: nil, table: "Secrets"))"),
            URLQueryItem(name: "q", value:"\(title)")]
        if let url = components?.url
        {
            Alamofire.request(url).response { response in
                let xml = XML.parse(response.data!)
                let results = xml["GoodreadsResponse", "search", "results", "work"]
                let bestResult = Book(xml: results[0, "best_book"])
                
                completion(bestResult)
            }
        }
    }
    
    func addBookToShelf(sender: UIViewController, bookId: String, completion: @escaping () -> ())
    {
        if oauthswift == nil || oauthswift!.client.credential.oauthToken.isEmpty {
            loginToGoodreadsAccount(sender: sender) { self.addBookToShelf(sender: sender, bookId: bookId, completion: completion) }
            return
        }
        
        let userDefaults = UserDefaultsService()
        let shelfName = userDefaults.loadDefaultShelf() ?? "to-read"
        let parameters = ["name" : shelfName,
                          "book_id" : bookId]
        
        let _ = oauthswift?.client.post("https://www.goodreads.com/shelf/add_to_shelf.xml",
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
}
