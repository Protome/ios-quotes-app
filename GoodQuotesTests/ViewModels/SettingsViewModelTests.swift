//
//  SettingsViewModelTests.swift
//  GoodQuotesTests
//
//  Created by Kieran on 12/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//


import XCTest
import Mockingbird
@testable import GoodQuotes

class SettingsViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetCurrentShelfSetsToDefault_WhenUserDefaultsReturnsNil() async {
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        
        let userDefaultsMock = mock(UserDefaultsServiceProtocol.self)
        given(userDefaultsMock.loadDefaultShelf()).willReturn(nil)
        
        let viewModel = SettingsViewModel(userDefaultsService: userDefaultsMock, goodreadsService: goodreadsMock)
        viewModel.setCurrentShelf()
        
        verify(userDefaultsMock.loadDefaultShelf()).wasCalled()
        XCTAssertEqual(viewModel.defaultShelf, viewModel.currentShelf)
    }
    
    func testSetCurrentShelfSetsToStoredShelf_WhenUserDefaultsReturnsStoredValue() async {
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        
        let expectedShelfName = "I-Am-The-Shelf"
        
        let userDefaultsMock = mock(UserDefaultsServiceProtocol.self)
        given(userDefaultsMock.loadDefaultShelf()).willReturn(expectedShelfName)
        
        let viewModel = SettingsViewModel(userDefaultsService: userDefaultsMock, goodreadsService: goodreadsMock)
        viewModel.setCurrentShelf()
        
        verify(userDefaultsMock.loadDefaultShelf()).wasCalled()
        XCTAssertEqual(expectedShelfName, viewModel.currentShelf)
    }
    
    func testTitleForRowReturnsCurrentShelf_WhenGoodreadsShelfSelected_AndCurrentShelfHasValue() {
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        let userDefaultsMock = mock(UserDefaultsServiceProtocol.self)
        let viewModel = SettingsViewModel(userDefaultsService: userDefaultsMock, goodreadsService: goodreadsMock)
        
        let expectedShelfName = "I-Am-The-Shelf"
        given(userDefaultsMock.loadDefaultShelf()).willReturn(expectedShelfName)
        viewModel.setCurrentShelf()
        
        //The map for these is in the ViewModel under "Sections"
        let goodreadsShelfIndex = IndexPath(row: 0, section: 0)
        let result = viewModel.titleForRow(indexPath: goodreadsShelfIndex)
        
        let containsShelfName = result.contains(expectedShelfName)
        XCTAssertTrue(containsShelfName)
    }
    
    func testTitleForRowReturnsCorrectValuesForLoginAndLogout_BasedOnGoodreadsServiceValue() {
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        let userDefaultsMock = mock(UserDefaultsServiceProtocol.self)
        let viewModel = SettingsViewModel(userDefaultsService: userDefaultsMock, goodreadsService: goodreadsMock)
        
        given(goodreadsMock.isLoggedIn).willReturn(.LoggedOut)
        
        //The map for these is in the ViewModel under "Sections"
        let goodreadsLoginIndex = IndexPath(row: 0, section: 1)
        let loggedOutResult = viewModel.titleForRow(indexPath: goodreadsLoginIndex)
        
        XCTAssertEqual(loggedOutResult, viewModel.goodreadsTitles.signIn)
        
        given(goodreadsMock.isLoggedIn).willReturn(.LoggedIn)
        let loggedInResult = viewModel.titleForRow(indexPath: goodreadsLoginIndex)
        
        XCTAssertEqual(loggedInResult, viewModel.goodreadsTitles.signOut)
    }
    
    func testLogoutOfGoodreadsCallsGoodreadsService() {
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        let userDefaultsMock = mock(UserDefaultsServiceProtocol.self)
        let viewModel = SettingsViewModel(userDefaultsService: userDefaultsMock, goodreadsService: goodreadsMock)
        
        viewModel.logoutOfGoodreads()
        
        verify(goodreadsMock.logoutOfGoodreadsAccount()).wasCalled()
    }
    
    func testLoginToGoodreadsCallsGoodreadsService() async {
        let dummyNSObject = NSObject()
        
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        let userDefaultsMock = mock(UserDefaultsServiceProtocol.self)
        let viewModel = SettingsViewModel(userDefaultsService: userDefaultsMock, goodreadsService: goodreadsMock)
        
        await viewModel.loginToGoodreads(sender: dummyNSObject)
        
        verify(await goodreadsMock.loginToGoodreads(sender: dummyNSObject)).wasCalled()
    }
    
    func testSetCurrentShelfUpdatesShelfName() {
        let dummyShelfName = "DummyShelf"
        
        let goodreadsMock = mock(GoodreadsServiceProtocol.self)
        let userDefaultsMock = mock(UserDefaultsServiceProtocol.self)
        let viewModel = SettingsViewModel(userDefaultsService: userDefaultsMock, goodreadsService: goodreadsMock)
        
        viewModel.shelfSelected(shelfName: dummyShelfName)
        
        verify(userDefaultsMock.storeDefaultShelf(shelfName: dummyShelfName)).wasCalled()
    }
}
