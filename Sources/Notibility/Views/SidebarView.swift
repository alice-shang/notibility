import SwiftUI

struct SidebarView: View {
    @Environment(DocumentStore.self) private var store

    var body: some View {
        @Bindable var store = store
        List(store.notes, selection: $store.selectedNoteID) { note in
            VStack(alignment: .leading, spacing: 3) {
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .fontWeight(.medium)
                Text(note.updatedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
            .tag(note.id)
            .contextMenu {
                Button("Delete", role: .destructive) {
                    store.delete(note)
                }
            }
        }
        .navigationTitle("My Notes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: store.createNote) {
                    Image(systemName: "square.and.pencil")
                }
                .help("New Note (⌘N)")
            }
        }
    }
}
