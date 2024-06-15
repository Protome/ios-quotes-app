//
//  QuoteScraperService.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 16/04/2024.
//  Copyright © 2024 Protome. All rights reserved.
//

import Foundation
import SwiftSoup

class QuoteScraperService: QuoteServiceProtocol {
    func getRandomQuote() async -> Quote {
        let defaultsService = UserDefaultsService()
        let searchType = defaultsService.loadCurrentFilterType()
        
        switch searchType {
        case .None: return await getFullyRandomQuote()
        case .Book:
            let searchTerm = defaultsService.loadBook()
            return await getBookQuote(book: searchTerm!)
            
        case .Search:
            let searchTerm = defaultsService.loadSearch()
            return await getAuthorQuote(author: searchTerm ?? "")
        case .Tag:
            //TODO: Implement this
            return await getFullyRandomQuote()
        }
    }
    
    func getFullyRandomQuote() async -> Quote {
        let author = randomAuthor()
        let pageCount = await getTotalPageNumberForString(query: "\(author)")
        let randomPage = Int(arc4random_uniform(UInt32(pageCount)))
        let quotes = await getAllQuotesForStringAtPage(query: "\(author)", pageNumber: randomPage)
        
        if quotes.count == 0 {
            return await self.getRandomQuote()
        }
        else {
            let random = Int(arc4random_uniform(UInt32(quotes.count)))
            return quotes[random]
        }
    }
    
    func getAuthorQuote(author: String) async -> Quote {
        let editedAuthor = author.components(separatedBy: .whitespaces).joined(separator: "+")
        let pages = await getTotalPageNumberForString(query: editedAuthor)
        let randomPage = Int(arc4random_uniform(UInt32(pages)))
        let quotes = await getAllQuotesForStringAtPage(query: editedAuthor, pageNumber: randomPage)
        if quotes.count == 0 {
            return await getFullyRandomQuote()
        }
        else {
            let random = Int(arc4random_uniform(UInt32(quotes.count)))
            return quotes[random]
        }
    }
    
    func getBookQuote(book: Book) async -> Quote {
        var editedTitle = book.title
        editedTitle.unicodeScalars.removeAll(where: { !CharacterSet.alphanumerics.contains($0) && !CharacterSet.whitespaces.contains($0) })
        editedTitle = editedTitle.components(separatedBy: .whitespaces).joined(separator: "+")
        
        //The OpenLibrary API sometimes returns Translators as additional authors, but that breaks the search as Goodreads doesn't list them, so remove them (sorry translators!) - KB
        var firstAuthor = book.author.name.split(separator: ",").first ?? ""
        firstAuthor.unicodeScalars.removeAll(where: { !CharacterSet.alphanumerics.contains($0) && !CharacterSet.whitespaces.contains($0) })
        let editedAuthor = firstAuthor.components(separatedBy: .whitespaces).joined(separator: "+")
        let query = "\(editedTitle)+\(editedAuthor)"
        
        let pagesNumber = await getTotalPageNumberForString(query: query)
        let randomPage = Int(arc4random_uniform(UInt32(pagesNumber)))
        let allQuotesForPage = await getAllQuotesForStringAtPage(query: query, pageNumber: randomPage)
        
        if allQuotesForPage.count == 0 {
            return await getFullyRandomQuote()
        }
        
        let filteredQuotes = allQuotesForPage.filter({ quote in
            let authorMatches = quote.author == book.author.name
            let titleMatches = quote.publication == book.title
            return authorMatches && titleMatches
        })
        
        let listToUse = filteredQuotes.count > 0 ? filteredQuotes : allQuotesForPage
        
        let random = Int(arc4random_uniform(UInt32(listToUse.count)))
        return listToUse[random]
    }
    
    func randomAuthor() -> Character {
        let allowedChars = "bcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomNum = Int(arc4random_uniform(UInt32(allowedChars.count)))
        let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
        return allowedChars[randomIndex]
    }
}

private extension QuoteScraperService {
    func getTotalPageNumberForString(query: String) async -> Int {
        let url = "https://www.goodreads.com/search?page=\(1)&q=\(query)&search%5Bfield%5D=author&search_type=quotes&tab=quotes"
        
        do {
            guard let url = URL(string:url) else { return 0 }
            let html = try String(contentsOf: url)
            let document = try SwiftSoup.parse(html)
            let totalPages = try document.select(".next_page").first()?.previousElementSibling()?.text()
            
            return Int(totalPages ?? "0") ?? 0
        } catch Exception.Error(let type, let message) {
            print("\(type): \(message)")
        } catch {
            print("")
        }
        
        return 0
    }
    
    func getAllQuotesForStringAtPage(query: String, pageNumber: Int) async -> [Quote] {
        let url = "https://www.goodreads.com/search?page=\(pageNumber)&q=\(query)&search%5Bfield%5D=author&search_type=quotes&tab=quotes"
        
        do {
            guard let url = URL(string:url) else { return [] }
            let html = try String(contentsOf: url)
            let document = try SwiftSoup.parse(html)
            
            var quotes: [Quote] = []
            let quoteTexts = try document.select(".quoteText")
            
            quoteTexts.forEach({ element in
                let quoteText = element.textNodes().first?.text() ?? ""
                let author = element.children().count > 1 ? (try? element.children()[1].text()) ?? "" : ""
                let bookTitle = element.children().count > 2 ? (try? element.children()[2].text()) ?? "" : ""
                
                quotes.append(Quote(quote: quoteText, author: author, publication: bookTitle))
            })
            
            return quotes
        } catch Exception.Error(let type, let message) {
            print("\(type): \(message)")
        } catch {
            print("")
        }
        
        return []
    }
}
