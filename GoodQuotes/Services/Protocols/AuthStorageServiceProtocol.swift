//
//  AuthStorageServiceProtocol.swift
//  GoodQuotes
//
//  Created by Kieran on 06/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import Foundation

protocol AuthStorageServiceProtocol {
    static func saveAuthToken(_ token: String)
    static func readAuthToken() -> String
    static func removeAuthToken()
    static func saveTokenSecret(_ secret: String)
    static func readTokenSecret() -> String
    static func removeTokenSecret()
}
