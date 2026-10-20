import SwiftUI

/// The small wordmark and date at the top of a page.
struct PageHeader: View {
    var left: String
    var right: String = ""

    var body: some View {
        HStack {
            Caps(left, size: 10, color: VirtusPalette.inkFaint, tracking: 3)
            Spacer()
            if !right.isEmpty { Caps(right, size: 10, color: VirtusPalette.inkFaint, tracking: 2) }
        }
        .padding(.horizontal, 28)
        .padding(.top, 18)
    }
}

/// An icon with a small-caps word under it, for the actions under a quote.
struct ActionButton: View {
    var icon: String
    var title: String
    var active = false
    var action: () -> Void

    var body: some View {
        Button(action: action) { ActionLabel(icon: icon, title: title, active: active) }
            .buttonStyle(.plain)
    }
}

struct ActionLabel: View {
    var icon: String
    var title: String
    var active = false

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(active ? VirtusPalette.gold : VirtusPalette.ink)
                .frame(height: 22)
            Caps(title, size: 9, color: active ? VirtusPalette.gold : VirtusPalette.inkSoft, tracking: 1.8)
        }
        .frame(minWidth: 72)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

/// Size the quote so short lines are grand and long ones still fit.
enum QuoteSizing {
    static func size(for text: String, max: CGFloat = 34, min: CGFloat = 21) -> CGFloat {
        switch text.count {
        case ..<70: return max
        case ..<130: return Swift.max(min, max * 0.85)
        case ..<200: return Swift.max(min, max * 0.72)
        default: return min
        }
    }
}

/// A quote in a list: date caption, three lines of the text, the author.
struct QuoteRow: View {
    var quote: Quote
    var caption: String
    var pinned = false
    var featured = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Caps(caption, size: 9, color: featured ? VirtusPalette.gold : VirtusPalette.inkFaint, tracking: 2)
                Spacer()
                if pinned { PinMark(size: 10) }
            }
            Text("\u{201C}\(quote.text)\u{201D}")
                .font(VirtusFont.quote(19))
                .foregroundStyle(VirtusPalette.ink)
                .lineSpacing(4)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Caps(quote.author, size: 10, color: VirtusPalette.inkSoft, tracking: 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 20)
        .background { QuoteBackdrop(quote: quote) }
        .contentShape(Rectangle())
    }
}

/// The initial in a thin ring on the Profile.
struct Monogram: View {
    var name: String
    var size: CGFloat = 72

    var body: some View {
        ZStack {
            Circle().strokeBorder(VirtusPalette.gold.opacity(0.8), lineWidth: 1)
            Text(String(name.trimmingCharacters(in: .whitespaces).first.map(String.init) ?? "V").uppercased())
                .font(.system(size: size * 0.46, weight: .regular, design: .serif))
                .foregroundStyle(VirtusPalette.ink)
        }
        .frame(width: size, height: size)
    }
}

struct Stat: View {
    var value: Int
    var label: String

    var body: some View {
        VStack(spacing: 6) {
            Text("\(value)").font(VirtusFont.numeral(28)).foregroundStyle(VirtusPalette.ink)
            Caps(label, size: 9, color: VirtusPalette.inkFaint, tracking: 2)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Three steps to put Virtus on the Home or Lock Screen.
struct WidgetGuideContent: View {
    var close: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack {
                Caps("Add a widget", size: 11, color: VirtusPalette.ink, tracking: 3)
                Spacer()
                Button(action: close) {
                    Image(systemName: "xmark").font(.system(size: 15, weight: .light)).foregroundStyle(VirtusPalette.inkSoft)
                }
                .buttonStyle(.plain)
            }
            step(1, "Hold an empty spot on your Home Screen, then tap Edit and Add Widget.")
            step(2, "Search for Virtus and pick a size.")
            step(3, "Hold the widget and tap Edit Widget to show today’s quote or your pinned ones.")
            Hairline()
            Text("For the Lock Screen: hold the Lock Screen, tap Customise, then add Virtus.")
                .font(VirtusFont.body(15)).foregroundStyle(VirtusPalette.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(28)
        .background(VirtusPalette.black)
    }

    private func step(_ n: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(n)").font(VirtusFont.numeral(22)).foregroundStyle(VirtusPalette.gold).frame(width: 18)
            Text(text).font(VirtusFont.body(17)).foregroundStyle(VirtusPalette.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
