//
//  ColorSystem.swift
//  harveyspectorquotes
//
//  Design System Colors - Harvey Specter Aesthetic
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors
    static let navyBlue = Color(hex: "1A1F3A")      // Harvey's Suit - Primary background
    static let charcoal = Color(hex: "2D3142")      // Secondary backgrounds
    static let pearlWhite = Color(hex: "F8F9FA")    // Primary text on dark
    static let cream = Color(hex: "FEFEFE")         // Background for light mode

    // MARK: - Accent Colors
    static let gold = Color(hex: "D4AF37")          // Power & Success - CTAs, highlights
    static let deepRed = Color(hex: "8B0000")       // Confidence - Secondary accents
    static let silver = Color(hex: "C0C0C0")        // Borders, subtle details

    // MARK: - Helper: Hex to Color
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Presets
extension LinearGradient {
    static let quoteCardGradient = LinearGradient(
        gradient: Gradient(colors: [Color.navyBlue, Color.charcoal]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let widgetPremiumGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.navyBlue,
            Color.charcoal,
            Color.deepRed.opacity(0.3)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
