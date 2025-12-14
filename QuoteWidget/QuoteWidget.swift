//
//  QuoteWidget.swift
//  QuoteWidget
//
//  Created by Trung Nguyen on 14/12/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: Date(), quote: "I don't have dreams, I have goals.", configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> QuoteEntry {
        QuoteEntry(date: Date(), quote: loadRandomQuote(), configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<QuoteEntry> {
        var entries: [QuoteEntry] = []

        // Generate a timeline with new quotes each day at midnight
        let currentDate = Date()
        let calendar = Calendar.current

        // Create entry for today
        if let startOfDay = calendar.startOfDay(for: currentDate) as Date? {
            let entry = QuoteEntry(date: startOfDay, quote: loadRandomQuote(), configuration: configuration)
            entries.append(entry)
        }

        // Create entries for the next 7 days
        for dayOffset in 1...7 {
            if let entryDate = calendar.date(byAdding: .day, value: dayOffset, to: currentDate),
               let startOfDay = calendar.startOfDay(for: entryDate) as Date? {
                let entry = QuoteEntry(date: startOfDay, quote: loadRandomQuote(), configuration: configuration)
                entries.append(entry)
            }
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    private func loadRandomQuote() -> String {
        guard let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let quotes = try? JSONDecoder().decode([String].self, from: data) else {
            return "Work until you no longer have to introduce yourself."
        }
        return quotes.randomElement() ?? "I don't have dreams, I have goals."
    }
}

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: String
    let configuration: ConfigurationAppIntent
}

struct QuoteWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: widgetFamily == .systemSmall ? 8 : 12) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: widgetFamily == .systemSmall ? 20 : 24))
                    .foregroundColor(.white.opacity(0.9))

                ScrollingText(text: entry.quote, fontSize: widgetFamily == .systemSmall ? 11 : 13)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)

                Text("- Harvey Specter")
                    .font(.system(size: widgetFamily == .systemSmall ? 8 : 10))
                    .foregroundColor(.white.opacity(0.8))
                    .italic()
            }
            .padding(widgetFamily == .systemSmall ? 12 : 16)
        }
    }
}

// Scrolling text view with animation for long quotes
struct ScrollingText: View {
    let text: String
    let fontSize: CGFloat
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            Text(text)
                .font(.system(size: fontSize, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: geometry.size.width)
                .offset(y: offset)
                .onAppear {
                    // Calculate if text needs scrolling
                    let textHeight = text.heightWithConstrainedWidth(width: geometry.size.width, font: .systemFont(ofSize: fontSize, weight: .medium))
                    if textHeight > geometry.size.height {
                        // Animate scrolling for long text
                        withAnimation(Animation.linear(duration: Double(text.count) * 0.1).repeatForever(autoreverses: true)) {
                            offset = -(textHeight - geometry.size.height)
                        }
                    }
                }
        }
    }
}

// Helper extension to calculate text height
extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}

struct QuoteWidget: Widget {
    let kind: String = "QuoteWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            QuoteWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Harvey Specter Quote")
        .description("Get a daily dose of wisdom from Harvey Specter.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    QuoteWidget()
} timeline: {
    QuoteEntry(date: .now, quote: "I don't have dreams, I have goals.", configuration: ConfigurationAppIntent())
    QuoteEntry(date: .now, quote: "Work until you no longer have to introduce yourself.", configuration: ConfigurationAppIntent())
}
