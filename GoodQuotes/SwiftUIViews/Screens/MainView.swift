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
    @State private var renderedImage = Image(systemName: "photo")
    @State private var showingSheet = false
    @Environment(\.displayScale) var displayScale
    
    var body: some View {
        NavigationStack {
            VStack() {
                quoteView
                    .padding(.horizontal, 26)
                    .padding(.top, 22)
                    .animation(.easeOut(duration: 0.3), value: viewModel.currentQuote)
                    .onAppear { render() }
                    .onChange(of: viewModel.currentQuote) {_ in
                        render()
                    }
                if viewModel.currentBook != nil {
                    bookView
                        .padding(.horizontal, 26)
                        .padding([.top, .bottom], 22)
                        .animation(.easeInOut, value: viewModel.currentBook)
                }
                Spacer()
                buttons
                    .padding(.horizontal, 16)
                    .padding(.bottom)
                
            }
            .colorScheme(.light)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button() {
                        showingSheet = true
                    } label: {
                        Image(systemName: "gear").foregroundColor(.black)
                    }
                    .sheet(isPresented: $showingSheet) {
                        SettingsView(viewModel: SettingsViewModel(userDefaultsService: UserDefaultsService(), goodreadsService: GoodreadsService()))
                    }
                }
            }
        }
    }
    
    var background: some View {
        Rectangle().fill(LinearGradient(gradient: Gradient(colors: GradientsService.Blue), startPoint: .bottomLeading, endPoint: .topTrailing))
    }
    
    var quoteView: some View {
        VStack() {
            Text(viewModel.currentQuote.quote)
                .font(.custom("Avenir Next", size: 16))
                .fontWeight(.medium)
                .minimumScaleFactor(0.7)
                .padding([.top, .horizontal], 14)
            Divider()
                .background(Color("MainText"))
                .padding(.horizontal, 140)
                .frame(height: 2)
            Text(viewModel.currentQuote.publication)
                .font(.custom("Avenir Next", size: 13))
                .padding(.horizontal, 14)
            Text(viewModel.currentQuote.author)
                .font(.custom("Avenir Next", size: 13))
                .padding(.top, 0)
                .padding([.bottom, .horizontal], 14)
        }
        .frame(maxWidth: .infinity)
        .background(.thinMaterial
            .opacity(0.75))
        .foregroundColor(Color("MainText"))
        .multilineTextAlignment(.center)
        .cornerRadius(10)
    }
    
    var bookView: some View {
        HStack() {
            AsyncImage(url: URL(string: viewModel.currentBook?.imageUrl ?? ""))
            { image in
                image.resizable()
            } placeholder: {
                
            }
            .frame(width: 60, height: 90)
            .cornerRadius(4)
            .padding(.all, 16)
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.currentBook?.title ?? "")
                    .foregroundColor(Color("MainText"))
                    .font(.custom("Avenir Next", size: 15))
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(viewModel.currentBook?.author.name ?? "")
                    .foregroundColor(Color("MainText"))
                    .font(.custom("Avenir Next", size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(viewModel.publicationDate)
                    .foregroundColor(Color("MainText"))
                    .font(.custom("Avenir Next", size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 6)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .animation(.easeInOut, value: viewModel.currentBook)
        }
        .frame(maxWidth: .infinity)
        .background(.thinMaterial
            .opacity(0.75))
        .cornerRadius(10)
    }
    
    var buttons: some View {
        HStack() {
            Spacer()
            if viewModel.loggedIn {
                Button() {
                    //                    viewModel.addCurrentBookToShelf(sender: self)
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color.black)
                        .frame(width: 42, height: 42)
                        .background(.thinMaterial)
                        .cornerRadius(21)
                }
            }
            else {
                Spacer()
                    .frame(width: 42)
            }
            Button() {
                Task {
                    await viewModel.loadRandomQuote()
                }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .resizable()
                    .scaledToFit()
                    .padding(.all, 16)
                    .frame(width: 62, height: 62)
                    .foregroundColor(Color.black)
                    .background(.thinMaterial
                        .opacity(0.75))
                    .cornerRadius(31)
            }
            
            ShareLink(item: renderedImage, preview: SharePreview(viewModel.currentBook?.title ?? "Quotey quote", image: renderedImage)) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(Color.black)
                    .frame(width: 42, height: 42)
                    .background(.thinMaterial
                        .opacity(0.75))
                    .cornerRadius(21)
            }
            
            Spacer()
        }
    }
    
    @MainActor func render() {
        let renderer = ImageRenderer(content: quoteView
            .frame(width: 360)
            .background(background))
        renderer.scale = displayScale
        
        if let uiImage = renderer.uiImage {
            renderedImage = Image(uiImage: uiImage)
        }
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
                viewModel.currentQuote = Quote(quote: "This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote This is a test Quote ", author: "Kieran Bamford", publication: "The Book of Kieran")
                var book = Book()
                book.title = "The Book of Kieran"
                book.author.name = "Kieran Bamford"
                book.publicationYear = 1991
                book.imageUrl = "https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1537977912i/40523931.jpg"
                
                viewModel.currentBook = book
                
            }
        
    }
}
