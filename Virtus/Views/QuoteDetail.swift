import SwiftUI

/// One quote full screen, from the Archive, the Profile or a widget tap.
struct QuoteDetail: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    var quote: Quote
    /// The harness renders without a presentation, so it passes its own close.
    var close: (() -> Void)?

    var body: some View {
        ZStack {
            VirtusPalette.black.ignoresSafeArea()
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    PortraitStage(quote: quote, portrait: Portraits.image(for: quote, maxPixel: 1400),
                                  size: QuoteSizing.size(for: quote.text))
                        .ignoresSafeArea(edges: .top)
                    HStack {
                        Caps("Virtus", size: 10, color: VirtusPalette.inkFaint, tracking: 3)
                        Spacer()
                        Button {
                            if let close { close() } else { model.selected = nil; dismiss() }
                        } label: {
                            Image(systemName: "xmark").font(.system(size: 15, weight: .light)).foregroundStyle(VirtusPalette.inkSoft)
                                .frame(width: 32, height: 32).contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 18)
                }
                QuoteActions(quote: quote).padding(.bottom, 24)
            }
        }
        .overlay(alignment: .top) { MessageBanner() }
        .animation(.snappy, value: model.message)
    }
}
