import SwiftUI
import Notibility

@main
struct NotibilityPadApp: App {
    @State private var store = DocumentStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
