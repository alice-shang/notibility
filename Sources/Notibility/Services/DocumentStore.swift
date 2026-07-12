import Foundation

@Observable
@MainActor
class DocumentStore {
    var notes: [Note] = []
    var selectedNoteID: UUID?

    private let directory: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        directory = docs.appendingPathComponent("Notibility", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        load()
    }

    func createNote() {
        let note = Note()
        notes.insert(note, at: 0)
        selectedNoteID = note.id
        save(note)
    }

    func delete(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        try? FileManager.default.removeItem(at: fileURL(for: note.id))
        selectedNoteID = notes.first?.id
    }

    func update(_ note: Note) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        var updated = note
        updated.updatedAt = Date()
        notes[index] = updated
        save(updated)
    }

    private func load() {
        guard let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return }
        let decoder = JSONDecoder()
        notes = files
            .filter { $0.pathExtension == "json" }
            .compactMap { try? decoder.decode(Note.self, from: Data(contentsOf: $0)) }
            .sorted { $0.updatedAt > $1.updatedAt }
        selectedNoteID = notes.first?.id
    }

    private func save(_ note: Note) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        try? encoder.encode(note).write(to: fileURL(for: note.id))
    }

    private func fileURL(for id: UUID) -> URL {
        directory.appendingPathComponent("\(id).json")
    }
}
