//
//  QuoteListView.swift
//  harveyspecterquotes
//
//  Created by Trung Nguyen on 14/12/25.
//

import SwiftUI

struct QuoteListView: View {
    @StateObject private var quoteService = QuoteService()
    @State private var isRefreshing = false
    @State private var appearedCards: Set<Int> = []

    func refreshQuotes() async {
        // Add a small delay for the refresh animation
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Reload quotes
        await MainActor.run {
            quoteService.loadQuotes()

            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }

    @ViewBuilder
    private func quoteCard(quote: String, index: Int) -> some View {
        let hasAppeared = appearedCards.contains(index)

        NavigationLink(destination: QuoteDetailView(quote: quote)) {
            QuoteCardView(quote: quote, index: index, hasAppeared: hasAppeared)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.1).delay(Double(index) * 0.05)) {
                _ = appearedCards.insert(index)
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.navyBlue.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(quoteService.quotes.enumerated()), id: \.offset) { index, quote in
                            quoteCard(quote: quote, index: index)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
                .refreshable {
                    await refreshQuotes()
                }
            }
            .navigationTitle("Harvey Specter")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.navyBlue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(.dark)
    }
}

struct QuoteCardView: View {
    let quote: String
    let index: Int
    let hasAppeared: Bool
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 0) {
            // Gold accent bar
            Rectangle()
                .fill(Color.gold)
                .frame(width: 3)

            // Card content
            VStack(alignment: .leading, spacing: 12) {
                Text(quote)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.pearlWhite)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                HStack {
                    Text("— Harvey Specter")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(.pearlWhite.opacity(0.7))
                        .italic()

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gold.opacity(0.6))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    LinearGradient.quoteCardGradient

                    // Subtle overlay for depth
                    Color.white.opacity(0.02)
                }
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.5, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    QuoteListView()
}
