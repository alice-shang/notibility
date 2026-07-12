import Foundation

struct Note: Codable, Identifiable {
    let id: UUID
    var title: String
    var content: String
    var updatedAt: Date

    init(title: String = "Untitled") {
        self.id = UUID()
        self.title = title
        self.content = ""
        self.updatedAt = Date()
    }
}
