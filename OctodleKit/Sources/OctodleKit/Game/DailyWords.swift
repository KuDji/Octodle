import Foundation

public enum GameDay {
    /// Day #1 on octordle.ru is 19613 days after the Unix epoch (UTC).
    static let epochDayOffset = 19612

    public static func number(for date: Date = .now) -> Int {
        Int((date.timeIntervalSince1970 / 86_400).rounded(.down)) - epochDayOffset
    }

    public static func secondsUntilNextDay(from date: Date = .now) -> Int {
        let seconds = Int(date.timeIntervalSince1970)
        return (seconds / 86_400 + 1) * 86_400 - seconds
    }
}

/// Port of the mulberry32 PRNG used by octordle.ru to pick the daily words.
struct Mulberry32 {
    private var state: UInt32

    init(seed: Int) {
        state = UInt32(truncatingIfNeeded: seed)
    }

    mutating func next() -> Double {
        state &+= 1_831_565_813
        var t = state
        t = (t ^ (t >> 15)) &* (t | 1)
        t ^= t &+ ((t ^ (t >> 7)) &* (t | 61))
        return Double(t ^ (t >> 14)) / 4_294_967_296
    }
}

public enum DailyWords {
    public static let boardCount = 8

    public static func words(
        day: Int,
        mode: GameMode,
        count: Int = boardCount,
        wordList: WordList = .bundled
    ) -> [String] {
        let pool = wordList.answerPool(for: mode)
        var random = Mulberry32(seed: day)
        return (0..<count).map { _ in pool[Int(random.next() * Double(pool.count))] }
    }
}
