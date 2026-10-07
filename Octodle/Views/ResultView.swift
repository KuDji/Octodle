import OctodleKit
import SwiftUI

struct ResultView: View {
    let result: GameResult
    let betterThan: Int?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(result.answers.indices, id: \.self) { index in
                    HStack {
                        Text(result.tryEmojis[index])
                        Text(result.answers[index].uppercased())
                            .font(.headline.monospaced())
                            .foregroundStyle(result.tryNumbers[index] == 0 ? Palette.present : .white)
                        Spacer(minLength: 0)
                    }
                }
            }

            Text("Счет: " + result.points.map(String.init).joined(separator: "+") + " = \(result.score) \(result.mood)")
                .font(.headline)

            if let betterThan {
                Text("Ваш результат лучше, чем у \(betterThan)% игроков")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TimelineView(.periodic(from: .now, by: 1)) { context in
                Text("Следующая игра через \(Self.format(GameDay.secondsUntilNextDay(from: context.date)))")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            ShareLink(item: result.shareText(betterThan: betterThan)) {
                Label("Поделиться результатом", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }

    private static func format(_ seconds: Int) -> String {
        String(format: "%02d:%02d:%02d", seconds / 3600, seconds % 3600 / 60, seconds % 60)
    }
}
