import OctodleKit
import SwiftUI

enum Palette {
    static let background = Color(red: 0.07, green: 0.07, blue: 0.09)
    static let emptyTile = Color.white.opacity(0.06)
    static let key = Color(white: 0.32)
    static let correct = Color(red: 0.33, green: 0.65, blue: 0.35)
    static let present = Color(red: 0.85, green: 0.70, blue: 0.20)
    static let absent = Color(white: 0.18)

    static func color(for state: LetterState?) -> Color {
        switch state {
        case .correct: correct
        case .present: present
        case .absent: absent
        case nil: key
        }
    }
}
