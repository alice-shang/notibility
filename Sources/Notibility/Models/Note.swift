import Foundation

struct Note: Codable, Identifiable {
    let id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var fontName: String
    var strokes: [DrawingStroke]

    enum CodingKeys: String, CodingKey {
        case id, title, content, createdAt, updatedAt, fontName, strokes
    }

    init(title: String = "Untitled") {
        self.id = UUID()
        self.title = title
        self.content = ""
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
        self.fontName = NoteFont.system.rawValue
        self.strokes = []
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? updatedAt
        fontName = try container.decodeIfPresent(String.self, forKey: .fontName) ?? NoteFont.system.rawValue
        strokes = try container.decodeIfPresent([DrawingStroke].self, forKey: .strokes) ?? []
    }
}
