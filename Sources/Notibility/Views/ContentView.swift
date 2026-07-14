import SwiftUI

public struct ContentView: View {
    @Environment(DocumentStore.self) private var store
    @AppStorage("appearanceMode") private var appearanceModeRaw: String = AppearanceMode.system.rawValue
    @AppStorage("systemFontName") private var systemFontName: String = NoteFont.system.rawValue

    public init() {}

    private var appearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceModeRaw) ?? .system
    }

    private var systemFont: NoteFont {
        NoteFont(rawValue: systemFontName) ?? .system
    }

    public var body: some View {
        @Bindable var store = store
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 230, ideal: 260, max: 340)
        } detail: {
            if let id = store.selectedNoteID,
               let index = store.notes.firstIndex(where: { $0.id == id }) {
                NoteEditorView(note: $store.notes[index], save: { store.update($0) })
                    .id(id)
            } else {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.12))
                            .frame(width: 88, height: 88)
                        Image(systemName: "note.text")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.accentColor)
                    }
                    VStack(spacing: 4) {
                        Text("No note selected")
                            .font(systemFont.font(size: 16).weight(.semibold))
                        Text("Pick a note from the list, or create a new one.")
                            .font(systemFont.font(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    Button("Create a note") { store.createNote() }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .font(systemFont.font(size: 13))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.background)
            }
        }
        #if os(macOS)
        .frame(minWidth: 760, minHeight: 520)
        #endif
        .preferredColorScheme(appearanceMode.colorScheme)
    }
}
