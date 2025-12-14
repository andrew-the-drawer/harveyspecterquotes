//
//  QuoteListView.swift
//  harveyspectorquotes
//
//  Created by Trung Nguyen on 14/12/25.
//

import SwiftUI

struct QuoteListView: View {
    @StateObject private var quoteService = QuoteService()

    var body: some View {
        NavigationView {
            List {
                ForEach(Array(quoteService.quotes.enumerated()), id: \.offset) { index, quote in
                    NavigationLink(destination: QuoteDetailView(quote: quote)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(quote)
                                .font(.body)
                                .lineLimit(2)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Harvey Specter Quotes")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    QuoteListView()
}
