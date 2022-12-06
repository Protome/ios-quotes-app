//
//  GoodreadsServiceProtocol.swift
//  GoodQuotes
//
//  Created by Kieran on 06/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import Foundation
import UIKit

protocol GoodreadsServiceProtocol {
    static var sharedInstance: GoodreadsServiceProtocol { get }
    var isLoggedIn: LoginState { get set }
    func loginToGoodreadsAccount(sender: UIViewController, completion:  (() -> ())?)
    func logoutOfGoodreadsAccount()
    func loadShelves(sender: UIViewController, completion: (([Shelf]) -> ())?)
    func searchForBook(title: String, author: String, completion:  @escaping (Book) -> ())
    func searchForBooks(title: String, page: Int, completion:  @escaping ([Book], Int) -> ())
    func addBookToShelf(sender: UIViewController, bookId: String, completion: @escaping () -> ())
    func getBooksFromShelf(sender: UIViewController, shelf: Shelf, page: Int, completion: (([Book], Pages) -> ())?)
}
