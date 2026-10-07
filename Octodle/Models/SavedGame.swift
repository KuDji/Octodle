import Foundation
import OctodleKit
import SwiftData

/// Progress of one daily game; survives app restarts.
@Model
final class SavedGame {
    @Attribute(.unique) var key: String
    var day: Int
    var modeRaw: String
    var tries: [String]
    var startSent: Bool
    var resultSent: Bool
    var betterThan: Int?
    var updatedAt: Date

    init(day: Int, mode: GameMode) {
        key = Self.key(day: day, mode: mode)
        self.day = day
        modeRaw = mode.rawValue
        tries = []
        startSent = false
        resultSent = false
        updatedAt = .now
    }

    var mode: GameMode { GameMode(rawValue: modeRaw) ?? .standard }

    static func key(day: Int, mode: GameMode) -> String {
        "\(mode == .sogra ? "sogra" : "standard")-\(day)"
    }
}

/// Anonymous device identity sent to octordle.ru as `uuid`.
@Model
final class PlayerProfile {
    var uuid: String
    var name: String?
    var email: String?

    init(uuid: String = UUID().uuidString.lowercased()) {
        self.uuid = uuid
    }
}
