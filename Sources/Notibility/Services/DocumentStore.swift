import Foundation

@Observable
@MainActor
class DocumentStore {
    var notes: [Note] = []
    var selectedNoteID: UUID?

    private let saveFolder: URL

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        saveFolder = documents.appendingPathComponent("Notibility")
        try? FileManager.default.createDirectory(at: saveFolder, withIntermediateDirectories: true)
        loadAll()
    }

    func createNote() {
        let note = Note()
        notes.insert(note, at: 0)
        selectedNoteID = note.id
        save(note)
    }

    func delete(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        try? FileManager.default.removeItem(at: fileURL(note.id))
        selectedNoteID = notes.first?.id
    }

    func update(_ note: Note) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        var updated = note
        updated.updatedAt = Date()
        notes[index] = updated
        save(updated)
    }

    private func loadAll() {
        guard let files = try? FileManager.default.contentsOfDirectory(at: saveFolder, includingPropertiesForKeys: nil) else { return }
        notes = files
            .filter { $0.pathExtension == "json" }
            .compactMap { try? JSONDecoder().decode(Note.self, from: Data(contentsOf: $0)) }
            .sorted { $0.updatedAt > $1.updatedAt }
        selectedNoteID = notes.first?.id
    }

    private func save(_ note: Note) {
        try? JSONEncoder().encode(note).write(to: fileURL(note.id))
    }

    private func fileURL(_ id: UUID) -> URL {
        saveFolder.appendingPathComponent("\(id).json")
    }
}
