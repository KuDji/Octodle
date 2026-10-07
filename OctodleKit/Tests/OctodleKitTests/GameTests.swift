import Foundation
import Testing
@testable import OctodleKit

@Suite struct DailyWordsTests {
    @Test func dayNumberMatchesSite() {
        // 2026-10-07 is day #1121 on octordle.ru
        let date = ISO8601DateFormatter().date(from: "2026-10-07T12:00:00Z")!
        #expect(GameDay.number(for: date) == 1121)
    }

    @Test func wordsMatchSiteForDay1121() {
        #expect(DailyWords.words(day: 1121, mode: .standard) ==
            ["клерк", "кредо", "опека", "ирбис", "кулон", "скука", "пицца", "брошь"])
        #expect(DailyWords.words(day: 1121, mode: .sogra) ==
            ["сфера", "устье", "дутик", "рулон", "хворь", "пироп", "краги", "грунт"])
        #expect(DailyWords.words(day: 1, mode: .standard) ==
            ["покер", "авеню", "окрас", "шутка", "шпага", "излом", "пласт", "садик"])
    }

    @Test func dictionary() {
        let words = WordList.bundled
        #expect(words.isValid("клерк"))
        #expect(!words.isValid("ыыыыы"))
        #expect(words.isHard("абака", mode: .standard))
        #expect(!words.isHard("абака", mode: .sogra))
    }
}

@Suite struct EvaluationTests {
    @Test func repeatedLetters() {
        #expect(Evaluation.evaluate(guess: "кошка", answer: "кукла") ==
            [.correct, .absent, .absent, .present, .correct])
        #expect(Evaluation.evaluate(guess: "ааааб", answer: "бочка") ==
            [.present, .absent, .absent, .absent, .present])
    }
}

@Suite struct GameStateTests {
    let answers = ["клерк", "кредо"]

    @Test func boardStopsAfterSolved() throws {
        var state = GameState(day: 1, mode: .standard, answers: answers)
        try state.submit("клерк")
        try state.submit("рента")
        #expect(state.rows(board: 0).count == 1)
        #expect(state.rows(board: 1).count == 2)
        #expect(state.tryNumbers == [1, 0])
    }

    @Test func rejectsInvalidWords() {
        var state = GameState(day: 1, mode: .standard, answers: answers)
        #expect(throws: GameState.SubmitError.tooShort) { try state.submit("кот") }
        #expect(throws: GameState.SubmitError.notInDictionary) { try state.submit("ыыыыы") }
    }

    @Test func finishesWhenWonOrOutOfTries() throws {
        var state = GameState(day: 1, mode: .standard, answers: answers)
        try state.submit("клерк")
        try state.submit("кредо")
        #expect(state.isWon && state.isFinished)
        #expect(throws: GameState.SubmitError.finished) { try state.submit("рента") }
    }

    @Test func keyboardHints() throws {
        var state = GameState(day: 1, mode: .standard, answers: answers)
        try state.submit("крона")
        let hints = state.keyboardHints()
        #expect(hints["к"] == [.correct, .correct])
        #expect(hints["р"] == [.present, .correct])
        #expect(hints["н"] == [.absent, .absent])
        #expect(hints["е"] == nil)
        #expect(state.keyboardHints(selectedBoard: 1)["о"] == [.present])

        try state.submit("клерк")
        #expect(state.keyboardHints()["р"] == [nil, .correct])
    }
}

@Suite struct GameResultTests {
    @Test func scoreAndShareTextMatchSite() {
        let result = GameResult(
            day: 1121,
            mode: .standard,
            answers: ["клерк", "кредо", "опека", "ирбис", "кулон", "скука", "пицца", "брошь"],
            tryNumbers: [6, 7, 5, 9, 3, 4, 8, 11]
        )
        #expect(result.points == [14, 13, 15, 11, 17, 16, 12, 9])
        #expect(result.score == 107)
        #expect(result.mood == "😎")
        #expect(result.shareText(betterThan: 88) ==
            "octordle▪️ru #1121:\n6️⃣ 7️⃣ \n5️⃣ 9️⃣ \n3️⃣ 4️⃣ \n8️⃣ 🕚 \nСчет: 107 😎\nКруче 88% игроков")
    }

    @Test func unsolvedWordsScoreZero() {
        let result = GameResult(day: 1, mode: .sogra, answers: ["а", "б"], tryNumbers: [3, 0])
        #expect(result.score == 17)
        #expect(result.tryEmojis == ["3️⃣", "🟥"])
        #expect(result.payload(uuid: "u").tries == "3 0")
    }
}
