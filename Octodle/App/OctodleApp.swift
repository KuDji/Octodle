import SwiftData
import SwiftUI

@main
struct OctodleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [SavedGame.self, PlayerProfile.self])
    }
}
