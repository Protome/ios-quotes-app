//
//  FeedbackView.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 24/04/2023.
//  Copyright © 2023 Protome. All rights reserved.
//

import SwiftUI

struct FeedbackView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Got some changes you want to suggest or improvements you'd like to see in the app? \nSee something broken? \nJust want to say hi?")
                    .padding()
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("Text"))
                    .font(.custom("Avenir Next", size: 16))
                
                Button("Send us a message!") {
                    
                }
                .padding()
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding()
            .navigationTitle("About")
        }
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
