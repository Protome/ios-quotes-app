//
//  BookSelectionViewModelTests.swift
//  GoodQuotesTests
//
//  Created by Kieran on 12/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import XCTest
import Mockingbird
@testable import GoodQuotes

class BookSelectionViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadBooksFromShelvesCallsServices() async {
        let dummyNSObject = NSObject()
        let dummyShelf = Shelf(id: "", name: "", book_count: 0)
        
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        given(await goodreadsMock.getBooksFromShelf(sender: any(), shelf: any(), page: any())).willReturn(nil)
        
        let viewModel = BookSelectionViewModel(goodreadsService: goodreadsMock)
        viewModel.shelf = dummyShelf
        await viewModel.loadBooksFromShelf(sender: dummyNSObject)
        
        verify(await goodreadsMock.loginToGoodreads(sender: dummyNSObject)).wasCalled()
        verify(await goodreadsMock.getBooksFromShelf(sender: dummyNSObject, shelf: any(), page: any())).wasCalled()
        XCTAssertEqual(0, viewModel.books.count)
    }
    
    func testLoadBooksFromShelvesPopulatesBooks_WhenServiceReturnsData() async {
        let dummyNSObject = NSObject()
        let dummyShelf = Shelf(id: "", name: "", book_count: 0)
        let dummyBookArray = [Book(), Book(), Book(), Book()]
        let dummyPages = Pages()

        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        given(await goodreadsMock.getBooksFromShelf(sender: any(), shelf: any(), page: any())).willReturn((dummyBookArray, dummyPages))

        let viewModel = BookSelectionViewModel(goodreadsService: goodreadsMock)
        viewModel.shelf = dummyShelf
        await viewModel.loadBooksFromShelf(sender: dummyNSObject)

        verify(await goodreadsMock.loginToGoodreads(sender: dummyNSObject)).wasCalled()
        verify(await goodreadsMock.getBooksFromShelf(sender: dummyNSObject, shelf: any(), page: any())).wasCalled()
        XCTAssertEqual(dummyBookArray.count, viewModel.books.count)
        XCTAssertEqual(dummyPages.currentPage, viewModel.pages?.currentPage)
    }
    
    func testSelectBookSetsSelectedBookFromData() async {
        let dummyNSObject = NSObject()
        let dummyShelf = Shelf(id: "", name: "", book_count: 0)
        let dummyBookArray = [Book(), Book(), Book(), Book()]
        let dummyPages = Pages()

        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        given(await goodreadsMock.getBooksFromShelf(sender: any(), shelf: any(), page: any())).willReturn((dummyBookArray, dummyPages))

        let userDefaultsMock = mock(UserDefaultsServiceProtocol.self)

        let viewModel = BookSelectionViewModel(goodreadsService: goodreadsMock, defaultsService: userDefaultsMock)
        viewModel.shelf = dummyShelf
        await viewModel.loadBooksFromShelf(sender: dummyNSObject)
        viewModel.selectBook(selected: 1)

        verify(userDefaultsMock.storeBook(book: any())).wasCalled()
    }
}
