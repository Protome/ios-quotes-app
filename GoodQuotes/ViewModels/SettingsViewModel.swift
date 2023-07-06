//
//  SettingsViewModel.swift
//  GoodQuotes
//
//  Created by Kieran on 12/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import Foundation

class SettingsViewModel: ObservableObject {
    private var userDefaultsService: UserDefaultsServiceProtocol
    private var goodreadsService: GoodreadsServiceProtocol
    
    @Published var loggedIntoGoodreads = false
    @Published var goodreadsShelfTitle = Settings.GoodreadsShelf.rawValue
    @Published var currentShelf = ""
    @Published var signIntoGoodreadsTitle = ""
    
    let goodreadsTitles = (signIn: "Sign In to Goodreads", signOut: "Sign Out of Goodreads")
    let defaultShelf = "to-read"
    
    let sectionTitles = [0 : "Settings",
                          1 : "Goodreads",
                          2 : "Other"]
    
    let sections: [Int : [Settings]] = [0 : [.GoodreadsShelf, .ChangeBackground],
                     1 : [.SignInOutGoodreads, .VisitGoodreads],
                     2 : [.About, .Feedback]]
    
    let segueForSection: [Settings : String] = [.GoodreadsShelf : "ShowShelves",
                                                .About : "ShowAcknowledgements",
                                                .Feedback : "ShowFeedback",
                                                .ChangeBackground : "ChangeBackground" ]
    
    
    var changesMade = false
    
    init(userDefaultsService: UserDefaultsServiceProtocol, goodreadsService: GoodreadsServiceProtocol, currentShelf: String = "", changesMade: Bool = false) {
        self.userDefaultsService = userDefaultsService
        self.goodreadsService = goodreadsService
        self.currentShelf = currentShelf
        self.changesMade = changesMade
        
        self.goodreadsService.isLoggedInPublisher
            .map({ $0 == .LoggedIn})
            .assign(to: &$loggedIntoGoodreads)
        
        self.goodreadsService.isLoggedInPublisher
            .map({ [weak self] loggedIn in (loggedIn == .LoggedIn ? self?.goodreadsTitles.signOut : self?.goodreadsTitles.signIn) ?? "" })
            .assign(to: &$signIntoGoodreadsTitle)
    }
    
    func setCurrentShelf() {
        currentShelf = userDefaultsService.loadDefaultShelf() ?? defaultShelf
        goodreadsShelfTitle = currentShelf.isEmpty ? Settings.GoodreadsShelf.rawValue : "\(Settings.GoodreadsShelf.rawValue): \(currentShelf)"
    }
    
    func titleForRow(indexPath: IndexPath) -> String
    {
        guard sections.count > indexPath.section else {
            return ""
        }
        
        let item = sections[indexPath.section]![indexPath.row]
        
        switch item {
        case .GoodreadsShelf:
            return  currentShelf.isEmpty ? item.rawValue : "\(item.rawValue): \(currentShelf)"
        case .SignInOutGoodreads:
            return loggedIntoGoodreads ? goodreadsTitles.signOut : goodreadsTitles.signIn
        default:
            return item.rawValue
        }
    }
    
    func logoutOfGoodreads() {
        goodreadsService.logoutOfGoodreadsAccount()
    }
    
    func loginToGoodreads(sender: NSObject) async -> Void {
        await goodreadsService.loginToGoodreads(sender: sender)
    }
    
    func shelfSelected(shelfName: String) {
        currentShelf = shelfName
        userDefaultsService.storeDefaultShelf(shelfName: currentShelf)
    }
}
