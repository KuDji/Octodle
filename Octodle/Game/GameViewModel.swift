import Foundation
import Observation
import OctodleKit
import SwiftData

@MainActor
@Observable
final class GameViewModel {
    private(set) var state: GameState
    private(set) var input = ""
    private(set) var toast: String?
    private(set) var betterThan: Int?
    var selectedBoard: Int?
    var mode: GameMode {
        didSet { if oldValue != mode { load() } }
    }

    let api: OctordleAPI
    let profile: PlayerProfile
    private let context: ModelContext
    private var saved: SavedGame
    private var toastTask: Task<Void, Never>?

    init(context: ModelContext, api: OctordleAPI = OctordleAPI(), mode: GameMode = .standard) {
        self.context = context
        self.api = api
        self.mode = mode
        profile = Self.fetchProfile(in: context)
        let day = GameDay.number()
        saved = Self.fetchGame(day: day, mode: mode, in: context)
        state = GameState(day: day, mode: mode, tries: saved.tries)
        betterThan = saved.betterThan
        reportResultIfNeeded()
    }

    var keyboardHints: [Character: [LetterState?]] {
        state.keyboardHints(selectedBoard: selectedBoard)
    }

    var result: GameResult? {
        state.isFinished ? GameResult(state) : nil
    }

    // MARK: - Input

    func type(_ letter: Character) {
        guard !state.isFinished, input.count < GameState.wordLength else { return }
        input.append(letter)
    }

    func deleteLetter() {
        guard !input.isEmpty else { return }
        input.removeLast()
    }

    func submit() {
        let word = input
        do {
            try state.submit(word)
        } catch {
            show(message(for: error))
            return
        }
        input = ""
        if let board = selectedBoard, state.isSolved(board: board) { selectedBoard = nil }

        saved.tries = state.tries
        saved.updatedAt = .now
        try? context.save()

        if state.tries.count == 1 {
            let payload = StartPayload(day: state.day, word: word, uuid: profile.uuid)
            Task { await sendStart(payload) }
        }
        reportResultIfNeeded()
    }

    func toggleSelection(board: Int) {
        guard !state.isSolved(board: board) else { return }
        selectedBoard = selectedBoard == board ? nil : board
    }

    /// Switches to the new daily game after midnight UTC.
    func refreshDay() {
        if GameDay.number() != state.day { load() }
    }

    // MARK: - Private

    private func load() {
        let day = GameDay.number()
        saved = Self.fetchGame(day: day, mode: mode, in: context)
        state = GameState(day: day, mode: mode, tries: saved.tries)
        betterThan = saved.betterThan
        input = ""
        selectedBoard = nil
        reportResultIfNeeded()
    }

    private func reportResultIfNeeded() {
        guard state.isFinished, saved.betterThan == nil else { return }
        let payload = GameResult(state).payload(uuid: profile.uuid)
        Task { await reportResult(payload, for: saved) }
    }

    private func sendStart(_ payload: StartPayload) async {
        guard !saved.startSent else { return }
        do {
            try await api.postStart(payload)
            saved.startSent = true
            try? context.save()
        } catch {
            // Analytics only; the game works offline.
        }
    }

    private func reportResult(_ payload: GamePayload, for game: SavedGame) async {
        do {
            let response = game.resultSent ? try await api.gameStat(payload) : try await api.postGame(payload)
            game.resultSent = true
            if response.betterThan >= 0 { game.betterThan = Int(response.betterThan.rounded()) }
            try? context.save()
            if game === saved { betterThan = game.betterThan }
        } catch {
            show("Не удалось отправить результат")
        }
    }

    private func show(_ message: String) {
        toast = message
        toastTask?.cancel()
        toastTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            toast = nil
        }
    }

    private func message(for error: GameState.SubmitError) -> String {
        switch error {
        case .finished: "Игра окончена"
        case .tooShort: "Слово должно быть из 5 букв"
        case .notInDictionary: "Такого слова нет в словаре"
        }
    }

    private static func fetchGame(day: Int, mode: GameMode, in context: ModelContext) -> SavedGame {
        let key = SavedGame.key(day: day, mode: mode)
        let descriptor = FetchDescriptor<SavedGame>(predicate: #Predicate { $0.key == key })
        if let game = try? context.fetch(descriptor).first { return game }
        let game = SavedGame(day: day, mode: mode)
        context.insert(game)
        try? context.save()
        return game
    }

    private static func fetchProfile(in context: ModelContext) -> PlayerProfile {
        if let profile = try? context.fetch(FetchDescriptor<PlayerProfile>()).first { return profile }
        let profile = PlayerProfile()
        context.insert(profile)
        try? context.save()
        return profile
    }
}
