//
//  GoodreadsServiceProtocol.swift
//  GoodQuotes
//
//  Created by Kieran on 06/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import Foundation
import Combine

protocol GoodreadsServiceProtocol {
    var isLoggedInPublisher: AnyPublisher<LoginState, Never> { get }
    func loginToGoodreads(sender: NSObject) async -> Void
    func logoutOfGoodreadsAccount()
    func loadShelves(sender: NSObject) async -> [Shelf]?
    func searchForBook(title: String, author: String) async -> Book?
    func searchForBooks(title: String, page: Int) async -> ([Book], Int)
    func addBookToShelf(sender: NSObject, bookId: String, completion: @escaping () -> ())
    func getBooksFromShelf(sender: NSObject, shelf: Shelf, page: Int) async -> (books: [Book], pages: Pages)?
}
