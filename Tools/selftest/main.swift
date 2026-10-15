import Foundation
import SwiftUI
import ImageIO
import UniformTypeIdentifiers

// Checks the quote library, the daily order, pins/streak and the widget plan with a fake clock,
// then renders the widgets and the app icon to PNGs.
// Usage: selftest <output dir>

var failures = 0
func check(_ ok: Bool, _ what: String) {
    print(ok ? "ok    \(what)" : "FAIL  \(what)")
    if !ok { failures += 1 }
}

func writePNG(_ image: CGImage, to url: URL) {
    guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { return }
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
}

/// A stand-in portrait so the layout and fades can be checked before real art exists: a bronze head and
/// shoulders with a crimson cloak on black, 1080x1350, written as JPEG.
func makePortrait(seed: Int, to url: URL) {
    let w = 1080, h = 1350
    let space = CGColorSpace(name: CGColorSpace.sRGB)!
    guard let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0, space: space,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return }
    ctx.setFillColor(CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1))
    ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
    let bronze = [CGColor(srgbRed: 0.78, green: 0.62, blue: 0.36, alpha: 1), CGColor(srgbRed: 0.06, green: 0.045, blue: 0.03, alpha: 1)] as CFArray
    let grad = CGGradient(colorsSpace: space, colors: bronze, locations: [0, 1])!
    // torso
    ctx.saveGState()
    let torso = CGMutablePath()
    torso.move(to: CGPoint(x: 60, y: 0)); torso.addCurve(to: CGPoint(x: 330, y: 640), control1: CGPoint(x: 120, y: 420), control2: CGPoint(x: 200, y: 600))
    torso.addCurve(to: CGPoint(x: 560, y: 640), control1: CGPoint(x: 400, y: 680), control2: CGPoint(x: 500, y: 680))
    torso.addCurve(to: CGPoint(x: 820, y: 0), control1: CGPoint(x: 700, y: 600), control2: CGPoint(x: 780, y: 400))
    torso.closeSubpath()
    ctx.addPath(torso); ctx.clip()
    ctx.drawRadialGradient(grad, startCenter: CGPoint(x: 300, y: 560), startRadius: 40, endCenter: CGPoint(x: 420, y: 300), endRadius: 560, options: [])
    ctx.restoreGState()
    // cloak
    ctx.setFillColor(CGColor(srgbRed: 0.42, green: 0.07, blue: 0.09, alpha: 0.85))
    let cloak = CGMutablePath()
    cloak.move(to: CGPoint(x: 520, y: 640)); cloak.addLine(to: CGPoint(x: 900, y: 0)); cloak.addLine(to: CGPoint(x: 560, y: 0)); cloak.closeSubpath()
    ctx.addPath(cloak); ctx.fillPath()
    // head (+ helmet crest for odd seeds)
    ctx.saveGState()
    let head = CGRect(x: 290 + seed * 10, y: 660, width: 300, height: 390)
    ctx.addEllipse(in: head); ctx.clip()
    ctx.drawRadialGradient(grad, startCenter: CGPoint(x: head.minX + 90, y: head.maxY - 110), startRadius: 10, endCenter: head.origin.applying(.init(translationX: 150, y: 190)), endRadius: 260, options: [])
    ctx.restoreGState()
    if seed % 2 == 1 {
        ctx.setFillColor(CGColor(srgbRed: 0.5, green: 0.09, blue: 0.1, alpha: 0.9))
        ctx.fill(CGRect(x: head.midX - 30, y: head.maxY - 20, width: 60, height: 260))
    }
    guard let image = ctx.makeImage(),
          let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else { return }
    CGImageDestinationAddImage(dest, image, [kCGImageDestinationLossyCompressionQuality: 0.85] as CFDictionary)
    CGImageDestinationFinalize(dest)
}

@MainActor
func render<V: View>(_ view: V, scale: CGFloat = 2, to url: URL) {
    let renderer = ImageRenderer(content: view.environment(\.colorScheme, .dark))
    renderer.scale = scale
    if let image = renderer.cgImage { writePNG(image, to: url) } else { check(false, "render \(url.lastPathComponent)") }
}

var cal = Calendar(identifier: .gregorian)
cal.timeZone = TimeZone(identifier: "Europe/London")!
func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 9, _ minute: Int = 0) -> Date {
    cal.date(from: DateComponents(year: y, month: m, day: d, hour: h, minute: minute))!
}

@MainActor
func run(out: URL) async {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("virtus-selftest-\(UUID().uuidString)")
    defer { try? FileManager.default.removeItem(at: tmp) }

    // Library
    let all = QuoteLibrary.all
    check(all.count >= 366, "library has a quote for every day of the year (\(all.count))")
    check(Set(all.map(\.id)).count == all.count, "every quote id is unique")
    check(Set(all.map { $0.text.lowercased() }).count == all.count, "no quote text repeats")
    check(all.allSatisfy { !$0.text.isEmpty && !$0.author.isEmpty }, "every quote has text and an author")
    check(all.allSatisfy { !$0.text.contains("\"") && !$0.text.hasPrefix("\u{201C}") }, "quote marks are added by the view, not stored")
    check(all.allSatisfy { $0.text.count <= 260 }, "no quote is longer than 260 characters")
    check(Set(all.map(\.author)).count >= 100, "at least 100 different authors (\(Set(all.map(\.author)).count))")
    let bad = all.filter { $0.text.last.map { ".!?\u{2019}".contains($0) } != true }
    check(bad.isEmpty, "every quote ends with punctuation \(bad.prefix(3).map(\.text))")
    check(Quote.makeID("Hello") == Quote.makeID("hello") && Quote.makeID("a") != Quote.makeID("b"), "ids hash the lowercased text")

    // Daily order
    let days = (0..<366).map { DailyQuote.quote(day: $0) }
    check(Set(days.map(\.id)).count == 366, "366 consecutive days give 366 different quotes")
    let repeats = (1..<all.count).filter { DailyQuote.quote(day: $0).author == DailyQuote.quote(day: $0 - 1).author }
    check(repeats.isEmpty, "no author two days running (\(repeats.count) clashes)")
    check(DailyQuote.quote(day: all.count).id == DailyQuote.quote(day: 0).id, "the order wraps after the whole library")
    check(DailyQuote.quote(day: all.count - 1).author != DailyQuote.quote(day: 0).author, "and the wrap does not repeat an author either")
    let wrapped = DailyQuote.order(count: 20, authors: ["x"] + Array(repeating: "y", count: 9) + Array(repeating: "x", count: 10))
    check(Set(wrapped).count == 20, "the wrap fix keeps the order a permutation")
    check(DailyQuote.quote(day: -1).id == DailyQuote.quote(day: all.count - 1).id, "days before the epoch wrap backwards")
    check(DailyQuote.dayNumber(for: date(2026, 1, 1), calendar: cal) == 0, "1 January 2026 is day 0")
    check(DailyQuote.dayNumber(for: date(2026, 10, 15), calendar: cal) == 287, "15 October 2026 is day 287")
    check(DailyQuote.quote(for: date(2026, 10, 15, 0), calendar: cal).id == DailyQuote.quote(for: date(2026, 10, 15, 23), calendar: cal).id,
          "the quote holds all day")
    check(DailyQuote.quote(for: date(2026, 10, 15), calendar: cal).id != DailyQuote.quote(for: date(2026, 10, 16), calendar: cal).id,
          "and changes at midnight")
    let twice = DailyQuote.order(count: 50, authors: (0..<50).map { "a\($0 % 7)" })
    check(twice == DailyQuote.order(count: 50, authors: (0..<50).map { "a\($0 % 7)" }) && Set(twice).count == 50,
          "the order is deterministic and a permutation")

    // Profile store, pins, streak
    let store = SharedStore(root: tmp.appendingPathComponent("group"))
    var now = date(2026, 10, 15)
    var reloads = 0
    var scheduled: [Profile] = []
    let env = VirtusEnvironment(shared: store, now: { now }, calendar: cal,
                                reloadWidgets: { reloads += 1 }, scheduleReminders: { p, _ in scheduled.append(p) })
    let model = AppModel(env: env)
    check(model.profile == Profile(), "fresh install has an empty profile")
    model.start()
    check(model.daysOpened == 1 && model.streak == 1, "first open counts as day 1, streak 1")
    check(scheduled.count == 1, "opening schedules reminders")
    let today = model.today
    check(today.id == DailyQuote.quote(day: 287).id, "today is day 287's quote")
    model.togglePin(today)
    check(model.isPinned(today) && model.featured?.id == today.id, "pinning features the first pin")
    check(reloads == 2 && store.load().pinned == [today.id], "pins are saved to the App Group and reload the widget")
    let other = model.archive(days: 3)[1].quote
    model.pin(other)
    check(model.pinnedQuotes.map(\.id) == [today.id, other.id], "the featured quote stays first")
    model.feature(other)
    check(model.pinnedQuotes.first?.id == other.id, "featuring moves a quote to the top")
    model.unpin(other)
    check(model.featured?.id == today.id && model.pinnedQuotes.count == 1, "unpinning the featured quote features the next one")
    model.pin(other); model.unpin(today); model.unpin(other)
    check(model.featured == nil && model.pinnedQuotes.isEmpty, "unpinning everything clears the feature")
    model.pin(today)
    model.setName("  Marcus Aurelius Antoninus Augustus  ")
    check(model.profile.name.count == VirtusConfig.maxName && model.profile.name.hasPrefix("Marcus Aurelius"), "names are trimmed and capped at \(VirtusConfig.maxName)")
    check(AppModel(env: env).profile == model.profile, "a second launch reads the same profile")

    now = date(2026, 10, 16); model.start()
    now = date(2026, 10, 17); model.start(); model.start()
    check(model.daysOpened == 3 && model.streak == 3, "three days in a row: streak 3, opened 3")
    now = date(2026, 10, 19); 
    check(model.streak == 0, "missing a day ends the streak (seen from two days later)")
    model.start()
    check(model.streak == 1 && model.daysOpened == 4, "and a new one starts")
    now = date(2026, 10, 20)
    check(model.streak == 1, "the streak survives until the end of the next day")
    check(model.secondsToNextDay > 0 && model.secondsToNextDay <= 86_401, "midnight is at most a day away")
    let tick = model.dayTick
    now = date(2026, 10, 21, 0, 0)
    model.dayChanged()
    check(model.dayTick == tick + 1 && model.profile.openedDays.contains(DailyQuote.dayNumber(for: now, calendar: cal)), "a midnight tick counts the new day")
    now = date(2026, 10, 20)
    model.open(url: VirtusLink.quote(other.id))
    check(model.selected?.id == other.id, "a widget link opens its quote")
    model.open(url: VirtusLink.pinned)
    check(model.route == .profile, "virtus://pinned opens the profile")
    check(VirtusLink.quoteID(in: URL(string: "virtus://today")!) == nil, "virtus://today is not a quote link")

    // Archive
    let archive = model.archive(days: 90)
    check(archive.count == 90 && archive.first!.date < now && cal.isDate(archive[0].date, inSameDayAs: date(2026, 10, 19)),
          "the archive lists 90 past days, newest first")
    check(archive[0].quote.id == DailyQuote.quote(for: date(2026, 10, 19), calendar: cal).id, "each day shows the quote it had")

    // Reminders
    model.setReminder(on: true, hour: 7, minute: 30)
    let plan = Reminders.plan(profile: model.profile, now: date(2026, 10, 20, 9), calendar: cal)
    check(plan.count == 7 && plan[0].fire.day == 21 && plan[0].fire.hour == 7 && plan[0].fire.minute == 30,
          "7 reminders, starting tomorrow when today's time has passed")
    check(plan[0].quote.id == DailyQuote.quote(for: date(2026, 10, 21), calendar: cal).id, "each reminder carries its day's quote")
    check(Reminders.plan(profile: model.profile, now: date(2026, 10, 20, 6), calendar: cal)[0].fire.day == 20, "today's reminder is included before its time")
    model.setReminder(on: false, hour: 7, minute: 30)
    check(Reminders.plan(profile: model.profile, now: now, calendar: cal).isEmpty, "off means no reminders")

    // Widget plan
    let todaySlots = WidgetPlan.slots(source: .today, profile: model.profile, now: now, calendar: cal)
    check(todaySlots.count == 4 && todaySlots[0].quote.id == DailyQuote.quote(for: now, calendar: cal).id, "today widget: now plus the next 3 midnights")
    check(todaySlots[1].date == cal.startOfDay(for: date(2026, 10, 21)) && todaySlots[1].quote.id == DailyQuote.quote(day: 293).id,
          "the second entry flips at midnight to tomorrow's quote")
    let pinnedSlots = WidgetPlan.slots(source: .pinned, profile: model.profile, now: now, calendar: cal)
    check(pinnedSlots.count == 24 && pinnedSlots.allSatisfy { $0.quote.id == today.id && $0.hint == nil }, "pinned widget rotates through the pins hourly")
    model.pin(other)
    let two = WidgetPlan.slots(source: .pinned, profile: model.profile, now: now, calendar: cal)
    check(Set(two.map(\.quote.id)) == [today.id, other.id] && two[0].quote.id != two[1].quote.id, "two pins alternate")
    check(two[1].date > two[0].date && cal.component(.minute, from: two[1].date) == 0, "later entries land on the hour")
    let empty = WidgetPlan.slots(source: .pinned, profile: Profile(), now: now, calendar: cal)
    check(empty.count == 1 && empty[0].hint != nil, "no pins: the widget shows a hint")
    check(WidgetPlan.fontSize(for: "short", base: 17, floor: 11) == 17 && WidgetPlan.fontSize(for: String(repeating: "x", count: 220), base: 17, floor: 11) == 11,
          "widget type shrinks for long quotes")

    // Portraits
    check(Portraits.slug(for: "Niccolò Machiavelli") == "niccolo-machiavelli" && Portraits.slug(for: "T. E. Lawrence") == "t-e-lawrence"
          && Portraits.slug(for: "Søren Kierkegaard") == "soren-kierkegaard" && Portraits.slug(for: "Alfred, Lord Tennyson") == "alfred-lord-tennyson"
          && Portraits.slug(for: "George S. Patton") == "george-s-patton", "author slugs: lowercase ascii, dashes, no doubles")
    check(Portraits.image(for: today, maxPixel: 400) == nil && !Portraits.has(today), "no portrait file means text-only")
    let portraits = out.appendingPathComponent("portraits", isDirectory: true)
    try? FileManager.default.createDirectory(at: portraits, withIntermediateDirectories: true)
    for (i, slug) in ["napoleon-bonaparte", "epictetus", "michel-de-montaigne", "marcus-aurelius"].enumerated() {
        makePortrait(seed: i, to: portraits.appendingPathComponent("\(slug).jpg"))
    }
    Portraits.directory = portraits
    check(Portraits.has(today) && today.author == "Napoleon Bonaparte", "a portrait is found by the author's slug")
    let small = Portraits.image(for: today, maxPixel: 400)
    check(small != nil && max(small!.width, small!.height) <= 400, "portraits decode no larger than asked (widgets stay small)")
    check(Portraits.image(for: today, maxPixel: 400) === small, "decoded portraits are cached")
    check(Portraits.image(for: today, maxPixel: 1400).map { max($0.width, $0.height) } == 1350, "and full size for the app")
    let prompt = (try? String(contentsOfFile: "Portraits/PROMPT.md", encoding: .utf8)) ?? ""
    let authors = Set(all.map { Portraits.slug(for: $0.author) })
    let listed = prompt.split(separator: "\n").compactMap { line -> String? in
        guard let first = line.split(separator: " ").first, first.allSatisfy({ $0.isLowercase || $0 == "-" }), first.contains("-") || authors.contains(String(first)) else { return nil }
        return String(first)
    }
    let unknown = listed.filter { !authors.contains($0) }
    check(listed.count >= 40 && unknown.isEmpty, "every file name in PROMPT.md matches an author in the library \(unknown)")

    // Renders
    let long = all.max { $0.text.count < $1.text.count }!
    let samples: [(VirtusWidgetSize, CGSize)] = [(.small, CGSize(width: 170, height: 170)), (.medium, CGSize(width: 364, height: 170)),
                                                 (.large, CGSize(width: 364, height: 382))]
    let sheet = VStack(alignment: .leading, spacing: 24) {
        ForEach([today, long, other], id: \.id) { q in
            HStack(alignment: .top, spacing: 24) {
                ForEach(samples.indices, id: \.self) { i in
                    VirtusWidgetContent(slot: WidgetSlot(date: now, quote: q), size: samples[i].0, pinned: q.id == today.id)
                        .frame(width: samples[i].1.width, height: samples[i].1.height)
                        .background(VirtusPalette.black)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
            }
        }
        HStack(spacing: 24) {
            VirtusWidgetContent(slot: empty[0], size: .small, pinned: false)
                .frame(width: 170, height: 170).background(VirtusPalette.black)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            VirtusWidgetContent(slot: WidgetSlot(date: now, quote: today), size: .rectangular, pinned: false)
                .frame(width: 172, height: 72).foregroundStyle(.white)
            VirtusWidgetContent(slot: WidgetSlot(date: now, quote: today), size: .circular, pinned: false)
                .frame(width: 72, height: 72).foregroundStyle(.white)
        }
    }
    .padding(24)
    .background(Color(rgb: 0x4B5563))
    render(sheet, to: out.appendingPathComponent("widgets.png"))
    render(ShareCard(quote: today), scale: 0.5, to: out.appendingPathComponent("share.png"))
    let stacked = all.first { $0.author == "Epictetus" && $0.text.count > 150 }!
    render(ShareCard(quote: stacked), scale: 0.5, to: out.appendingPathComponent("share-long.png"))
    render(AppIconArt().frame(width: 1024, height: 1024), scale: 1, to: out.appendingPathComponent("AppIcon.png"))

    print(failures == 0 ? "SELFTEST PASSED" : "SELFTEST FAILED (\(failures))")
    exit(failures == 0 ? 0 : 1)
}

let out = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "build/selftest")
try? FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
await run(out: out)
