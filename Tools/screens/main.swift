import SwiftUI
import UIKit

// Renders Virtus's screens with a sample profile to one PNG (Mac Catalyst, no simulator needed).
// Usage: screens <output.png>

@MainActor
func run() async {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("virtus-screens-\(UUID().uuidString)")
    defer { try? FileManager.default.removeItem(at: tmp) }
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(identifier: "Europe/London")!
    let now = cal.date(from: DateComponents(year: 2026, month: 10, day: 15, hour: 9))!
    let env = VirtusEnvironment(shared: SharedStore(root: tmp), now: { now }, calendar: cal)
    let fresh = AppModel(env: VirtusEnvironment(shared: SharedStore(root: tmp.appendingPathComponent("fresh")), now: { now }, calendar: cal))
    let outPath = CommandLine.arguments.dropFirst().first ?? "screens.png"
    Portraits.directory = URL(fileURLWithPath: outPath).deletingLastPathComponent().appendingPathComponent("portraits")
    let model = AppModel(env: env)
    model.start()
    model.setName("Jason")
    model.pin(model.today)
    model.pin(model.archive(days: 9)[8].quote)
    model.pin(model.archive(days: 3)[2].quote)
    model.message = nil

    let longEpictetus = QuoteLibrary.all.first { $0.author == "Epictetus" && $0.text.count > 150 }!
    let marcus = QuoteLibrary.all.first { $0.author == "Marcus Aurelius" && $0.text.count < 90 }!
    let seneca = QuoteLibrary.all.first { $0.author == "Seneca" && $0.text.count < 90 }!
    let screens: [(String, AnyView)] = [
        ("today (portrait)", AnyView(TodayScreen().environment(model))),
        ("quote, long (portrait under)", AnyView(QuoteDetail(quote: longEpictetus, close: {}).environment(model))),
        ("quote, no portrait", AnyView(QuoteDetail(quote: seneca, close: {}).environment(model))),
        ("quote (widget tap)", AnyView(QuoteDetail(quote: marcus, close: {}).environment(model))),
        ("archive", AnyView(ArchiveScreen(preview: true).environment(model))),
        ("profile", AnyView(ProfileScreen(preview: true).environment(model))),
        ("profile (fresh)", AnyView(ProfileScreen(preview: true).environment(fresh))),
        ("add a widget", AnyView(WidgetGuideContent(close: {}).environment(model))),
    ]
    let rows = stride(from: 0, to: screens.count, by: 4).map { Array(screens[$0..<min($0 + 4, screens.count)]) }
    let sheet = VStack(alignment: .leading, spacing: 30) {
        ForEach(rows.indices, id: \.self) { r in
            HStack(alignment: .top, spacing: 24) {
                ForEach(rows[r].indices, id: \.self) { i in
                    VStack(spacing: 10) {
                        Text(rows[r][i].0).font(.headline).foregroundStyle(.white)
                        ZStack(alignment: .top) {
                            VirtusPalette.black
                            VStack(spacing: 0) {
                                rows[r][i].1
                                RouteBar(route: .constant(r == 1 && i == 0 ? .archive : (r == 1 && i < 3 ? .profile : .today)))
                            }
                            .padding(.top, 50)
                        }
                        .frame(width: 393, height: 852, alignment: .top)
                        .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
                    }
                }
            }
        }
    }
    .padding(24)
    .background(Color(rgb: 0x4B5563))
    .environment(\.colorScheme, .dark)
    .tint(VirtusPalette.gold)

    let renderer = ImageRenderer(content: sheet)
    renderer.scale = 1
    guard let image = renderer.uiImage, let data = image.pngData() else { print("render failed"); exit(1) }
    try? data.write(to: URL(fileURLWithPath: outPath))
    print("rendered \(Int(image.size.width))x\(Int(image.size.height))")
}

await run()
