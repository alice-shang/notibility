import SwiftUI

struct ContentView: View {
    @Environment(DocumentStore.self) private var store

    var body: some View {
        @Bindable var store = store
        NavigationSplitView {
            SidebarView()
        } detail: {
            if let id = store.selectedNoteID,
               let index = store.notes.firstIndex(where: { $0.id == id }) {
                CanvasView(note: $store.notes[index], save: { store.update($0) })
                    .id(id)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "note.text")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text("Select a note or create a new one")
                        .foregroundStyle(.secondary)
                    Button("New Note") { store.createNote() }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 800, minHeight: 550)
    }
}
