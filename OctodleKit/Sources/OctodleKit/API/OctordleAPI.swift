import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol HTTPTransport: Sendable {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

public struct URLSessionTransport: HTTPTransport, @unchecked Sendable {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw OctordleAPIError.invalidResponse }
        return (data, http)
    }
}

public enum OctordleAPIError: Error, Equatable {
    case invalidResponse
    case status(Int, String)
}

/// Client for the octordle.ru backend; mirrors the requests made by the web client.
public struct OctordleAPI: Sendable {
    public static let defaultBaseURL = URL(string: "https://octordle.ru/api")!

    private let baseURL: URL
    private let transport: HTTPTransport

    public init(baseURL: URL = defaultBaseURL, transport: HTTPTransport = URLSessionTransport()) {
        self.baseURL = baseURL
        self.transport = transport
    }

    public func postStart(_ payload: StartPayload) async throws {
        _ = try await send(path: "post_start", method: "POST", body: payload)
    }

    public func postGame(_ payload: GamePayload) async throws -> BetterThanResponse {
        try decode(await send(path: "post_game", method: "POST", body: payload))
    }

    /// Used instead of `postGame` when the result was already sent.
    public func gameStat(_ payload: GamePayload) async throws -> BetterThanResponse {
        let json = String(decoding: try JSONEncoder.sorted.encode(payload), as: UTF8.self)
        return try decode(await send(path: "get_game_stat", query: ["game": json]))
    }

    public func fullStat(uuid: String, email: String? = nil) async throws -> FullStatResponse {
        try decode(await send(path: "get_full_stat", query: ["uuid": uuid, "email": email]))
    }

    public func leaderBoard(day: Int, email: String? = nil) async throws -> LeaderBoardResponse {
        try decode(await send(path: "get_leader_board", query: ["day": String(day), "email": email]))
    }

    /// `number` 0 is today's news, higher numbers go back in time.
    public func dayNews(number: Int = 0) async throws -> DayNewsResponse {
        try decode(await send(path: "get_day_news", query: ["news_number": String(number)]))
    }

    public func markNewsWatched(uuid: String) async throws {
        _ = try await send(path: "post_watched_news", method: "POST", query: ["uuid": uuid])
    }

    /// Links the device `uuid` to an account after Google OAuth sign-in.
    public func login(uuid: String, email: String, name: String) async throws {
        _ = try await send(path: "login", method: "POST", query: ["uuid": uuid, "email": email, "name": name])
    }

    public func sendWordOffer(action: WordOfferAction, word: String, userName: String) async throws {
        struct Body: Encodable { let action: String, word: String, userName: String }
        _ = try await send(
            path: "send_word_offer",
            method: "POST",
            body: Body(action: action.rawValue, word: word, userName: userName)
        )
    }

    // MARK: - Plumbing

    private struct NoBody: Encodable {}

    private func send(
        path: String,
        method: String = "GET",
        query: KeyValuePairs<String, String?> = [:],
        body: (some Encodable)? = NoBody?.none
    ) async throws -> Data {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        let items = query.compactMap { key, value in value.map { URLQueryItem(name: key, value: $0) } }
        if !items.isEmpty { components.queryItems = items }

        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        if let body {
            request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder.sorted.encode(body)
        }

        let (data, response) = try await transport.send(request)
        guard (200..<300).contains(response.statusCode) else {
            throw OctordleAPIError.status(response.statusCode, String(decoding: data, as: UTF8.self))
        }
        return data
    }

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        try JSONDecoder().decode(T.self, from: data)
    }
}

extension JSONEncoder {
    static let sorted: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return encoder
    }()
}
