import Foundation

/// Dictionary bundled with the octordle.ru client (`easyWords`, `hardWords`, `badWords`).
public struct WordList: Sendable {
    public let easy: [String]
    public let hard: [String]
    public let bad: [String]

    private let valid: Set<String>
    private let hardSet: Set<String>
    private let badSet: Set<String>

    public init(easy: [String], hard: [String], bad: [String]) {
        self.easy = easy
        self.hard = hard
        self.bad = bad
        valid = Set(easy + hard + bad)
        hardSet = Set(hard)
        badSet = Set(bad)
    }

    public static let bundled: WordList = {
        guard let url = Bundle.module.url(forResource: "words", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let raw = try? JSONDecoder().decode(Raw.self, from: data)
        else { fatalError("words.json is missing from OctodleKit resources") }
        return WordList(easy: raw.easyWords, hard: raw.hardWords, bad: raw.badWords)
    }()

    public func answerPool(for mode: GameMode) -> [String] {
        mode == .sogra ? easy + hard : easy
    }

    public func isValid(_ word: String) -> Bool {
        valid.contains(word)
    }

    /// Words highlighted when the "highlight hard words" setting is on.
    public func isHard(_ word: String, mode: GameMode) -> Bool {
        mode == .sogra ? badSet.contains(word) : hardSet.contains(word) || badSet.contains(word)
    }

    private struct Raw: Decodable {
        let easyWords: [String]
        let hardWords: [String]
        let badWords: [String]
    }
}
