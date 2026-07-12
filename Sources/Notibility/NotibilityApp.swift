import SwiftUI

@main
struct NotibilityApp: App {
    @State private var store = DocumentStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Note") { store.createNote() }
                    .keyboardShortcut("n")
            }
        }
    }
}
