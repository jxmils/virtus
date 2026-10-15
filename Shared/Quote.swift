import Foundation

/// One quotation. The id is a hash of the text, so pins survive reordering or adding to the library.
struct Quote: Identifiable, Hashable, Codable {
    var id: String
    var text: String
    var author: String
    var source: String

    init(_ text: String, _ author: String, _ source: String = "") {
        self.text = text
        self.author = author
        self.source = source
        self.id = Quote.makeID(text)
    }

    /// FNV-1a over the lowercased text, as 16 hex digits.
    static func makeID(_ text: String) -> String {
        var h: UInt64 = 0xcbf29ce484222325
        for byte in text.lowercased().utf8 {
            h ^= UInt64(byte)
            h = h &* 0x100000001b3
        }
        return String(format: "%016llx", h)
    }
}

enum QuoteLibrary {
    static let all: [Quote] = QuoteData.stoics + QuoteData.warriors + QuoteData.kings + QuoteData.philosophers
        + QuoteData.strategists + QuoteData.moderns

    static let byID: [String: Quote] = Dictionary(all.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })

    static func quote(id: String) -> Quote? { byID[id] }
}

/// Which quote belongs to which day. Everyone sees the same quote on the same day, the order is a fixed
/// shuffle of the library, and two days in a row never share an author.
enum DailyQuote {
    /// Day 0. Days are counted in the user's calendar, so the quote changes at local midnight.
    static let epoch: Date = {
        var c = DateComponents(); c.year = 2026; c.month = 1; c.day = 1
        return Calendar(identifier: .gregorian).date(from: c)!
    }()

    static func dayNumber(for date: Date, calendar: Calendar = .autoupdatingCurrent) -> Int {
        let a = calendar.startOfDay(for: epoch)
        let b = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: a, to: b).day ?? 0
    }

    static func quote(for date: Date, calendar: Calendar = .autoupdatingCurrent, library: [Quote] = QuoteLibrary.all) -> Quote {
        quote(day: dayNumber(for: date, calendar: calendar), library: library)
    }

    static func quote(day: Int, library: [Quote] = QuoteLibrary.all) -> Quote {
        let order = library.count == QuoteLibrary.all.count ? cachedOrder : order(count: library.count, authors: library.map(\.author))
        let n = library.count
        let i = ((day % n) + n) % n
        return library[order[i]]
    }

    private static let cachedOrder: [Int] = order(count: QuoteLibrary.all.count, authors: QuoteLibrary.all.map(\.author))

    /// A fixed permutation: seeded Fisher-Yates, then neighbours with the same author are pushed apart.
    static func order(count: Int, authors: [String], seed: UInt64 = 0x5EED_0F_B1A7_0C01) -> [Int] {
        guard count > 1 else { return Array(0..<count) }
        var rng = SplitMix64(seed: seed)
        var order = Array(0..<count)
        for i in stride(from: count - 1, to: 0, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            order.swapAt(i, j)
        }
        for i in 1..<count where authors[order[i]] == authors[order[i - 1]] {
            // Find the next index whose author differs from both neighbours and swap it in.
            for j in (i + 1)..<(count + i) {
                let k = j % count
                guard k != i, k != i - 1 else { continue }
                let left = authors[order[(k - 1 + count) % count]], right = authors[order[(k + 1) % count]]
                let a = authors[order[k]], b = authors[order[i]]
                if a != authors[order[i - 1]], (i + 1 >= count || a != authors[order[i + 1]]),
                   b != left, b != right {
                    order.swapAt(i, k)
                    break
                }
            }
        }
        return order
    }
}

/// Small deterministic generator so the daily order is the same on every device.
struct SplitMix64 {
    var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
