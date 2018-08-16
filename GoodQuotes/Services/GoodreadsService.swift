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
    
    func loginToGoodreadsAccount(sender: UIViewController) {
        
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
                    self.loginToUser(oauthswift)
            },
                failure: { error in
                    print( "ERROR ERROR: \(error.localizedDescription)", terminator: "")
            })
        }
        else {
            oauthswift.client.credential.oauthToken = authToken
            oauthswift.client.credential.oauthTokenSecret = authSecret
            
            loginToUser(oauthswift)
        }
    }
    
    func loginToUser(_ oauthswift: OAuth1Swift) {
        let _ = oauthswift.client.get(
            "https://www.goodreads.com/api/auth_user",
            success: { response in
                let xml = try! XML.parse(response.string!)
                guard let id = xml["GoodreadsResponse", "user"].attributes["id"] else {
                    return
                }
                self.id = id
                
        }, failure: { error in
            print(error)
        })
    }
    
    func loadShelves() {
        
    }
}
