//
//  KeychainError.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 16/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}
