//
//  BookSelectionShelfListViewModel.swift
//  GoodQuotes
//
//  Created by Kieran on 11/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import Foundation

class BookSelectionShelfListViewModel {
    private var goodreadsService: GoodreadsServiceProtocol
    
    var shelves = [Shelf]()
    var selectedShelf: Shelf?
    
    var title: String { selectedShelf?.name ?? "Shelves" }
    
    init(goodreadsService: GoodreadsServiceProtocol) {
        self.goodreadsService = goodreadsService
    }
    
    func loadBooksFromShelf(sender: NSObject) async -> Void {
        await goodreadsService.loginToGoodreads(sender: sender)
        shelves = await goodreadsService.loadShelves(sender: sender) ?? [Shelf]()
    }
    
    func selectShelf(selected: Int) {
        selectedShelf = shelves[selected]
    }
}
