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
            return "I don't have dreams, I have goals."
        }

        // Filter quotes to 15 words or less for widget display
        let shortQuotes = quotes.filter { quote in
            quote.split(separator: " ").count <= 15
        }

        return shortQuotes.randomElement() ?? "I don't have dreams, I have goals."
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
