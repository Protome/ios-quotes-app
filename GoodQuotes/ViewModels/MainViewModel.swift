//
//  MainViewModel.swift
//  GoodQuotes
//
//  Created by Kieran on 06/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import Foundation

class MainViewModel {
    private var quoteService : QuoteServiceProtocol
    private var reviewService : ReviewRequestServiceProtocol
    private var goodreadsService: GoodreadsServiceProtocol
    private var openLibraryservice: OpenLibraryServiceProtocol
    
    let averageRatingText = "Average Rating:"
    var currentBook: Book?
    var currentQuote: Quote?
    var bookTitle: String { currentBook?.title ?? "" }
    var authorName: String { currentBook?.author.name ?? "" }
    var publishDate: String {
        guard let publicationYear = currentBook?.publicationYear else { return "" }
        return "First published \(publicationYear)"
    }
    var showBookDetails: Bool { currentBook != nil }
    
    init(quoteService: QuoteServiceProtocol = QuoteService(), reviewService: ReviewRequestServiceProtocol = ReviewRequestService(), goodreadsService: GoodreadsServiceProtocol = GoodreadsService(), openLibraryservice: OpenLibraryServiceProtocol = OpenLibraryService(), currentBook: Book? = nil, currentQuote: Quote? = nil) {
        self.quoteService = quoteService
        self.reviewService = reviewService
        self.goodreadsService = goodreadsService
        self.openLibraryservice = openLibraryservice
        self.currentBook = currentBook
    }
    
    func loadRandomQuote(completionHandler: @escaping () -> Void) {
        quoteService.getRandomQuote { quote in
            self.currentQuote = quote
            completionHandler()
        }
    }
    
    //Search OpenLibrary for books with matching titles and author names.
    func updateBookDetailsFromService(completionHandler: @escaping () -> Void) {
        guard let currentQuote = currentQuote, !currentQuote.publication.isEmpty else {
            self.currentBook = nil
            completionHandler()
            return
        }
        
        let deadlineTime = DispatchTime.now() + .seconds(5)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.reviewService.showReview()
        }
        
        OpenLibraryService.sharedInstance.searchForBook(title: currentQuote.publication, author: currentQuote.author) { book in
            guard let bookResult = book else {
                self.updateBookDetailsFromWiderSearch(existingCompletionHandler: completionHandler)
                return
            }
            
            self.populateMissingBookDataFromGoodreads(bookResult: bookResult, existingCompletionHandler: completionHandler)
        }
    }
    
    //If we cannot find any matches for the book, loosen our search params
    private func updateBookDetailsFromWiderSearch(existingCompletionHandler: @escaping () -> Void) {
        guard let currentQuote = currentQuote else { return }
        
        openLibraryservice.wideSearchForBook(query: currentQuote.publication) { book in
            guard let bookResult = book else {
                self.currentBook = nil
                existingCompletionHandler()
                return
            }
            self.populateMissingBookDataFromGoodreads(bookResult: bookResult, existingCompletionHandler: existingCompletionHandler)
        }
    }
    
    //While Goodreads API still works there is some data we need that OpenLibrary does not offer. Populate the missing fields with this. If it fails/the api finally gets shut down there'll be less info but nothing should break.
    private func populateMissingBookDataFromGoodreads(bookResult: Book, existingCompletionHandler: @escaping () -> Void) {
        guard let currentQuote = currentQuote else { return }
        
        goodreadsService.searchForBook(title: currentQuote.publication, author: currentQuote.author) { book in
            var bookCopy = bookResult
            bookCopy.fillMissingDataFromFallback(fallbackBook: book)
            self.currentBook = bookCopy
            existingCompletionHandler()
        }
    }
}
