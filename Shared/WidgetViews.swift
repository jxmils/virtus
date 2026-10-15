import SwiftUI
import WidgetKit

enum VirtusWidgetSize {
    case small, medium, large, circular, rectangular, inline

    var isAccessory: Bool { self == .circular || self == .rectangular || self == .inline }
}

/// The widget's content for every family. Accessory families draw in the Lock Screen's own colours.
struct VirtusWidgetContent: View {
    var slot: WidgetSlot
    var size: VirtusWidgetSize
    var pinned: Bool

    var url: URL { VirtusLink.quote(slot.quote.id) }

    var body: some View {
        switch size {
        case .small: small
        case .medium: medium
        case .large: large
        case .circular: circular
        case .rectangular: rectangular
        case .inline: inline
        }
    }

    private var text: String { "\u{201C}\(slot.quote.text)\u{201D}" }

    private var small: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let hint = slot.hint {
                Text(hint).font(VirtusFont.body(14)).foregroundStyle(VirtusPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(text)
                    .font(VirtusFont.quote(WidgetPlan.fontSize(for: slot.quote.text, base: 17, floor: 11)))
                    .foregroundStyle(VirtusPalette.ink)
                    .lineSpacing(2)
                    .minimumScaleFactor(0.6)
            }
            Spacer(minLength: 0)
            HStack(spacing: 6) {
                Caps(slot.quote.author, size: 9, color: VirtusPalette.inkSoft, tracking: 1.4).lineLimit(1).minimumScaleFactor(0.7)
                Spacer(minLength: 0)
                if pinned { PinMark(size: 9) }
            }
        }
        .padding(14)
    }

    private var medium: some View {
        HStack(alignment: .top, spacing: 14) {
            Rectangle().fill(VirtusPalette.gold.opacity(pinned ? 0.9 : 0)).frame(width: 2)
            VStack(alignment: .leading, spacing: 8) {
                if let hint = slot.hint {
                    Text(hint).font(VirtusFont.body(15)).foregroundStyle(VirtusPalette.inkSoft)
                } else {
                    Text(text)
                        .font(VirtusFont.quote(WidgetPlan.fontSize(for: slot.quote.text, base: 19, floor: 12)))
                        .foregroundStyle(VirtusPalette.ink)
                        .lineSpacing(3)
                        .minimumScaleFactor(0.6)
                }
                Spacer(minLength: 0)
                Caps(slot.quote.author, size: 10, color: VirtusPalette.inkSoft, tracking: 1.8).lineLimit(1)
            }
        }
        .padding(16)
    }

    @ViewBuilder private var large: some View {
        if slot.hint == nil, let portrait = Portraits.image(for: slot.quote, maxPixel: 520) {
            ZStack(alignment: .top) {
                PortraitStage(quote: slot.quote, portrait: portrait,
                              size: WidgetPlan.fontSize(for: slot.quote.text, base: 24, floor: 15),
                              showSource: false, inset: 18, sideLimit: 110)
                largeHeader.padding(20)
            }
        } else {
            VStack(alignment: .leading, spacing: 0) {
                largeHeader
                Spacer(minLength: 12)
                if let hint = slot.hint {
                    Text(hint).font(VirtusFont.body(17)).foregroundStyle(VirtusPalette.inkSoft)
                } else {
                    QuoteBlock(quote: slot.quote, size: WidgetPlan.fontSize(for: slot.quote.text, base: 26, floor: 16), showSource: true)
                        .minimumScaleFactor(0.7)
                }
                Spacer(minLength: 12)
            }
            .padding(20)
        }
    }

    private var largeHeader: some View {
        HStack {
            Caps(pinned ? "Pinned" : DateText.long(slot.date), size: 10, color: VirtusPalette.inkFaint, tracking: 2)
            Spacer()
            if pinned { PinMark(size: 10) }
        }
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            Text("V").font(.system(size: 30, weight: .regular, design: .serif))
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(slot.hint ?? text)
                .font(.system(size: 13, weight: .regular, design: .serif))
                .lineLimit(3)
                .minimumScaleFactor(0.8)
            Text(slot.quote.author.uppercased())
                .font(.system(size: 9, weight: .medium, design: .serif))
                .tracking(1.2)
                .opacity(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var inline: some View {
        Text(slot.hint ?? "\(slot.quote.text) \u{2014} \(slot.quote.author)")
    }
}

/// The small gold mark for pinned quotes.
struct PinMark: View {
    var size: CGFloat = 10

    var body: some View {
        Image(systemName: "pin.fill")
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(VirtusPalette.gold)
            .rotationEffect(.degrees(45))
    }
}
