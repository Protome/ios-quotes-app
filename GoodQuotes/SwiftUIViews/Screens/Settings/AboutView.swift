//
//  AboutView.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 24/04/2023.
//  Copyright © 2023 Protome. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("App created by Kieran Bamford. I'm @Protome on Twitter, feel free to send me feedback! \n\nGoodreads functionality all uses the official Goodreads API\n\nApp Logo was created by Amy Gallagher, go check her stuff out at http://www.amiluu.com")
                    .padding()
                    .foregroundColor(Color("Text"))
                    .font(.custom("Avenir Next", size: 16))
                Spacer()
            }
            .padding()
            .navigationTitle("About")
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
