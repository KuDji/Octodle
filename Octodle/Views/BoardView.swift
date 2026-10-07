import OctodleKit
import SwiftUI

struct BoardView: View {
    let rows: [BoardRow]
    let input: String
    let isSolved: Bool
    let isFinished: Bool
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<GameState.maxTries, id: \.self) { index in
                HStack(spacing: 2) {
                    ForEach(0..<GameState.wordLength, id: \.self) { column in
                        tile(row: index, column: column)
                    }
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.white : .clear, lineWidth: 2)
        )
        .opacity(isSolved ? 0.75 : 1)
        .contentShape(Rectangle())
    }

    private func tile(row: Int, column: Int) -> some View {
        let (letter, color) = content(row: row, column: column)
        return RoundedRectangle(cornerRadius: 3)
            .fill(color)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let letter {
                    Text(String(letter).uppercased())
                        .font(.system(size: 14, weight: .bold))
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(.white)
                }
            }
    }

    private func content(row: Int, column: Int) -> (Character?, Color) {
        if row < rows.count {
            return (Array(rows[row].word)[column], Palette.color(for: rows[row].states[column]))
        }
        if row == rows.count, !isSolved, !isFinished {
            let typed = Array(input)
            return (column < typed.count ? typed[column] : nil, Palette.inputTile)
        }
        return (nil, Palette.emptyTile)
    }
}
