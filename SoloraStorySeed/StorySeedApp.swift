import SwiftUI

@main
struct StorySeedApp: App {
    @StateObject private var store = StoryStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
