public struct GameResult: Sendable, Equatable {
    public let day: Int
    public let mode: GameMode
    public let answers: [String]
    public let tryNumbers: [Int]

    public init(day: Int, mode: GameMode, answers: [String], tryNumbers: [Int]) {
        self.day = day
        self.mode = mode
        self.answers = answers
        self.tryNumbers = tryNumbers
    }

    public init(_ state: GameState) {
        self.init(day: state.day, mode: state.mode, answers: state.answers, tryNumbers: state.tryNumbers)
    }

    private static let tryEmoji = ["1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣", "6️⃣", "7️⃣", "8️⃣", "9️⃣", "🔟", "🕚", "🕛", "🕐", "🕑", "🕒"]

    public var points: [Int] { tryNumbers.map { $0 == 0 ? 0 : 20 - $0 } }
    public var score: Int { points.reduce(0, +) }

    public var tryEmojis: [String] {
        tryNumbers.map { $0 >= 1 && $0 <= Self.tryEmoji.count ? Self.tryEmoji[$0 - 1] : "🟥" }
    }

    public var mood: String {
        if tryNumbers.contains(1) { return "😑" }
        if tryNumbers.allSatisfy({ $0 != 0 && $0 <= 10 }) { return "🤯" }
        switch score {
        case 90...: return "😎"
        case 70...: return "😊"
        case 50...: return "🙂"
        default: return "😶"
        }
    }

    /// Same format as the "копировать результат" button on octordle.ru.
    public func shareText(betterThan: Int? = nil) -> String {
        var text = mode == .sogra ? "sogra mode #\(day):" : "octordle▪️ru #\(day):"
        for (i, emoji) in tryEmojis.enumerated() {
            if i % 2 == 0 { text += "\n" }
            text += emoji + " "
        }
        text += "\nСчет: \(score) \(mood)"
        if let betterThan { text += "\nКруче \(betterThan)% игроков" }
        return text
    }

    public func payload(uuid: String) -> GamePayload {
        GamePayload(
            day: day,
            words: answers.joined(separator: " "),
            tries: tryNumbers.map(String.init).joined(separator: " "),
            score: score,
            uuid: uuid,
            mode: mode.rawValue
        )
    }
}
