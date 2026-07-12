import SwiftUI

struct NoteEditorView: View {
    @Binding var note: Note
    let save: (Note) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Title
            TextField("Note title", text: $note.title)
                .font(.title.bold())
                .textFieldStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 8)
                .onChange(of: note.title) { _, _ in save(note) }

            Divider()

            // Body
            TextEditor(text: $note.content)
                .font(.body)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .onChange(of: note.content) { _, _ in save(note) }
        }
    }
}
