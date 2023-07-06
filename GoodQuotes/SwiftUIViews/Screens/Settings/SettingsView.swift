//
//  SettingsView.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 24/04/2023.
//  Copyright © 2023 Protome. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section() {
                    if viewModel.loggedIntoGoodreads {
                        SettingCell(title: viewModel.goodreadsShelfTitle, destination: ShelvesView())
                    }
                    SettingCell(title: Settings.ChangeBackground.rawValue, destination: BackgroundView())
                } header: {
                    SettingsHeader(title: viewModel.sectionTitles[0] ?? "")
                }
                
                Section() {
                    SettingCell(title: viewModel.signIntoGoodreadsTitle, destination: ShelvesView())
                    SettingCell(title: Settings.VisitGoodreads.rawValue, destination: ShelvesView())
                } header: {
                    SettingsHeader(title: viewModel.sectionTitles[1] ?? "")
                }
                
                Section() {
                    SettingCell(title: Settings.About.rawValue, destination: AboutView())
                    SettingCell(title: Settings.Feedback.rawValue, destination: FeedbackView())
                } header: {
                    SettingsHeader(title: viewModel.sectionTitles[2] ?? "")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsHeader: View {
    var title: String
    
    var body: some View {
        Text(title)
            .textCase(.none)
            .font(.custom("Avenir Next", size: 15))
            .fontWeight(.medium)
    }
}

struct SettingCell<T: View>: View {
    var title: String
    var destination: T
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            Text(title)
                .foregroundColor(Color("Text"))
                .font(.custom("Avenir Next", size: 16))
                .fontWeight(.medium)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let userDefaultsService = UserDefaultsService()
        let goodreadsService = GoodreadsService()
        
        let dummyViewModel = SettingsViewModel(userDefaultsService: userDefaultsService, goodreadsService: goodreadsService)
        
        SettingsView(viewModel: dummyViewModel)
    }
}
