import SwiftUI

/// The day's quote, set like a printed epigraph (or beside its author's portrait), with pin and share underneath.
struct TodayScreen: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let quote = model.today
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                PortraitStage(quote: quote, portrait: Portraits.image(for: quote, maxPixel: 1400),
                              size: QuoteSizing.size(for: quote.text), caption: DateText.long(model.now))
                    .ignoresSafeArea(edges: .top)
                PageHeader(left: "Virtus", right: "No. \(model.todayNumber + 1)")
            }
            QuoteActions(quote: quote)
                .padding(.bottom, 10)
        }
    }
}

/// Pin and share for a quote; feature appears once the quote is pinned.
struct QuoteActions: View {
    @Environment(AppModel.self) private var model
    var quote: Quote
    @State private var shareImage: Image?

    var body: some View {
        let pinned = model.isPinned(quote)
        HStack(spacing: 8) {
            ActionButton(icon: pinned ? "pin.fill" : "pin", title: pinned ? "Pinned" : "Pin", active: pinned) {
                model.togglePin(quote)
            }
            if pinned {
                let featured = model.featured?.id == quote.id
                ActionButton(icon: featured ? "star.fill" : "star", title: featured ? "Featured" : "Feature", active: featured) {
                    model.feature(quote)
                }
            }
            if let shareImage {
                ShareLink(item: shareImage, preview: SharePreview(quote.author, image: shareImage)) {
                    ActionLabel(icon: "square.and.arrow.up", title: "Share")
                }
                .buttonStyle(.plain)
            } else {
                ActionLabel(icon: "square.and.arrow.up", title: "Share").opacity(0.4)
            }
        }
        .background(VirtusPalette.black)
        .task(id: quote.id) { shareImage = await ShareImage.render(quote) }
    }
}

/// Renders the black share card once per quote.
enum ShareImage {
    @MainActor
    static func render(_ quote: Quote) async -> Image? {
        let renderer = ImageRenderer(content: ShareCard(quote: quote).environment(\.colorScheme, .dark))
        renderer.scale = 1
        guard let cg = renderer.cgImage else { return nil }
        return Image(decorative: cg, scale: 1)
    }
}
