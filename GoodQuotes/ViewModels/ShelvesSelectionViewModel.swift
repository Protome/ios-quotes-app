//
//  ShelvesSelectionViewModel.swift
//  GoodQuotes
//
//  Created by Kieran on 11/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import Foundation

class ShelvesSelectionViewModel {
    private var userDefaultsService: UserDefaultsServiceProtocol
    private var goodreadsService: GoodreadsServiceProtocol
    
    var currentShelf = ""
    var shelves = [Shelf]()
    
    init(userDefaultsService: UserDefaultsServiceProtocol = UserDefaultsService(), goodreadsService: GoodreadsServiceProtocol = GoodreadsService(), currentShelf: String = "", shelves: [Shelf] = [Shelf]()) {
        self.userDefaultsService = userDefaultsService
        self.goodreadsService = goodreadsService
        self.currentShelf = currentShelf
        self.shelves = shelves
    }
    
    func loadShelves(sender: NSObject) async -> Void {
        shelves = await goodreadsService.loadShelves(sender: sender) ?? [Shelf]()
        loadSavedShelf()
    }
    
    func loadSavedShelf() {
        let savedShelf = userDefaultsService.loadDefaultShelf()
        
        if let shelf = savedShelf {
            currentShelf = shelf
        }
    }
    
    func selectShelf(selected: Int) {
        currentShelf = shelves[selected].name
    }
}
