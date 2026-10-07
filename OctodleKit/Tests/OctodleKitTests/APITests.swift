import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
@testable import OctodleKit

final class MockTransport: HTTPTransport, @unchecked Sendable {
    var requests: [URLRequest] = []
    let response: String

    init(response: String) {
        self.response = response
    }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        requests.append(request)
        let http = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (Data(response.utf8), http)
    }
}

@Suite struct APITests {
    @Test func leaderBoardRequest() async throws {
        let transport = MockTransport(response: """
        {"currentDay":1121,"day":1121,"leaderBoard":[{"name":"Тарас","score":112,"users":false,"allWords":true,"tries":"3 2 5 9 4 8 10 7","mode":""}]}
        """)
        let board = try await OctordleAPI(transport: transport).leaderBoard(day: 1121)
        #expect(board.leaderBoard.first?.score == 112)
        #expect(transport.requests.first?.url?.absoluteString == "https://octordle.ru/api/get_leader_board?day=1121")
    }

    @Test func postGameSendsJSONBody() async throws {
        let transport = MockTransport(response: #"{"betterThan":88}"#)
        let payload = GameResult(day: 1121, mode: .standard, answers: ["клерк", "кредо"], tryNumbers: [6, 7])
            .payload(uuid: "abc")
        let response = try await OctordleAPI(transport: transport).postGame(payload)
        #expect(response.betterThan == 88)

        let request = try #require(transport.requests.first)
        #expect(request.httpMethod == "POST")
        #expect(request.url?.absoluteString == "https://octordle.ru/api/post_game")
        let body = try JSONDecoder().decode(GamePayload.self, from: try #require(request.httpBody))
        #expect(body == payload)
        #expect(body.words == "клерк кредо" && body.tries == "6 7" && body.score == 27 && body.mode == "")
    }

    @Test func decodesFullStat() async throws {
        let transport = MockTransport(response: """
        {"currentDay":1121,"today":{"starts":127,"finish":102,"average":98.37,"max":112,"min":63,"median":100},
         "yesterday":{"starts":135,"finish":126,"average":95.35,"max":108,"min":62,"median":97},
         "personal":{"standart":{"count":0,"average":null,"scores":[]},"sogra":{"count":0,"average":null,"scores":[]}},
         "leaderBoardDay":1121,"leaderBoard":[]}
        """)
        let stat = try await OctordleAPI(transport: transport).fullStat(uuid: "u", email: nil)
        #expect(stat.today.finish == 102)
        #expect(transport.requests.first?.url?.query == "uuid=u")
    }
}
