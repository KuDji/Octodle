public struct BoardRow: Sendable, Equatable {
    public let word: String
    public let states: [LetterState]
}

public struct GameState: Sendable, Equatable {
    public static let maxTries = 14
    public static let wordLength = 5

    public let day: Int
    public let mode: GameMode
    public let answers: [String]
    public private(set) var tries: [String]

    public init(day: Int, mode: GameMode, answers: [String], tries: [String] = []) {
        self.day = day
        self.mode = mode
        self.answers = answers
        self.tries = tries
    }

    public init(day: Int, mode: GameMode, tries: [String] = [], wordList: WordList = .bundled) {
        self.init(day: day, mode: mode, answers: DailyWords.words(day: day, mode: mode, wordList: wordList), tries: tries)
    }

    public var isWon: Bool { answers.allSatisfy(tries.contains) }
    public var isFinished: Bool { isWon || tries.count >= Self.maxTries }

    /// 1-based try number on which each answer was guessed, 0 if not guessed.
    public var tryNumbers: [Int] {
        answers.map { answer in tries.firstIndex(of: answer).map { $0 + 1 } ?? 0 }
    }

    public func isSolved(board: Int) -> Bool {
        tries.contains(answers[board])
    }

    /// Rows shown on a board: every try up to and including the one that solved it.
    public func rows(board: Int) -> [BoardRow] {
        let answer = answers[board]
        let visible = tries.firstIndex(of: answer).map { Array(tries[...$0]) } ?? tries
        return visible.map { BoardRow(word: $0, states: Evaluation.evaluate(guess: $0, answer: answer)) }
    }

    public enum SubmitError: Error, Equatable {
        case finished
        case tooShort
        case notInDictionary
    }

    public mutating func submit(_ word: String, wordList: WordList = .bundled) throws(SubmitError) {
        guard !isFinished else { throw .finished }
        guard word.count == Self.wordLength else { throw .tooShort }
        guard wordList.isValid(word) else { throw .notInDictionary }
        tries.append(word)
    }

    /// Per-letter hints for the custom keyboard.
    /// With a selected board the key gets one colour for that board, otherwise one colour per board
    /// (`nil` for already solved boards and letters not yet tried).
    public func keyboardHints(selectedBoard: Int? = nil) -> [Character: [LetterState?]] {
        let boards = selectedBoard.map { [$0] } ?? Array(answers.indices)
        var hints: [Character: [LetterState?]] = [:]
        for (slot, board) in boards.enumerated() {
            if selectedBoard == nil && isSolved(board: board) { continue }
            let answer = Array(answers[board])
            for word in tries {
                for (i, letter) in word.enumerated() {
                    var states = hints[letter] ?? Array(repeating: nil, count: boards.count)
                    let state: LetterState = answer[i] == letter ? .correct : answer.contains(letter) ? .present : .absent
                    states[slot] = Self.best(states[slot], state)
                    hints[letter] = states
                }
            }
        }
        return hints
    }

    private static func best(_ current: LetterState?, _ new: LetterState) -> LetterState {
        switch (current, new) {
        case (.correct, _), (_, .correct): .correct
        case (.present, _), (_, .present): .present
        default: .absent
        }
    }
}
