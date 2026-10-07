public enum GameMode: String, Codable, Sendable, CaseIterable {
    /// Raw values match the `mode` field sent to octordle.ru.
    case standard = ""
    case sogra
}
