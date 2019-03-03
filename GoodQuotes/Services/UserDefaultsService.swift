//
//  UserDefaultsService.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 11/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation

class UserDefaultsService
{
    let searchKey = "Search"
    let typeKey = "Type"
    let shelfKey = "GoodreadsShelf"
    let bookKey = "Book"
    
    func wipeFilters()
    {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: searchKey)
        defaults.removeObject(forKey: typeKey)
        defaults.removeObject(forKey: bookKey)
    }
    
    func storeSearchTerm(search: String)
    {
        let defaults = UserDefaults.standard
        defaults.set(search, forKey: searchKey)
        defaults.set(FilterType.Search.rawValue, forKey: typeKey)
    }
    
    func loadSearch() -> String?
    {
        let defaults = UserDefaults.standard
        guard let search = defaults.string(forKey: searchKey) else
        {
            return nil
        }
        
        return search
    }
    
    func loadCurrentFilterType() -> FilterType {
        let defaults = UserDefaults.standard
        guard let type = FilterType(rawValue: defaults.integer(forKey: typeKey)) else
        {
            return FilterType.None
        }
        
        return type
    }
    
    func storeBook(book: Book)
    {
        do {
            let defaults = UserDefaults.standard
            let data = try PropertyListEncoder().encode(book)
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: data)
            defaults.set(encodedData, forKey: bookKey)
            defaults.set(FilterType.Book.rawValue, forKey: typeKey)
        } catch {
            print("Save Failed")
        }
    }
    
    func loadBook() -> Book?
    {
        let defaults = UserDefaults.standard
        guard let defaultsBook = defaults.object(forKey: bookKey) as? Data, let bookData = NSKeyedUnarchiver.unarchiveObject(with: defaultsBook) as? Data else
        {
            return nil
        }
        
        do {
            let book = try PropertyListDecoder().decode(Book.self, from: bookData)
            return book
        } catch {
            print("Retrieve Failed")
            return nil
        }
    }
    
    func removeStoredBook() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: bookKey)
    }
    
    func storeDefaultShelf(shelfName: String) {
        let defaults = UserDefaults.standard
        defaults.set(shelfName, forKey: shelfKey)
    }
    
    func loadDefaultShelf() -> String?
    {
        let defaults = UserDefaults.standard
        guard let shelf = defaults.string(forKey: shelfKey) else
        {
            return nil
        }
        
        return shelf
    }
}
