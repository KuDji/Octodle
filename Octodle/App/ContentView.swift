import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @State private var model: GameViewModel?

    var body: some View {
        NavigationStack {
            if let model {
                GameView(model: model)
            } else {
                ProgressView()
            }
        }
        .task {
            if model == nil { model = GameViewModel(context: context) }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { model?.refreshDay() }
        }
    }
}
