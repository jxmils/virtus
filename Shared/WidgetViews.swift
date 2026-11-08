import SwiftUI
import WidgetKit

/// One dot for every day of the year, ordered left to right, top to bottom.
struct YearInDotsContent: View {
    var progress: YearProgress
    var size: VirtusWidgetSize

    private var compact: Bool { size == .small }

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 8 : 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(String(progress.year)).font(VirtusFont.numeral(compact ? 22 : 30))
                Spacer(minLength: 4)
                if !compact { Caps("Year in dots", size: 9, color: VirtusPalette.inkSoft, tracking: 1.7) }
            }
            GeometryReader { geometry in
                let columns = size == .medium ? 31 : 20
                let rows = (progress.totalDays + columns - 1) / columns
                let cellWidth = geometry.size.width / CGFloat(columns)
                let cellHeight = geometry.size.height / CGFloat(rows)
                let diameter = min(cellWidth, cellHeight) * 0.66
                Canvas { context, _ in
                    for day in 0..<progress.totalDays {
                        let x = (CGFloat(day % columns) + 0.5) * cellWidth - diameter / 2
                        let y = (CGFloat(day / columns) + 0.5) * cellHeight - diameter / 2
                        let dot = Path(ellipseIn: CGRect(x: x, y: y, width: diameter, height: diameter))
                        if day < progress.daysPassed {
                            context.fill(dot, with: .color(VirtusPalette.ink))
                        } else {
                            context.stroke(dot, with: .color(VirtusPalette.inkSoft.opacity(0.7)), lineWidth: compact ? 0.65 : 0.85)
                        }
                    }
                }
            }
            .accessibilityHidden(true)
            HStack {
                Text("\(progress.daysPassed) passed")
                Spacer(minLength: 4)
                Text("\(progress.daysLeft) left").foregroundStyle(VirtusPalette.inkSoft)
            }
            .font(VirtusFont.label(compact ? 10 : 12))
            .monospacedDigit()
        }
        .foregroundStyle(VirtusPalette.ink)
        .padding(compact ? 14 : 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VirtusPalette.black)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(progress.year). \(progress.daysPassed) days completed. \(progress.daysLeft) days left, including today. Filled dots are completed days; outlined dots are days left.")
    }
}

enum VirtusWidgetSize {
    case small, medium, large, circular, rectangular, inline

    var isAccessory: Bool { self == .circular || self == .rectangular || self == .inline }
}

/// The widget's content for every family. Accessory families draw in the Lock Screen's own colours.
struct VirtusWidgetContent: View {
    var slot: WidgetSlot
    var size: VirtusWidgetSize
    /// The quote is one of the user's pins (shows the gold mark).
    var pinned: Bool
    /// What the widget was set to show; the large header says "Pinned" or the date accordingly.
    var source: WidgetSource = .today

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

    private var small: some View { homeWidget(base: 23, floor: 13, padding: 12) }
    private var medium: some View { homeWidget(base: 27, floor: 15, padding: 14) }
    private var large: some View { homeWidget(base: 36, floor: 21, padding: 18) }

    /// Fill the widget canvas with artwork; text gets the full usable width, including for long quotes.
    private func homeWidget(base: CGFloat, floor: CGFloat, padding: CGFloat) -> some View {
        ZStack {
            widgetArtwork
            VStack(alignment: .leading, spacing: size == .large ? 12 : 7) {
                if size == .large { largeHeader }
                Text(slot.hint ?? text)
                    .font(VirtusFont.quote(slot.hint == nil
                                          ? WidgetPlan.fontSize(for: slot.quote.text, base: base, floor: floor)
                                          : base * 0.75))
                    .foregroundStyle(VirtusPalette.ink)
                    .shadow(color: .black.opacity(0.7), radius: 2, y: 1)
                    .lineSpacing(size == .large ? 4 : 2)
                    .minimumScaleFactor(0.55)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .layoutPriority(1)
                HStack(spacing: 6) {
                    Caps(slot.quote.author, size: size == .small ? 9 : 11,
                         color: VirtusPalette.ink, tracking: size == .small ? 1 : 1.6)
                        .lineLimit(1).minimumScaleFactor(0.65)
                    Spacer(minLength: 0)
                    if pinned && size != .large { PinMark(size: 10) }
                }
            }
            .padding(padding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private var widgetArtwork: some View {
        GeometryReader { geo in
            ZStack {
                VirtusPalette.black
                if let portrait = Portraits.image(for: slot.quote, maxPixel: 520) {
                    let scale = max(geo.size.width / CGFloat(portrait.width), geo.size.height / CGFloat(portrait.height))
                    let height = CGFloat(portrait.height) * scale
                    Image(decorative: portrait, scale: 1)
                        .resizable()
                        .frame(width: CGFloat(portrait.width) * scale, height: height)
                        .offset(y: -(height - geo.size.height) * (size == .medium ? 0.12 : 0))
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                        .clipped()
                }
                // A continuous shade keeps full-bleed figures legible behind white type.
                LinearGradient(stops: [
                    .init(color: .black.opacity(size == .large ? 0.18 : 0.42), location: 0),
                    .init(color: .black.opacity(0.38), location: 0.38),
                    .init(color: .black.opacity(0.82), location: 1)
                ], startPoint: .top, endPoint: .bottom)
            }
        }
        .accessibilityHidden(true)
    }

    private var largeHeader: some View {
        HStack {
            Caps(source == .pinned ? "Pinned" : DateText.long(slot.date), size: 10, color: VirtusPalette.ink, tracking: 2)
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
