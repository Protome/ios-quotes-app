//
//  BookSelectionShelfListViewModelTests.swift
//  GoodQuotesTests
//
//  Created by Kieran on 12/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import XCTest
import Mockingbird
@testable import GoodQuotes

class BookSelectionShelfListViewModelTests: XCTestCase {
    
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
        
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        given(await goodreadsMock.loadShelves(sender: dummyNSObject)).willReturn([Shelf]())
        
        let viewModel = BookSelectionShelfListViewModel(goodreadsService: goodreadsMock)
        await viewModel.loadBooksFromShelf(sender: dummyNSObject)
        
        verify(await goodreadsMock.loginToGoodreads(sender: dummyNSObject)).wasCalled()
        verify(await goodreadsMock.loadShelves(sender: dummyNSObject)).wasCalled()
        XCTAssertEqual(0, viewModel.shelves.count)
    }
    
    func testLoadBooksFromShelvesIsEmpty_WhenServiceReturnsNoData() async {
        let dummyNSObject = NSObject()
        
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        given(await goodreadsMock.loadShelves(sender: dummyNSObject)).willReturn([Shelf]())
        
        let viewModel = BookSelectionShelfListViewModel(goodreadsService: goodreadsMock)
        await viewModel.loadBooksFromShelf(sender: dummyNSObject)
        
        verify(await goodreadsMock.loginToGoodreads(sender: dummyNSObject)).wasCalled()
        verify(await goodreadsMock.loadShelves(sender: dummyNSObject)).wasCalled()
        XCTAssertEqual(0, viewModel.shelves.count)
    }
    
    func testLoadBooksFromShelvesPopulatesShelves_WhenServiceReturnsData() async {
        let dummyNSObject = NSObject()
        let dummyShelf1 = Shelf(id: "shelf1", name: "Shelf1", book_count: 0)
        let dummyShelf2 = Shelf(id: "shelf2", name: "Shelf2", book_count: 0)
        let dummyShelf3 = Shelf(id: "shelf3", name: "Shelf3", book_count: 0)
        
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        given(await goodreadsMock.loadShelves(sender: dummyNSObject)).willReturn([dummyShelf1, dummyShelf2, dummyShelf3])
        
        let viewModel = BookSelectionShelfListViewModel(goodreadsService: goodreadsMock)
        await viewModel.loadBooksFromShelf(sender: dummyNSObject)
        
        verify(await goodreadsMock.loginToGoodreads(sender: dummyNSObject)).wasCalled()
        verify(await goodreadsMock.loadShelves(sender: dummyNSObject)).wasCalled()
        XCTAssertEqual(3, viewModel.shelves.count)
    }
    
    func testSelectShelfSetsSelectedShelfFromData() async {
        let dummyNSObject = NSObject()
        let dummyShelf1 = Shelf(id: "shelf1", name: "Shelf1", book_count: 0)
        let dummyShelf2 = Shelf(id: "shelf2", name: "Shelf2", book_count: 0)
        let dummyShelf3 = Shelf(id: "shelf3", name: "Shelf3", book_count: 0)
        let dummyShelfArray = [dummyShelf1, dummyShelf2, dummyShelf3]
        
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        given(await goodreadsMock.loadShelves(sender: dummyNSObject)).willReturn(dummyShelfArray)
        
        let viewModel = BookSelectionShelfListViewModel(goodreadsService: goodreadsMock)
        await viewModel.loadBooksFromShelf(sender: dummyNSObject)
        let selectedIndex = 1
        viewModel.selectShelf(selected: selectedIndex)
        
        XCTAssertEqual(dummyShelfArray[1].id, viewModel.selectedShelf?.id ?? "")
    }
}
