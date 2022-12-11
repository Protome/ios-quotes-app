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
    var isLoading = false
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
    
    func loadRandomQuote() async -> Void {
        if isLoading { return }
        
        isLoading = true
        let quote = await quoteService.getRandomQuote()
        currentQuote = quote
        isLoading = false
    }
    
    //Search OpenLibrary for books with matching titles and author names.
    func updateBookDetailsFromService() async -> Void {
        guard let currentQuote = currentQuote, !currentQuote.publication.isEmpty else {
            self.currentBook = nil
            return
        }
        
        let deadlineTime = DispatchTime.now() + .seconds(5)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.reviewService.showReview()
        }
        
        let book = await openLibraryservice.searchForBook(title: currentQuote.publication, author: currentQuote.author)
        
        guard let bookResult = book else {
            await self.updateBookDetailsFromWiderSearch()
            return
        }
        
        await self.populateMissingBookDataFromGoodreads(bookResult: bookResult)
    }
    
    //If we cannot find any matches for the book, loosen our search params
    private func updateBookDetailsFromWiderSearch() async -> Void {
        guard let currentQuote = currentQuote else { return }
        
        let book = await openLibraryservice.wideSearchForBook(query: currentQuote.publication)
        guard let bookResult = book else {
            self.currentBook = nil
            return
        }
        await self.populateMissingBookDataFromGoodreads(bookResult: bookResult)
    }
    
    //While Goodreads API still works there is some data we need that OpenLibrary does not offer. Populate the missing fields with this. If it fails/the api finally gets shut down there'll be less info but nothing should break.
    private func populateMissingBookDataFromGoodreads(bookResult: Book) async -> Void {
        guard let currentQuote = currentQuote else { return }
        
        let book = await goodreadsService.searchForBook(title: currentQuote.publication, author: currentQuote.author)
        if let book = book {
            var bookCopy = bookResult
            bookCopy.fillMissingDataFromFallback(fallbackBook: book)
            self.currentBook = bookCopy
        }
    }
}
