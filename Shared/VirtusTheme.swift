import SwiftUI

// Virtus looks like an engraved plate: true black, warm off-white serif type, small-caps attributions,
// hairlines instead of boxes, and one muted gold used only for what you have pinned.

enum VirtusPalette {
    static let black = Color(rgb: 0x000000)
    static let surface = Color(rgb: 0x0E0E0F)
    static let raised = Color(rgb: 0x1A1A1C)
    static let hairline = Color.white.opacity(0.10)
    static let ink = Color(rgb: 0xEDE8DF)
    static let inkSoft = Color(rgb: 0x9A958C)
    static let inkFaint = Color(rgb: 0x5A5751)
    /// The one accent: pinned quotes and the featured mark.
    static let gold = Color(rgb: 0xC9A961)
}

enum VirtusFont {
    /// The quote itself, New York serif like a printed epigraph.
    static func quote(_ size: CGFloat = 30) -> Font { .system(size: size, weight: .regular, design: .serif) }
    static func quoteItalic(_ size: CGFloat = 30) -> Font { .system(size: size, weight: .regular, design: .serif).italic() }
    /// Small caps attribution: — MARCUS AURELIUS
    static func caps(_ size: CGFloat = 12) -> Font { .system(size: size, weight: .medium, design: .serif) }
    static func body(_ size: CGFloat = 16) -> Font { .system(size: size, weight: .regular, design: .serif) }
    static func label(_ size: CGFloat = 13) -> Font { .system(size: size, weight: .medium) }
    static func wordmark(_ size: CGFloat = 15) -> Font { .system(size: size, weight: .semibold, design: .serif) }
    static func numeral(_ size: CGFloat = 28) -> Font { .system(size: size, weight: .light, design: .serif) }
}

extension Color {
    init(rgb: UInt32) {
        self.init(red: Double((rgb >> 16) & 0xFF) / 255,
                  green: Double((rgb >> 8) & 0xFF) / 255,
                  blue: Double(rgb & 0xFF) / 255)
    }
}

/// Tracked uppercase text: the attribution and section labels.
struct Caps: View {
    var text: String
    var size: CGFloat = 12
    var color: Color = VirtusPalette.inkSoft
    var tracking: CGFloat = 2.2

    init(_ text: String, size: CGFloat = 12, color: Color = VirtusPalette.inkSoft, tracking: CGFloat = 2.2) {
        self.text = text; self.size = size; self.color = color; self.tracking = tracking
    }

    var body: some View {
        Text(text.uppercased())
            .font(VirtusFont.caps(size))
            .tracking(tracking)
            .foregroundStyle(color)
    }
}

struct Hairline: View {
    var body: some View {
        Rectangle().fill(VirtusPalette.hairline).frame(height: 1)
    }
}

enum DateText {
    static let calendar = Calendar.autoupdatingCurrent

    /// THURSDAY, 15 OCTOBER
    static func long(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = calendar
        f.locale = Locale.autoupdatingCurrent
        f.setLocalizedDateFormatFromTemplate("EEEEdMMMM")
        return f.string(from: date)
    }

    /// 15 OCT
    static func short(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = calendar
        f.locale = Locale.autoupdatingCurrent
        f.setLocalizedDateFormatFromTemplate("dMMM")
        return f.string(from: date)
    }

    /// Today, Yesterday, or the short date.
    static func relative(_ date: Date, now: Date) -> String {
        if calendar.isDate(date, inSameDayAs: now) { return "Today" }
        if let y = calendar.date(byAdding: .day, value: -1, to: now), calendar.isDate(date, inSameDayAs: y) { return "Yesterday" }
        return long(date)
    }
}
