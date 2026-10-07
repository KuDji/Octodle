import OctodleKit
import SwiftUI

struct GameView: View {
    @Bindable var model: GameViewModel
    @FocusState private var focused: Bool

    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    if let result = model.result {
                        ResultView(result: result, betterThan: model.betterThan)
                    }
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(model.state.answers.indices, id: \.self) { board in
                            BoardView(
                                rows: model.state.rows(board: board),
                                input: model.input,
                                isSolved: model.state.isSolved(board: board),
                                isFinished: model.state.isFinished,
                                isSelected: model.selectedBoard == board
                            )
                            .onTapGesture { model.toggleSelection(board: board) }
                        }
                    }
                }
                .padding(8)
            }

            if !model.state.isFinished {
                KeyboardView(
                    hints: model.keyboardHints,
                    onLetter: model.type,
                    onDelete: model.deleteLetter,
                    onEnter: model.submit
                )
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
            }
        }
        .background(Palette.background)
        .overlay(alignment: .top) {
            if let toast = model.toast {
                Text(toast)
                    .font(.callout.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.thinMaterial, in: Capsule())
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: model.toast)
        .focusable()
        .focused($focused)
        .focusEffectDisabled()
        .onAppear { focused = true }
        .onKeyPress(phases: [.down, .repeat], action: handleHardwareKey)
        .navigationTitle("Осьминогль #\(model.state.day)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Picker("Режим", selection: $model.mode) {
                    Text("Обычный").tag(GameMode.standard)
                    Text("Согра").tag(GameMode.sogra)
                }
                .pickerStyle(.menu)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink {
                    LeaderboardView(api: model.api)
                } label: {
                    Image(systemName: "trophy")
                }
                NavigationLink {
                    StatsView(api: model.api, uuid: model.profile.uuid)
                } label: {
                    Image(systemName: "chart.bar")
                }
            }
        }
    }

    private func handleHardwareKey(_ press: KeyPress) -> KeyPress.Result {
        switch press.key {
        case .return:
            model.submit()
        case .delete:
            model.deleteLetter()
        default:
            guard let letter = press.characters.lowercased().first, KeyboardView.letters.contains(letter) else {
                return .ignored
            }
            model.type(letter)
        }
        return .handled
    }
}
