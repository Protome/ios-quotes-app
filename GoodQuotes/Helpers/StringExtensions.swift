//
//  StringExtensions.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 21/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation

extension String {
    func withoutSpecialCharacters(separator: String?) -> String {
        let disallowedChars = CharacterSet.init(charactersIn: "=&*^()%$£@!|\\/.")
        return self.components(separatedBy: disallowedChars).joined(separator: separator ?? "")
    }
}
