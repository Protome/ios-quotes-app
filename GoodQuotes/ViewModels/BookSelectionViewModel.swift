//
//  BookSelectionViewModel.swift
//  GoodQuotes
//
//  Created by Kieran on 11/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import Foundation

class BookSelectionViewModel {
    private var goodreadsService: GoodreadsServiceProtocol
    private var defaultsService: UserDefaultsServiceProtocol
    
    let buffer = 15
    var books = [Book]()
    var shelf: Shelf?
    var pages: Pages?
    var isLoading = false
    var selectedBook: Book?
    
    var title: String { shelf?.name ?? "Shelves" }
    
    init(goodreadsService: GoodreadsServiceProtocol = GoodreadsService(), defaultsService: UserDefaultsServiceProtocol = UserDefaultsService()) {
        self.goodreadsService = goodreadsService
        self.defaultsService = defaultsService
    }
    
    func loadBooksFromShelf(sender: NSObject) async -> Void {
        guard let shelf = shelf, !isLoading else {
            return
        }
        
        isLoading = true
        
        await goodreadsService.loginToGoodreads(sender: sender)
        let result = await goodreadsService.getBooksFromShelf(sender: sender, shelf: shelf, page: pages?.nextPage ?? 1)
        pages = result?.pages
        if let pages = pages, pages.currentPage == 1 {
            books = result?.books ?? [Book]()
        }
    }
    
    func selectBook(selected: Int) {
        selectedBook = books[selected]
        defaultsService.storeBook(book: selectedBook!)
    }
    
}
