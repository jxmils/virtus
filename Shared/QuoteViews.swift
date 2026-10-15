import SwiftUI

/// The quote as set type: hanging open quote, serif text, then the small-caps attribution.
struct QuoteBlock: View {
    var quote: Quote
    var size: CGFloat = 30
    var showSource = true
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: size * 0.55) {
            Text("\u{201C}\(quote.text)\u{201D}")
                .font(VirtusFont.quote(size))
                .foregroundStyle(VirtusPalette.ink)
                .lineSpacing(size * 0.22)
                .multilineTextAlignment(alignment == .center ? .center : .leading)
                .fixedSize(horizontal: false, vertical: true)
            Attribution(quote: quote, showSource: showSource, size: max(10, size * 0.4), alignment: alignment)
        }
    }
}

struct Attribution: View {
    var quote: Quote
    var showSource = true
    var size: CGFloat = 12
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: 5) {
            HStack(spacing: 10) {
                Rectangle().fill(VirtusPalette.inkSoft).frame(width: size * 1.6, height: max(1, (size / 12).rounded()))
                Caps(quote.author, size: size, color: VirtusPalette.ink, tracking: size * 0.22)
            }
            if showSource, !quote.source.isEmpty {
                Text(quote.source)
                    .font(VirtusFont.body(size + 1).italic())
                    .foregroundStyle(VirtusPalette.inkFaint)
                    .padding(.leading, size * 1.6 + 10)
            }
        }
    }
}

/// A 1080x1350 black card for sharing, like a printed epigraph (with the portrait when there is one).
struct ShareCard: View {
    var quote: Quote

    var body: some View {
        let portrait = Portraits.image(for: quote, maxPixel: 1400)
        ZStack {
            VirtusPalette.black
            PortraitStage(quote: quote, portrait: portrait, size: quote.text.count > 160 ? 52 : 64,
                          showSource: false, inset: 96, sideLimit: 150)
            VStack(alignment: .leading, spacing: 0) {
                Caps("Virtus", size: 26, color: VirtusPalette.inkFaint, tracking: 10)
                Spacer()
                if portrait == nil { Hairline() }
                HStack {
                    if !quote.source.isEmpty {
                        Text(quote.source).font(VirtusFont.body(28).italic()).foregroundStyle(VirtusPalette.inkFaint)
                    }
                    Spacer()
                    Caps(DateText.short(.now), size: 24, color: VirtusPalette.inkFaint, tracking: 4)
                }
                .padding(.top, 28)
            }
            .padding(96)
        }
        .frame(width: 1080, height: 1350)
    }
}

/// The app icon: black, a serif V inside a thin ring.
struct AppIconArt: View {
    var body: some View {
        ZStack {
            VirtusPalette.black
            Circle().strokeBorder(VirtusPalette.gold.opacity(0.9), lineWidth: 14).padding(180)
            Text("V")
                .font(.system(size: 500, weight: .regular, design: .serif))
                .foregroundStyle(VirtusPalette.ink)
                .offset(y: -16)
        }
    }
}
