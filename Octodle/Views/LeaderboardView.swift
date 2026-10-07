import OctodleKit
import SwiftUI

struct LeaderboardView: View {
    let api: OctordleAPI

    @State private var day = GameDay.number()
    @State private var board: LeaderBoardResponse?
    @State private var error: String?

    var body: some View {
        List {
            if let error {
                Text(error).foregroundStyle(.red)
            }
            if let board {
                ForEach(Array(board.leaderBoard.enumerated()), id: \.offset) { place, entry in
                    HStack {
                        Text("\(place + 1).").monospacedDigit().foregroundStyle(.secondary)
                        VStack(alignment: .leading) {
                            Text(entry.name).font(.headline)
                            Text(entry.tries).font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(entry.score)").font(.headline.monospacedDigit())
                    }
                }
            } else if error == nil {
                ProgressView()
            }
        }
        .navigationTitle("Рейтинг #\(day)")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button { day -= 1 } label: { Image(systemName: "chevron.left") }
                Button { day += 1 } label: { Image(systemName: "chevron.right") }
                    .disabled(day >= GameDay.number())
            }
        }
        .task(id: day) { await load() }
        .refreshable { await load() }
    }

    private func load() async {
        do {
            board = try await api.leaderBoard(day: day)
            error = nil
        } catch {
            self.error = "Не удалось загрузить рейтинг"
        }
    }
}
