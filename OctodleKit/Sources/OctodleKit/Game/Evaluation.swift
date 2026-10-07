public enum LetterState: Sendable, Equatable {
    case correct
    case present
    case absent
}

public enum Evaluation {
    /// Wordle-style colouring with correct handling of repeated letters.
    public static func evaluate(guess: String, answer: String) -> [LetterState] {
        let guessLetters = Array(guess)
        let answerLetters = Array(answer)
        var remaining: [Character: Int] = [:]
        answerLetters.forEach { remaining[$0, default: 0] += 1 }

        var result = [LetterState](repeating: .absent, count: guessLetters.count)
        for (i, letter) in guessLetters.enumerated() where i < answerLetters.count && letter == answerLetters[i] {
            result[i] = .correct
            remaining[letter, default: 0] -= 1
        }
        for (i, letter) in guessLetters.enumerated() where result[i] != .correct {
            if remaining[letter, default: 0] > 0 {
                result[i] = .present
                remaining[letter, default: 0] -= 1
            }
        }
        return result
    }
}
