//
//  AppDelegate.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 09/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import UIKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder {

    var window: UIWindow?
}

// MARK: handle callback url
extension AppDelegate {
    
    func applicationHandle(url: URL) {
        if (url.host == "oauth-callback") {
            OAuthSwift.handle(url: url)
        } else {
            OAuthSwift.handle(url: url)
        }
    }
}

// MARK: ApplicationDelegate
extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        applicationHandle(url: url)
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        applicationHandle(url: url)
        return true
    }
}
