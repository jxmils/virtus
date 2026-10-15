import SwiftUI
import UIKit

// Renders Virtus's screens with a sample profile to one PNG (Mac Catalyst, no simulator needed).
// Usage: screens <output.png>

/// App Store screenshots: 440x956 pt at 3x = 1320x2868 (iPhone 6.9"). Today is rendered on a day whose
/// quote has a portrait, so the first screenshot shows the art.
@MainActor
func store(into dir: URL) async {
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("virtus-store-\(UUID().uuidString)")
    defer { try? FileManager.default.removeItem(at: tmp) }
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(identifier: "Europe/London")!
    Portraits.directory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Portraits")
    let leonidasDay = (0..<QuoteLibrary.all.count).first { DailyQuote.quote(day: $0).author == "Leonidas" } ?? 0
    let now = cal.date(byAdding: .day, value: leonidasDay, to: cal.startOfDay(for: DailyQuote.epoch))!.addingTimeInterval(9 * 3600)
    let model = AppModel(env: VirtusEnvironment(shared: SharedStore(root: tmp), now: { now }, calendar: cal))
    model.start()
    model.setName("Jason")
    model.setReminder(on: true, hour: 7, minute: 0)
    for d in [0, 2, 5] { model.pin(d == 0 ? model.today : model.archive(days: 6)[d].quote) }
    model.message = nil
    let alexander = QuoteLibrary.all.first { $0.author == "Alexander the Great" && $0.text.count > 100 }!
    let marcus = QuoteLibrary.all.first { $0.author == "Marcus Aurelius" && $0.text.count < 60 }!

    let widgets = VStack(alignment: .leading, spacing: 22) {
        Caps("On your Home Screen", size: 11, color: VirtusPalette.inkFaint, tracking: 3).padding(.top, 60)
        VirtusWidgetContent(slot: WidgetSlot(date: now, quote: model.today), size: .large, pinned: true)
            .frame(width: 364, height: 382).background(VirtusPalette.black)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(VirtusPalette.hairline))
        HStack(spacing: 22) {
            VirtusWidgetContent(slot: WidgetSlot(date: now, quote: marcus), size: .small, pinned: false)
                .frame(width: 171, height: 171).background(VirtusPalette.black)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(VirtusPalette.hairline))
            VStack(alignment: .leading, spacing: 10) {
                Caps("Lock Screen", size: 10, color: VirtusPalette.inkFaint, tracking: 2.4)
                VirtusWidgetContent(slot: WidgetSlot(date: now, quote: marcus), size: .rectangular, pinned: false)
                    .foregroundStyle(VirtusPalette.ink).frame(width: 171)
            }
        }
        Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 38)

    let shots: [(String, AnyView, AppModel.Route)] = [
        ("1-today", AnyView(TodayScreen().environment(model)), .today),
        ("2-quote", AnyView(QuoteDetail(quote: alexander, close: {}).environment(model)), .today),
        ("3-profile", AnyView(ProfileScreen(preview: true).environment(model)), .profile),
        ("4-archive", AnyView(ArchiveScreen(preview: true).environment(model)), .archive),
        ("5-widgets", AnyView(widgets), .today),
    ]
    for (name, view, route) in shots {
        let page = ZStack(alignment: .top) {
            VirtusPalette.black
            VStack(spacing: 0) {
                view
                RouteBar(route: .constant(route)).padding(.bottom, 24)
            }
            .padding(.top, 54)
        }
        .frame(width: 440, height: 956)
        .environment(\.colorScheme, .dark)
        .tint(VirtusPalette.gold)
        let renderer = ImageRenderer(content: page)
        renderer.scale = 3
        guard let image = renderer.uiImage, let data = image.pngData() else { print("render failed: \(name)"); exit(1) }
        try? data.write(to: dir.appendingPathComponent("\(name).png"))
        print("store \(name) \(Int(image.size.width * image.scale))x\(Int(image.size.height * image.scale))")
    }
}

@MainActor
func run() async {
    if CommandLine.arguments.dropFirst().first == "--store" {
        await store(into: URL(fileURLWithPath: CommandLine.arguments.dropFirst(2).first ?? "build/store"))
        return
    }
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
    let leonidas = QuoteLibrary.all.first { $0.author == "Leonidas" }!
    let alexander = QuoteLibrary.all.first { $0.author == "Alexander the Great" && $0.text.count > 100 }!
    let screens: [(String, AnyView)] = [
        ("leonidas (real art)", AnyView(QuoteDetail(quote: leonidas, close: {}).environment(model))),
        ("alexander (real art)", AnyView(QuoteDetail(quote: alexander, close: {}).environment(model))),
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
                                RouteBar(route: .constant(r == 1 && i == 2 ? .archive : (r == 1 && i == 3 || r == 2 && i == 0 ? .profile : .today)))
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
