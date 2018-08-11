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
    
    func wipeFilters()
    {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: filterKey)
        defaults.removeObject(forKey: typeKey)
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
}
