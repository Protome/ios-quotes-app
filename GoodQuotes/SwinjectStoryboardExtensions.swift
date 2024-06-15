//
//  SwinjectStoryboardExtensions.swift
//  GoodQuotes
//
//  Created by Kieran on 13/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import Foundation
import SwinjectStoryboard
import Swinject

extension SwinjectStoryboard {
    @objc class func setup() {
        setupServices()
        setupViewModels()
        setupViewControllers()
    }
    
    @objc class func setupServices() {
        defaultContainer.register(QuoteServiceProtocol.self) { resolver in return QuoteScraperService() }
        defaultContainer.register(UserDefaultsServiceProtocol.self) { resolver in return UserDefaultsService() }
        defaultContainer.register(GoodreadsServiceProtocol.self) { resolver in return GoodreadsService() }
        defaultContainer.register(AuthStorageServiceProtocol.self) { resolver in return AuthStorageService() }
        defaultContainer.register(ReviewRequestServiceProtocol.self) { resolver in return ReviewRequestService() }
        defaultContainer.register(OpenLibraryServiceProtocol.self) { resolver in return OpenLibraryService() }
    }
    
    @objc class func setupViewModels() {
        defaultContainer.register(MainViewModel.self) { resolver in
            return MainViewModel(quoteService: resolver.resolve(QuoteServiceProtocol.self)!, reviewService: resolver.resolve(ReviewRequestServiceProtocol.self)!, goodreadsService: resolver.resolve(GoodreadsServiceProtocol.self)!, openLibraryservice: resolver.resolve(OpenLibraryServiceProtocol.self)!)
        }
        defaultContainer.register(BookSelectionViewModel.self) { resolver in
            return BookSelectionViewModel(goodreadsService: resolver.resolve(GoodreadsServiceProtocol.self)!, defaultsService: resolver.resolve(UserDefaultsServiceProtocol.self)!)
        }
        defaultContainer.register(BookSelectionShelfListViewModel.self) { resolver in
            return BookSelectionShelfListViewModel(goodreadsService: resolver.resolve(GoodreadsServiceProtocol.self)!)
        }
        defaultContainer.register(ShelvesSelectionViewModel.self) { resolver in
            return ShelvesSelectionViewModel(userDefaultsService: resolver.resolve(UserDefaultsServiceProtocol.self)!, goodreadsService: resolver.resolve(GoodreadsServiceProtocol.self)!)
        }
        defaultContainer.register(SettingsViewModel.self) { resolver in
            return SettingsViewModel(userDefaultsService: resolver.resolve(UserDefaultsServiceProtocol.self)!, goodreadsService: resolver.resolve(GoodreadsServiceProtocol.self)!)
        }
        defaultContainer.register(FeedbackViewModel.self) { resolver in
            return FeedbackViewModel()
        }
        defaultContainer.register(MainViewModel.self) { resolver in
            return MainViewModel(quoteService: resolver.resolve(QuoteServiceProtocol.self)!, reviewService: resolver.resolve(ReviewRequestServiceProtocol.self)!, goodreadsService: resolver.resolve(GoodreadsServiceProtocol.self)!, openLibraryservice: resolver.resolve(OpenLibraryServiceProtocol.self)!)
        }
    }
    
    @objc class func setupViewControllers() {
        defaultContainer.storyboardInitCompleted(MainViewController.self) {resolver, controller in
            controller.viewModel = resolver.resolve(MainViewModel.self)!
        }
        defaultContainer.storyboardInitCompleted(BookSelectionViewController.self) {resolver, controller in
            controller.viewModel = resolver.resolve(BookSelectionViewModel.self)!
        }
        defaultContainer.storyboardInitCompleted(BookSelectionShelfListViewController.self) {resolver, controller in
            controller.viewModel = resolver.resolve(BookSelectionShelfListViewModel.self)!
        }
        defaultContainer.storyboardInitCompleted(ShelvesSelectionViewController.self) {resolver, controller in
            controller.viewModel = resolver.resolve(ShelvesSelectionViewModel.self)!
        }
        defaultContainer.storyboardInitCompleted(SettingsViewController.self) {resolver, controller in
            controller.viewModel = resolver.resolve(SettingsViewModel.self)!
        }
        defaultContainer.storyboardInitCompleted(FeedbackViewController.self) {resolver, controller in
            controller.viewModel = resolver.resolve(FeedbackViewModel.self)!
        }
    }
}
