//
//  OpenLibraryServiceProtocol.swift
//  GoodQuotes
//
//  Created by Kieran on 06/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import Foundation

protocol OpenLibraryServiceProtocol {
    static var sharedInstance: OpenLibraryServiceProtocol { get }
    func searchForBook(title: String, author: String, completion:  @escaping (Book?) -> ())
    func wideSearchForBook(query: String, completion:  @escaping (Book?) -> ())
    func searchForBooks(title: String?, author: String?, query: String?, completion:  @escaping ([Book], Bool) -> ())
}
