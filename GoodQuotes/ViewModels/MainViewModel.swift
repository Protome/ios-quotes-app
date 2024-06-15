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
    
    @Published var loggedIn = false
    @Published var currentQuote: Quote? = nil
    @Published var currentBook: Book? = nil
    @Published var isLoading = false
    
    let averageRatingText = "Average Rating:"
    var publishDate: String {
        guard let publicationYear = currentBook?.publicationYear else { return "" }
        return "First published \(publicationYear)"
    }
    var showBookDetails: Bool { currentBook != nil }
    
    init(quoteService: QuoteServiceProtocol, reviewService: ReviewRequestServiceProtocol, goodreadsService: GoodreadsServiceProtocol, openLibraryservice: OpenLibraryServiceProtocol, currentBook: Book? = nil, currentQuote: Quote? = nil) {
        self.quoteService = quoteService
        self.reviewService = reviewService
        self.goodreadsService = goodreadsService
        self.openLibraryservice = openLibraryservice
        self.currentBook = currentBook
        
        self.goodreadsService.isLoggedInPublisher
            .map({ return $0 == .LoggedIn })
            .assign(to: &$loggedIn)
    }
    
    func loadRandomQuote() async -> Void {
        if isLoading { return }
        
        isLoading = true
        let quote = await quoteService.getRandomQuote()
        currentQuote = quote
        await updateBookDetailsFromService()
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
    
    func addBookToShelf(sender: NSObject, bookId: String, completion: @escaping () -> ()) {
        goodreadsService.addBookToShelf(sender: sender, bookId: bookId, completion: completion)
    }
    
    func loginToGoodreads(sender: NSObject) async -> Void {
        await goodreadsService.loginToGoodreads(sender: sender)
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
