import AppKit
import Notibility
import SwiftUI

@main
struct NotibilityApp: App {
    @State private var store = DocumentStore()

    init() {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

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
