//
//  AuthStorageService.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 16/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation

struct TokenConfiguration {
    static let serviceName = "GoodreadsAuth"
    static let accountName = "GoodreadsAuthToken"
    static let accessGroup: String? = nil
}

struct TokenSecretConfiguration {
    static let serviceName = "GoodreadsAuth"
    static let accountName = "GoodreadsAuthTokenSecret"
    static let accessGroup: String? = nil
}

struct AuthStorageService {
    
    static func saveAuthToken(_ token: String) {
        guard !token.isEmpty else {
            return
        }
        
        do {
            let tokenItem = KeychainPasswordItem(service: TokenConfiguration.serviceName, account: TokenConfiguration.accountName, accessGroup: TokenConfiguration.accessGroup)
            try tokenItem.savePassword(token)
        } catch {
            print(error)
        }
    }
    
    static func readAuthToken() -> String {
        do {
            let tokenItem = KeychainPasswordItem(service: TokenConfiguration.serviceName, account: TokenConfiguration.accountName, accessGroup: TokenConfiguration.accessGroup)
            let token = try tokenItem.readPassword()
            return token
        } catch {
            print(error)
        }
        
        return ""
    }
    
    static func removeAuthToken() {
        do {
            let tokenItem = KeychainPasswordItem(service: TokenConfiguration.serviceName, account: TokenConfiguration.accountName, accessGroup: TokenConfiguration.accessGroup)
            try tokenItem.deleteItem()
        } catch {
            print(error)
        }
    }
    
    static func saveTokenSecret(_ secret: String) {
        guard !secret.isEmpty else {
            return
        }
        
        do {
            let secretItem = KeychainPasswordItem(service: TokenSecretConfiguration.serviceName, account: TokenSecretConfiguration.accountName, accessGroup: TokenSecretConfiguration.accessGroup)
            try secretItem.savePassword(secret)
        } catch {
            print(error)
        }
    }
    
    static func readTokenSecret() -> String {
        do {
            let secretItem = KeychainPasswordItem(service: TokenSecretConfiguration.serviceName, account: TokenSecretConfiguration.accountName, accessGroup: TokenSecretConfiguration.accessGroup)
            let secret = try secretItem.readPassword()
            return secret
        } catch {
            print(error)
        }
        
        return ""
    }
    
    static func removeTokenSecret() {
        do {
            let secretItem = KeychainPasswordItem(service: TokenSecretConfiguration.serviceName, account: TokenSecretConfiguration.accountName, accessGroup: TokenSecretConfiguration.accessGroup)
            try secretItem.deleteItem()
        } catch {
            print(error)
        }
    }
}
