import OctodleKit
import SwiftUI

/// Russian on-screen keyboard; each key shows a hint per board (or for the selected board).
struct KeyboardView: View {
    static let rows: [[Character]] = [Array("йцукенгшщзхъ"), Array("фывапролджэ"), Array("ячсмитьбю")]
    static let letters = Set(rows.joined())

    let hints: [Character: [LetterState?]]
    let onLetter: (Character) -> Void
    let onDelete: () -> Void
    let onEnter: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            letterRow(Self.rows[0])
            letterRow(Self.rows[1])
            HStack(spacing: 4) {
                ActionKey(systemImage: "delete.left", action: onDelete)
                letterRow(Self.rows[2])
                ActionKey(systemImage: "return", action: onEnter)
            }
        }
    }

    private func letterRow(_ letters: [Character]) -> some View {
        HStack(spacing: 4) {
            ForEach(letters, id: \.self) { letter in
                Button { onLetter(letter) } label: {
                    Text(String(letter).uppercased())
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(HintBackground(hints: hints[letter]))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct ActionKey: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 48)
                .background(Palette.key, in: RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
    }
}

/// Splits the key into one cell per board, laid out like the boards (two columns).
private struct HintBackground: View {
    let hints: [LetterState?]?

    var body: some View {
        if let hints, hints.count > 1 {
            let rows = stride(from: 0, to: hints.count, by: 2).map { Array(hints[$0..<min($0 + 2, hints.count)]) }
            VStack(spacing: 0) {
                ForEach(rows.indices, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(rows[row].indices, id: \.self) { column in
                            Palette.color(for: rows[row][column])
                        }
                    }
                }
            }
        } else {
            Palette.color(for: hints?.first ?? nil)
        }
    }
}
