import SwiftUI

/// Three pages under one thin bar: Today, Archive, Profile. A quote opens full screen on top.
struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        ZStack {
            VirtusPalette.black.ignoresSafeArea()
            VStack(spacing: 0) {
                Group {
                    switch model.route {
                    case .today: TodayScreen()
                    case .archive: ArchiveScreen()
                    case .profile: ProfileScreen()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                RouteBar(route: $model.route)
            }
        }
        .overlay(alignment: .top) { MessageBanner() }
        .animation(.snappy, value: model.message)
        .fullScreenCover(item: $model.selected) { quote in
            QuoteDetail(quote: quote)
        }
        .task(id: model.message) {
            guard model.message != nil else { return }
            try? await Task.sleep(for: .seconds(1.6))
            model.message = nil
        }
    }
}

/// The bottom bar: three small-caps labels, the current one in ink.
struct RouteBar: View {
    @Binding var route: AppModel.Route

    var body: some View {
        VStack(spacing: 0) {
            Hairline()
            HStack {
                ForEach(AppModel.Route.allCases, id: \.self) { r in
                    Button {
                        route = r
                    } label: {
                        Caps(r.title, size: 11, color: route == r ? VirtusPalette.ink : VirtusPalette.inkFaint, tracking: 2.4)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .background(VirtusPalette.black)
    }
}

struct MessageBanner: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if let text = model.message {
            Caps(text, size: 10, color: VirtusPalette.ink, tracking: 2)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(VirtusPalette.raised, in: Capsule())
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
