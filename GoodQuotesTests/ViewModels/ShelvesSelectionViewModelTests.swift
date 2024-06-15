//
//  ShelvesSelectionViewModelTests.swift
//  GoodQuotesTests
//
//  Created by Kieran on 12/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import XCTest
import Mockingbird
@testable import GoodQuotes

class ShelvesSelectionViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadShelvesCallsServices() async {
        let dummyNSObject = NSObject()
        
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        given(await goodreadsMock.loadShelves(sender: dummyNSObject)).willReturn([Shelf]())
        
        let userDefaultsMock = mock(UserDefaultsServiceProtocol.self)
        given(userDefaultsMock.loadDefaultShelf()).willReturn("")
        
        
        let viewModel = ShelvesSelectionViewModel(userDefaultsService: userDefaultsMock, goodreadsService: goodreadsMock)
        await viewModel.loadShelves(sender: dummyNSObject)
        
        verify(await goodreadsMock.loadShelves(sender: dummyNSObject)).wasCalled()
        verify(userDefaultsMock.loadDefaultShelf()).wasCalled()
        XCTAssertEqual(0, viewModel.shelves.count)
    }
    
    func testLoadShelvesPopulatesShelvesArray_WhenGoodreadsReturnsShelves() async {
        let dummyNSObject = NSObject()
        let dummyShelf = Shelf(id: "Test", name: "test", book_count: 1)
        
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        given(await goodreadsMock.loadShelves(sender: dummyNSObject)).willReturn([dummyShelf])
        
        let userDefaultsMock = mock(UserDefaultsServiceProtocol.self)
        given(userDefaultsMock.loadDefaultShelf()).willReturn("")
        
        let viewModel = ShelvesSelectionViewModel(userDefaultsService: userDefaultsMock, goodreadsService: goodreadsMock)
        await viewModel.loadShelves(sender: dummyNSObject)
        
        XCTAssertEqual(1, viewModel.shelves.count)
    }
    
    func testLoadShelvesPopulatesSavedShelf_WhenUserDefaultsReturnsOne() async {
        let dummyNSObject = NSObject()
        let dummyShelf = Shelf(id: "Test", name: "test", book_count: 1)
        
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        given(await goodreadsMock.loadShelves(sender: dummyNSObject)).willReturn([dummyShelf])
        
        let userDefaultsMock = mock(UserDefaultsServiceProtocol.self)
        given(userDefaultsMock.loadDefaultShelf()).willReturn(dummyShelf.name)
        
        let viewModel = ShelvesSelectionViewModel(userDefaultsService: userDefaultsMock, goodreadsService: goodreadsMock)
        await viewModel.loadShelves(sender: dummyNSObject)
        
        XCTAssertEqual(dummyShelf.name, viewModel.currentShelf)
    }
    
    func testSelectShelf_SetsCurrentShelfToNameOfSelectedOne() async {
        let dummyNSObject = NSObject()
        let dummyShelf = Shelf(id: "Test", name: "test", book_count: 1)
        let dummyShelf2 = Shelf(id: "newone", name: "this-one-is-the-new-one", book_count: 5)
        
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        given(await goodreadsMock.loadShelves(sender: dummyNSObject)).willReturn([dummyShelf, dummyShelf2])
        
        let userDefaultsMock = mock(UserDefaultsServiceProtocol.self)
        given(userDefaultsMock.loadDefaultShelf()).willReturn(dummyShelf.name)
        
        let viewModel = ShelvesSelectionViewModel(userDefaultsService: userDefaultsMock, goodreadsService: goodreadsMock)
        await viewModel.loadShelves(sender: dummyNSObject)
        
        XCTAssertEqual(dummyShelf.name, viewModel.currentShelf)
        
        viewModel.selectShelf(selected: 1)
        
        XCTAssertNotEqual(dummyShelf.name, viewModel.currentShelf)
        XCTAssertEqual(dummyShelf2.name, viewModel.currentShelf)
    }
}
