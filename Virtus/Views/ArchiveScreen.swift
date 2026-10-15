import SwiftUI

/// Past days, newest first. Tap a day to read it in full.
struct ArchiveScreen: View {
    @Environment(AppModel.self) private var model
    /// The render harness has no ScrollView, so it asks for a short static list.
    var preview = false

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(left: "Archive", right: "Past days")
            if preview {
                ArchiveList(items: Array(model.archive(days: 4))).padding(.horizontal, 28)
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
