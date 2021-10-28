//
//  UserDefaultsService.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 11/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import UIKit

class UserDefaultsService
{
    let searchKey = "Search"
    let typeKey = "Type"
    let shelfKey = "GoodreadsShelf"
    let bookKey = "Book"
    let backgroundColour1 = "BackgroundColour1"
    let backgroundColour2 = "BackgroundColour2"
    let backgroundType = "BackgroundType"
    
    func wipeFilters()
    {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: searchKey)
        defaults.removeObject(forKey: typeKey)
        defaults.removeObject(forKey: bookKey)
        defaults.removeObject(forKey: backgroundColour1)
        defaults.removeObject(forKey: backgroundColour2)
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
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            defaults.set(encodedData, forKey: bookKey)
            defaults.set(FilterType.Book.rawValue, forKey: typeKey)
        } catch {
            print("Save Failed")
        }
    }
    
    func loadBook() -> Book?
    {
        do {
            
            let defaults = UserDefaults.standard
            guard let defaultsBook = defaults.object(forKey: bookKey) as? Data, let bookData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(defaultsBook) as? Data else
            {
                return nil
            }
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
    
    func storeColours(colours: [UIColor])
    {
        let defaults = UserDefaults.standard
        defaults.set(colours[0], forKey: backgroundColour1)
        defaults.set(colours[1], forKey: backgroundColour2)
    }
    
    func loadColours() -> [UIColor]?
    {
        let defaults = UserDefaults.standard
        guard let colour1 = defaults.color(forKey: backgroundColour1),
            let colour2 = defaults.color(forKey: backgroundColour2)
            else
        {
            return nil
        }
        
        return [colour1, colour2]
    }
    
    func storeBackgroundType(type: String)
    {
        let defaults = UserDefaults.standard
        defaults.set(type, forKey: backgroundType)
    }
    
    func loadBackgroundType() -> String
    {
        let defaults = UserDefaults.standard
        guard let backgroundType = defaults.string(forKey: backgroundType)
            else
        {
            return "GreenGradient"
        }
        
        return backgroundType
    }
}
