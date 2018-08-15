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
    
    func loginToGoodreadsAccount(sender: UIViewController)
    {
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
        
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "Quotey://oauth-callback/goodreads")!,
            success: { credential, response, parameters in
                let test = response
                print(credential)
                print(response)
                //TODO: Handle login response (save user ID etc)
        },
            failure: { error in
                print( "ERROR ERROR: \(error.localizedDescription)", terminator: "")
        }
        )
    }
    
}
