public struct StartPayload: Codable, Sendable, Equatable {
    public let day: Int
    /// First word entered by the player.
    public let word: String
    public let uuid: String

    public init(day: Int, word: String, uuid: String) {
        self.day = day
        self.word = word
        self.uuid = uuid
    }
}

/// Body of `post_game` and the `game` query of `get_game_stat`.
public struct GamePayload: Codable, Sendable, Equatable {
    public let day: Int
    /// Answers separated by spaces.
    public let words: String
    /// 1-based try numbers per answer separated by spaces, 0 if not guessed.
    public let tries: String
    public let score: Int
    public let uuid: String
    public let mode: String
}

public struct BetterThanResponse: Decodable, Sendable, Equatable {
    /// Percentage of players with a worse result, -1 if unknown.
    public let betterThan: Double
}

public struct LeaderBoardEntry: Decodable, Sendable, Equatable, Identifiable {
    public var id: String { "\(name)|\(tries)|\(mode)" }
    public let name: String
    public let score: Int
    public let users: Bool
    public let allWords: Bool
    public let tries: String
    public let mode: String
}

public struct LeaderBoardResponse: Decodable, Sendable, Equatable {
    public let currentDay: Int
    public let day: Int
    public let leaderBoard: [LeaderBoardEntry]
}

public struct DayStat: Decodable, Sendable, Equatable {
    public let starts: Int
    public let finish: Int
    public let average: Double?
    public let max: Int?
    public let min: Int?
    public let median: Double?
}

public struct PersonalStat: Decodable, Sendable, Equatable {
    public let count: Int
    public let average: Double?
}

public struct PersonalStats: Decodable, Sendable, Equatable {
    public let standart: PersonalStat
    public let sogra: PersonalStat
}

public struct FullStatResponse: Decodable, Sendable, Equatable {
    public let currentDay: Int
    public let today: DayStat
    public let yesterday: DayStat
    public let personal: PersonalStats
    public let leaderBoardDay: Int
    public let leaderBoard: [LeaderBoardEntry]
}

public struct DayNews: Decodable, Sendable, Equatable {
    public let date: String
    public let text: String
}

public struct DayNewsResponse: Decodable, Sendable, Equatable {
    public let haveNext: Bool
    public let news: DayNews?
}

public enum WordOfferAction: String, Codable, Sendable {
    case add
    case remove
}
