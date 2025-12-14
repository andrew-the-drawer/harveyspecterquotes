//
//  QuoteDetailView.swift
//  harveyspectorquotes
//
//  Created by Trung Nguyen on 14/12/25.
//

import SwiftUI

struct QuoteDetailView: View {
    let quote: String

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.top, 40)

                Text(quote)
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)

                Text("- Harvey Specter")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .italic()

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Quote")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        QuoteDetailView(quote: "I don't have dreams, I have goals.")
    }
}
