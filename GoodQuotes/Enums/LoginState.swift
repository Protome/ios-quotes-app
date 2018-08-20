//
//  LoginState.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 20/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation

enum LoginState: String {
    case LoggedIn
    case LoggedOut
}

extension Notification.Name {
    static var loginStateChanged: Notification.Name {
        return .init(rawValue: LoginState.LoggedIn.rawValue)
    }
}
