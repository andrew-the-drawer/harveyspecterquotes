//
//  QuoteWidget.swift
//  QuoteWidget
//
//  Created by Trung Nguyen on 14/12/25.
//

import WidgetKit
import SwiftUI


struct Provider: AppIntentTimelineProvider {
    // Cached quotes filtered to 15 words or less
    private static let cachedQuotes: [String] = {
        guard let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let quotes = try? JSONDecoder().decode([String].self, from: data) else {
            return ["No quote available"]
        }
        return quotes.filter { $0.split(separator: " ").count <= 15 }
    }()

    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: Date(), quote: "I don't get lucky, I make my own luck", configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> QuoteEntry {
        return QuoteEntry(date: Date(), quote: "I don't get lucky, I make my own luck" , configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<QuoteEntry> {
        var entries: [QuoteEntry] = []

        let currentDate = Date()
        let calendar = Calendar.current

        // Add current entry
        let currentQuote = quoteRandom()
        entries.append(QuoteEntry(date: currentDate, quote: currentQuote, configuration: configuration))

        // Calculate next entry date based on time of day
        let hour = calendar.component(.hour, from: currentDate)

        let nextDate: Date

        if hour >= 23 || hour < 7 {
            // Night time (11pm - 7am): schedule for 8:00am
            var components = calendar.dateComponents([.year, .month, .day], from: currentDate)
            components.hour = 8
            components.minute = 0
            components.second = 0

            if hour >= 23 {
                // After 11pm, schedule for 8am next day
                if let baseDate = calendar.date(from: components),
                   let tomorrow8am = calendar.date(byAdding: .day, value: 1, to: baseDate) {
                    nextDate = tomorrow8am
                } else {
                    nextDate = calendar.date(byAdding: .hour, value: 2, to: currentDate)!
                }
            } else {
                // Before 7am, schedule for 8am same day
                nextDate = calendar.date(from: components) ?? calendar.date(byAdding: .hour, value: 2, to: currentDate)!
            }
        } else if hour >= 12 && hour < 14 {
            // Lunch time (12pm - 2pm): schedule for 2:30pm same day
            var components = calendar.dateComponents([.year, .month, .day], from: currentDate)
            components.hour = 14
            components.minute = 30
            components.second = 0
            nextDate = calendar.date(from: components) ?? calendar.date(byAdding: .hour, value: 2, to: currentDate)!
        } else {
            // Otherwise: every 2 hours
            nextDate = calendar.date(byAdding: .hour, value: 2, to: currentDate)!
        }

        // Add next entry
        let nextQuote = quoteRandom()
        entries.append(QuoteEntry(date: nextDate, quote: nextQuote, configuration: configuration))

        // Generate a timeline with 2 entries (current + next)
        return Timeline(entries: entries, policy: .atEnd)
    }

    /// Returns a quote based on counter value
    private func quoteRandom() -> String {
        let quotes = Self.cachedQuotes
        if let q = quotes.randomElement() {
            return q
        } else {
            return "I don't get lucky. I make my own luck"
        }
    }
}

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: String
    let configuration: ConfigurationAppIntent
}

struct AccessoryRectangularView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // Premium gradient background
            LinearGradient.widgetPremiumGradient

            // Subtle texture overlay
            Color.white.opacity(0.02)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.quote)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.pearlWhite)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                HStack(spacing: 2) {
                    Rectangle()
                        .fill(Color.gold)
                        .frame(width: 8, height: 1)

                    Text("Harvey Specter")
                        .font(.system(size: 8, weight: .light))
                        .foregroundColor(.pearlWhite.opacity(0.8))
                        .italic()
                }
            }
            .padding(8)
        }
    }
}

struct QuoteWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        default:
            // Standard medium widget view
            ZStack {
                // Premium gradient background
                LinearGradient.widgetPremiumGradient

                // Subtle texture overlay
                Color.white.opacity(0.02)

                VStack(spacing: 8) {
                    // Quote text - wrapped to fit widget
                    Text(entry.quote)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.pearlWhite)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.7)

                    // Attribution with gold accent
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.gold)
                            .frame(width: 16, height: 1.5)

                        Text("H.S.")
                            .font(.system(size: 10, weight: .light))
                            .foregroundColor(.pearlWhite.opacity(0.9))
                            .italic()
                            .tracking(1)
                    }
                }
                .padding(16)
            }
        }
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
        .supportedFamilies([.systemMedium, .accessoryRectangular])
    }
}

#Preview("Lock Screen", as: .accessoryRectangular) {
    QuoteWidget()
} timeline: {
    QuoteEntry(date: .now, quote: "I don't have dreams, I have goals.", configuration: ConfigurationAppIntent())
    QuoteEntry(date: .now, quote: "It's going to happen, because I am going to make it happen.", configuration: ConfigurationAppIntent())
}

#Preview("Medium", as: .systemMedium) {
    QuoteWidget()
} timeline: {
    QuoteEntry(date: .now, quote: "I don't have dreams, I have goals.", configuration: ConfigurationAppIntent())
    QuoteEntry(date: .now, quote: "When you're backed against the wall, break the goddamn thing down.", configuration: ConfigurationAppIntent())
}
