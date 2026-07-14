import SwiftUI

struct SidebarView: View {
    @Environment(DocumentStore.self) private var store
    @AppStorage("systemFontName") private var systemFontName: String = NoteFont.system.rawValue
    @State private var showingSettings = false

    private var systemFont: NoteFont {
        NoteFont(rawValue: systemFontName) ?? .system
    }

    var body: some View {
        @Bindable var store = store
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Your Notes")
                    .font(systemFont.font(size: 20).weight(.bold))

                Spacer()

                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 13, weight: .medium))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .background(.quaternary.opacity(0.5), in: Circle())
                .help("Display Settings")
                .popover(isPresented: $showingSettings) {
                    SettingsPopover()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            if store.notes.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "note.text")
                        .font(.system(size: 34))
                        .foregroundStyle(.tertiary)
                    Text("No notes yet")
                        .font(systemFont.font(size: 13).weight(.medium))
                        .foregroundStyle(.secondary)
                    Button("Create your first note", action: store.createNote)
                        .buttonStyle(.link)
                        .font(systemFont.font(size: 12))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 40)
            } else {
                List(store.notes, selection: $store.selectedNoteID) { note in
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color.accentColor.gradient.opacity(0.85))
                            .frame(width: 32, height: 32)
                            .overlay {
                                Text(String((note.title.isEmpty ? "Untitled" : note.title).prefix(1)).uppercased())
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            // Note title is user-typed content — kept independent of the system font setting.
                            Text(note.title.isEmpty ? "Untitled" : note.title)
                                .font(.body)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            Text(note.createdAt, format: .dateTime.month(.abbreviated).day().year().hour().minute())
                                .font(systemFont.font(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    .tag(note.id)
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            store.delete(note)
                        }
                    }
                }
                .listStyle(.sidebar)
            }
        }
        .navigationTitle("Your Notes")
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
