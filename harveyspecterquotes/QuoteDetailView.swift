//
//  QuoteDetailView.swift
//  harveyspecterquotes
//
//  Created by Trung Nguyen on 14/12/25.
//

import SwiftUI

struct QuoteDetailView: View {
    let quote: String
    @State private var showCopiedAlert = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.navyBlue, Color.charcoal.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 40)

                    // Decorative opening quote mark
                    Text("\"")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.gold.opacity(0.4))
                        .offset(y: 20)

                    // Main quote text
                    Text(quote)
                        .font(.system(size: 28, weight: .semibold, design: .serif))
                        .foregroundColor(.pearlWhite)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .padding(.horizontal, 32)

                    // Decorative closing quote mark
                    Text("\"")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.gold.opacity(0.4))
                        .offset(y: -20)

                    // Attribution
                    VStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.gold)
                            .frame(width: 60, height: 2)

                        Text("— Harvey Specter")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(.pearlWhite.opacity(0.8))
                            .italic()
                            .tracking(1)
                    }
                    .padding(.top, 8)

                    Spacer()
                        .frame(height: 32)

                    // Action buttons
                    VStack(spacing: 16) {
                        // Share button
                        ShareLink(item: "\"\(quote)\" - Harvey Specter") {
                            HStack(spacing: 12) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Share Quote")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.navyBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.gold)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Copy button
                        Button(action: {
                            UIPasteboard.general.string = "\"\(quote)\" - Harvey Specter"
                            showCopiedAlert = true

                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Copy to Clipboard")
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .foregroundColor(.pearlWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.charcoal)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gold.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .navigationTitle("Quote")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.navyBlue.opacity(0.95), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .overlay(
            // Copied alert
            VStack {
                if showCopiedAlert {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.gold)
                        Text("Copied to clipboard")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.pearlWhite)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.charcoal)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: Color.black.opacity(0.3), radius: 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showCopiedAlert = false
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 60)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showCopiedAlert)
        )
    }
}

#Preview {
    NavigationView {
        QuoteDetailView(quote: "Ever loved someone so much, you would do anything for them? Yeah, well make that someone yourself and do whatever the hell you want")
    }
}
