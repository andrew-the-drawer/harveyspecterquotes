//
//  QuoteService.swift
//  harveyspectorquotes
//
//  Created by Trung Nguyen on 14/12/25.
//

import Foundation
import Combine

class QuoteService: ObservableObject {
    @Published var quotes: [String] = []

    init() {
        loadQuotes()
    }

    func loadQuotes() {
        guard let url = Bundle.main.url(forResource: "quotes", withExtension: "json") else {
            print("Failed to locate quotes.json in bundle.")
            return
        }

        guard let data = try? Data(contentsOf: url) else {
            print("Failed to load quotes.json from bundle.")
            return
        }

        guard let loadedQuotes = try? JSONDecoder().decode([String].self, from: data) else {
            print("Failed to decode quotes.json.")
            return
        }

        self.quotes = loadedQuotes
    }

    func randomQuote() -> String {
        quotes.randomElement() ?? "No quotes available"
    }
}
