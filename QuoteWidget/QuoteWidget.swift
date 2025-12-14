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
            return "It’s going to happen, because I am going to make it happen."
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
            // Premium gradient background
            LinearGradient.widgetPremiumGradient

            // Subtle texture overlay
            Color.white.opacity(0.02)

            VStack(spacing: widgetFamily == .systemSmall ? 12 : 16) {
                // Decorative quote mark
                Text("\"")
                    .font(.system(size: widgetFamily == .systemSmall ? 32 : 40, weight: .bold))
                    .foregroundColor(.gold.opacity(0.3))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: widgetFamily == .systemSmall ? -8 : -12, y: widgetFamily == .systemSmall ? -4 : -8)

                Spacer()

                // Quote text with marquee scrolling for long quotes
                MarqueeText(
                    text: entry.quote,
                    font: .system(
                        size: widgetFamily == .systemSmall ? 13 : 15,
                        weight: .medium,
                        design: .serif
                    ),
                    fontSize: widgetFamily == .systemSmall ? 13 : 15,
                    textColor: .pearlWhite,
                    lineLimit: widgetFamily == .systemSmall ? 5 : 7,
                    availableHeight: widgetFamily == .systemSmall ? 80 : 110
                )
                .frame(height: widgetFamily == .systemSmall ? 80 : 110)
                .padding(.horizontal, 8)

                Spacer()

                // Attribution with gold accent
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.gold)
                        .frame(width: 20, height: 1.5)

                    Text("H.S.")
                        .font(.system(
                            size: widgetFamily == .systemSmall ? 10 : 12,
                            weight: .light
                        ))
                        .foregroundColor(.pearlWhite.opacity(0.9))
                        .italic()
                        .tracking(1)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(widgetFamily == .systemSmall ? 16 : 20)
        }
    }
}

// Marquee-style scrolling text for long quotes
struct MarqueeText: View {
    let text: String
    let font: Font
    let fontSize: CGFloat
    let textColor: Color
    let lineLimit: Int
    let availableHeight: CGFloat

    @State private var offset: CGFloat = 0
    @State private var shouldScroll: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if shouldScroll {
                    // Horizontal marquee scrolling for very long text
                    HStack(spacing: 50) {
                        Text(text)
                            .font(font)
                            .foregroundColor(textColor)
                            .lineLimit(1)
                            .fixedSize()

                        Text(text)
                            .font(font)
                            .foregroundColor(textColor)
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .offset(x: offset)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .onAppear {
                        startScrolling(containerWidth: geometry.size.width)
                    }
                } else {
                    // Static multi-line text for normal quotes
                    Text(text)
                        .font(font)
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(lineLimit)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            .frame(width: geometry.size.width, alignment: shouldScroll ? .leading : .center)
            .clipped()
            .onAppear {
                checkIfScrollingNeeded(
                    containerWidth: geometry.size.width,
                    containerHeight: geometry.size.height
                )
            }
        }
    }

    private func checkIfScrollingNeeded(containerWidth: CGFloat, containerHeight: CGFloat) {
        // Use marquee if text is too long vertically or horizontally
        shouldScroll = true
    }

    private func startScrolling(containerWidth: CGFloat) {
        let textWidth = text.size(
            withAttributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .medium)]
        ).width

        let scrollDistance = textWidth + 50
        let duration: Double = Double(scrollDistance / 40) // 40 points per second

        withAnimation(
            Animation.linear(duration: duration)
                .repeatForever(autoreverses: false)
        ) {
            offset = -scrollDistance
        }
    }
}

// Helper extension to calculate text dimensions
extension String {
    func size(withAttributes attributes: [NSAttributedString.Key: Any]) -> CGSize {
        let size = (self as NSString).size(withAttributes: attributes)
        return size
    }

    func heightForWidth(width: CGFloat, font: UIFont) -> CGFloat {
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
    QuoteEntry(date: .now, quote: "Ever loved someone so much, you would do anything for them? Yeah, well make that someone yourself and do whatever the hell you want", configuration: ConfigurationAppIntent())
}
