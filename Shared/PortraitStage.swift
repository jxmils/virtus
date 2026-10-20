import SwiftUI

/// A quiet artwork layer for compact quotes; the foreground text keeps its full width.
struct QuoteBackdrop: View {
    var quote: Quote

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .trailing) {
                Color.black
                if let image = Portraits.image(for: quote, maxPixel: 520) {
                    Image(decorative: image, scale: 1)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width * 0.62, height: geo.size.height, alignment: .top)
                        .clipped()
                        .opacity(0.42)
                }
                LinearGradient(stops: [.init(color: .black, location: 0.2),
                                       .init(color: .black.opacity(0.72), location: 0.55),
                                       .init(color: .black.opacity(0.25), location: 1)],
                               startPoint: .leading, endPoint: .trailing)
            }
            .clipped()
        }
        .accessibilityHidden(true)
    }
}

/// A portrait fading into black with the quote set against it: beside the figure for short quotes, under it
/// for long ones. Without a portrait it is just the quote, centred.
struct PortraitStage: View {
    var quote: Quote
    var portrait: CGImage?
    var size: CGFloat
    /// Small caps above the quote, e.g. the date.
    var caption: String? = nil
    var showSource = true
    var inset: CGFloat = 28
    /// Quotes up to this many characters sit beside the portrait; longer ones go under it.
    var sideLimit = 150

    var body: some View {
        GeometryReader { geo in
            if let portrait {
                let side = quote.text.count <= sideLimit
                ZStack(alignment: side ? .leading : .top) {
                    FadedPortrait(image: portrait, side: side)
                        .frame(width: side ? geo.size.width * 0.66 : geo.size.width,
                               height: side ? geo.size.height : geo.size.height * 0.56)
                    if side {
                        HStack(spacing: 0) {
                            Spacer(minLength: 0)
                            captioned(QuoteBlock(quote: quote, size: size * 0.82, showSource: showSource), gap: size * 0.7)
                                .frame(width: geo.size.width * 0.52)
                        }
                        .padding(.trailing, inset)
                        .frame(height: geo.size.height)
                    } else {
                        VStack(spacing: 0) {
                            Spacer(minLength: geo.size.height * 0.42)
                            captioned(QuoteBlock(quote: quote, size: size * 0.9, showSource: showSource), gap: size * 0.8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, inset)
                            Spacer(minLength: inset)
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            } else {
                VStack {
                    Spacer()
                    captioned(QuoteBlock(quote: quote, size: size, showSource: showSource), gap: size)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, inset)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }

    private func captioned<V: View>(_ block: V, gap: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: gap) {
            if let caption { Caps(caption, size: max(8, size * 0.3), color: VirtusPalette.inkFaint, tracking: size * 0.08) }
            block
        }
    }
}

/// The portrait, filled and darkened, dissolving into the black on the side the text sits.
struct FadedPortrait: View {
    var image: CGImage
    var side: Bool

    var body: some View {
        GeometryReader { geo in
            Image(decorative: image, scale: 1)
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height, alignment: side ? .top : .center)
                .clipped()
                .overlay(Color.black.opacity(0.18))
                .overlay(
                    LinearGradient(stops: side
                                   ? [.init(color: .clear, location: 0.3), .init(color: .black, location: 1)]
                                   : [.init(color: .clear, location: 0.45), .init(color: .black, location: 1)],
                                   startPoint: side ? .leading : .top, endPoint: side ? .trailing : .bottom))
                .overlay(
                    LinearGradient(stops: side
                                   ? [.init(color: .clear, location: 0.55), .init(color: .black, location: 1)]
                                   : [.init(color: .clear, location: 0.4), .init(color: .black.opacity(0.85), location: 1)],
                                   startPoint: side ? .top : .leading, endPoint: side ? .bottom : .trailing))
                .overlay(LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .top,
                                        endPoint: UnitPoint(x: 0.5, y: side ? 0.5 : 0.32)))
        }
    }
}
