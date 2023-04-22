//
//  MainView.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 22/04/2023.
//  Copyright © 2023 Protome. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    
    var body: some View {
        VStack() {
            quoteView
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Rectangle().fill(.blue.gradient))
    }
    
    var quoteView: some View {
        VStack() {
            Text(viewModel.currentQuote?.quote ?? "")
                .foregroundColor(Color("MainText"))
                .font(.custom("Avenir Next", size: 16))
                .fontWeight(.medium)
                .minimumScaleFactor(0.7)
                .padding(.top, 16)
                .padding(.horizontal, 8)
            Divider()
                .background(Color("MainText"))
                .padding(.horizontal, 140)
                .frame(height: 2)
            Text(viewModel.currentQuote?.publication ?? "")
                .foregroundColor(Color("MainText"))
                .font(.custom("Avenir Next", size: 13))
                .padding(.horizontal, 8)
            Text(viewModel.currentQuote?.author ?? "")
                .foregroundColor(Color("MainText"))
                .font(.custom("Avenir Next", size: 13))
                .padding(.top, 0)
                .padding(.bottom, 8)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .cornerRadius(10)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let quoteService = QuoteService()
        let reviewService = ReviewRequestService()
        let goodreadsService = GoodreadsService()
        let openLibraryService = OpenLibraryService()
        
        let viewModel = MainViewModel(quoteService: quoteService,
                                      reviewService: reviewService,
                                      goodreadsService: goodreadsService,
                                      openLibraryservice: openLibraryService)
        
        
        MainView(viewModel: viewModel)
            .onAppear() {
                viewModel.currentQuote = Quote(quote: "This is a test Quote", author: "Kieran Bamford", publication: "The Book of Kieran")
        }
        
    }
}
