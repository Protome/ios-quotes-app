//
//  UserDefaultsServiceProtocol.swift
//  GoodQuotes
//
//  Created by Kieran on 06/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import Foundation
import UIKit

protocol UserDefaultsServiceProtocol {
    func wipeFilters()
    func storeSearchTerm(search: String)
    func loadSearch() -> String?
    func loadCurrentFilterType() -> FilterType
    func storeBook(book: Book)
    func loadBook() -> Book?
    func removeStoredBook()
    func storeDefaultShelf(shelfName: String)
    func loadDefaultShelf() -> String?
    func storeColours(colours: [UIColor])
    func loadColours() -> [UIColor]?
    func storeBackgroundType(type: String)
    func loadBackgroundType() -> String
}
