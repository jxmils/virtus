import SwiftUI

/// Past days, newest first. Tap a day to read it in full.
struct ArchiveScreen: View {
    @Environment(AppModel.self) private var model
    /// The render harness has no ScrollView, so it asks for a short static list.
    var preview = false

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(left: "Archive", right: "Past days")
            if model.archive().isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("A little history, day by day.")
                        .font(VirtusFont.body(22)).foregroundStyle(VirtusPalette.ink)
                    Text("After each day, its quote will appear here.")
                        .font(VirtusFont.body(16)).foregroundStyle(VirtusPalette.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 28)
                .padding(.top, 32)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else if preview {
                VStack(spacing: 0) {
                    ArchiveList(items: Array(model.archive(days: 6))).padding(.horizontal, 28)
                    Spacer(minLength: 0)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .clipped()
            } else {
                ScrollView {
                    ArchiveList(items: model.archive()).padding(.horizontal, 28)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

struct ArchiveList: View {
    @Environment(AppModel.self) private var model
    var items: [(date: Date, quote: Quote)]

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(items, id: \.date) { item in
                Button {
                    model.selected = item.quote
                } label: {
                    QuoteRow(quote: item.quote, caption: DateText.relative(item.date, now: model.now), pinned: model.isPinned(item.quote))
                }
                .buttonStyle(.plain)
                Hairline()
            }
        }
        .padding(.top, 12)
    }
}
