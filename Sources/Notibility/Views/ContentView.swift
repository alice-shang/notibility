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
                NoteEditorView(note: $store.notes[index], save: { store.update($0) })
                    .id(id)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "note.text")
                        .font(.system(size: 52))
                        .foregroundStyle(.tertiary)
                    Text("No note selected")
                        .foregroundStyle(.secondary)
                    Button("Create a note") { store.createNote() }
                        .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 700, minHeight: 500)
    }
}
