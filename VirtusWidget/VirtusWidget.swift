import SwiftUI
import WidgetKit
import AppIntents

@main
struct VirtusWidgetBundle: WidgetBundle {
    var body: some Widget {
        VirtusQuoteWidget()
    }
}

/// The one choice when you edit the widget: today's quote, or your pinned quotes in turn.
enum QuoteSourceOption: String, AppEnum {
    case today, pinned

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Quotes")
    static let caseDisplayRepresentations: [QuoteSourceOption: DisplayRepresentation] = [
        .today: "Today’s quote",
        .pinned: "My pinned quotes",
    ]

    var source: WidgetSource { self == .today ? .today : .pinned }
}

struct QuoteSourceIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Virtus"
    static let description = IntentDescription("Choose which quotes the widget shows.")

    @Parameter(title: "Show", default: .today)
    var show: QuoteSourceOption
}

struct VirtusEntry: TimelineEntry {
    let date: Date
    let slot: WidgetSlot
    let pinned: Bool
}

struct VirtusProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> VirtusEntry {
        VirtusEntry(date: .now, slot: WidgetSlot(date: .now, quote: QuoteLibrary.all[0]), pinned: false)
    }

    func snapshot(for configuration: QuoteSourceIntent, in context: Context) async -> VirtusEntry {
        entries(for: configuration, now: .now).first ?? placeholder(in: context)
    }

    func timeline(for configuration: QuoteSourceIntent, in context: Context) async -> Timeline<VirtusEntry> {
        Timeline(entries: entries(for: configuration, now: .now), policy: .atEnd)
    }

    private func entries(for configuration: QuoteSourceIntent, now: Date) -> [VirtusEntry] {
        let profile = SharedStore.live.load()
        let source = configuration.show.source
        return WidgetPlan.slots(source: source, profile: profile, now: now).map {
            VirtusEntry(date: $0.date, slot: $0, pinned: $0.hint == nil && profile.isPinned($0.quote.id))
        }
    }
}

struct VirtusQuoteWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: VirtusConfig.widgetKind, intent: QuoteSourceIntent.self, provider: VirtusProvider()) { entry in
            VirtusWidgetView(entry: entry)
        }
        .configurationDisplayName("Virtus")
        .description("Today’s quote, or the ones you pinned.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryRectangular, .accessoryInline])
        .contentMarginsDisabled()
    }
}

struct VirtusWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: VirtusEntry

    private var size: VirtusWidgetSize {
        switch family {
        case .systemMedium: .medium
        case .systemLarge, .systemExtraLarge: .large
        case .accessoryCircular: .circular
        case .accessoryRectangular: .rectangular
        case .accessoryInline: .inline
        default: .small
        }
    }

    var body: some View {
        let content = VirtusWidgetContent(slot: entry.slot, size: size, pinned: entry.pinned)
        content
            .widgetURL(content.url)
            .containerBackground(for: .widget) {
                if size.isAccessory { Color.clear } else { VirtusPalette.black }
            }
    }
}
