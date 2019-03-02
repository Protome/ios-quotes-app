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
    let filterKey = "Filter"
    let typeKey = "Type"
    let shelfKey = "GoodreadsShelf"
    let bookKey = "Book"
    
    func wipeFilters()
    {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: filterKey)
        defaults.removeObject(forKey: typeKey)
        defaults.removeObject(forKey: bookKey)
    }
    
    func storeFilter(filter: String, type: FilterType)
    {
        let defaults = UserDefaults.standard
        defaults.set(filter, forKey: filterKey)
        defaults.set(type.rawValue, forKey: typeKey)
    }
    
    func loadFilters() -> (filter: String, type: FilterType)?
    {
        let defaults = UserDefaults.standard
        guard let filter = defaults.string(forKey: filterKey), let type = FilterType(rawValue: defaults.integer(forKey: typeKey)) else
        {
            return nil
        }
        
        return (filter: filter, type:type)
    }
    
    func storeBook(book: Book)
    {
        do {
            let defaults = UserDefaults.standard
            let data = try PropertyListEncoder().encode(book)
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: data)
            defaults.set(encodedData, forKey: bookKey)
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
        
        return nil
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
