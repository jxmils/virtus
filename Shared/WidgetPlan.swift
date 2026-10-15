import Foundation

/// What a widget shows: today's quote, or the quotes you pinned, in turn.
enum WidgetSource: String, Codable, CaseIterable {
    case today, pinned
}

/// One widget timeline entry, computed without WidgetKit so the self-test can cover it.
struct WidgetSlot: Equatable {
    var date: Date
    var quote: Quote
    /// Shown instead of the quote when there is nothing pinned yet.
    var hint: String?
}

enum WidgetPlan {
    /// Today's quote, then the next few midnights; WidgetKit asks again after the last one.
    /// Pinned: the featured quote first, then the rest, changing every hour.
    static func slots(source: WidgetSource, profile: Profile, now: Date, calendar: Calendar = .autoupdatingCurrent) -> [WidgetSlot] {
        switch source {
        case .today:
            var slots = [WidgetSlot(date: now, quote: DailyQuote.quote(for: now, calendar: calendar))]
            var day = calendar.startOfDay(for: now)
            for _ in 0..<3 {
                guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
                slots.append(WidgetSlot(date: next, quote: DailyQuote.quote(for: next, calendar: calendar)))
                day = next
            }
            return slots
        case .pinned:
            let pinned = profile.pinnedQuotes
            guard !pinned.isEmpty else {
                return [WidgetSlot(date: now, quote: DailyQuote.quote(for: now, calendar: calendar), hint: "Pin quotes in Virtus to see them here")]
            }
            let hour = calendar.dateComponents([.hour], from: calendar.startOfDay(for: now), to: now).hour ?? 0
            let start = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: now) ?? now
            let dayNumber = DailyQuote.dayNumber(for: now, calendar: calendar)
            return (0..<24).map { i in
                let date = i == 0 ? now : (calendar.date(byAdding: .hour, value: i, to: start) ?? now)
                // Rotate from a day-based offset so the order moves on from day to day as well.
                let index = (dayNumber * 24 + hour + i) % pinned.count
                return WidgetSlot(date: date, quote: pinned[((index % pinned.count) + pinned.count) % pinned.count])
            }
        }
    }

    /// Font size that fits a quote of this length into a widget family's text box.
    static func fontSize(for text: String, base: CGFloat, floor: CGFloat) -> CGFloat {
        let n = text.count
        switch n {
        case ..<60: return base
        case ..<110: return max(floor, base * 0.86)
        case ..<170: return max(floor, base * 0.72)
        default: return max(floor, base * 0.6)
        }
    }
}
