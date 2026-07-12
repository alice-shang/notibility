import Foundation
import CoreGraphics

struct StrokePoint: Codable, Sendable {
    var x: Double
    var y: Double

    init(_ point: CGPoint) {
        x = point.x
        y = point.y
    }

    var cgPoint: CGPoint { CGPoint(x: x, y: y) }
}

struct Stroke: Codable, Identifiable, Sendable {
    let id: UUID
    var points: [StrokePoint]
    var colorHex: String
    var lineWidth: Double
    var opacity: Double
    var isEraser: Bool

    init(colorHex: String = "#000000", lineWidth: Double = 3, opacity: Double = 1.0, isEraser: Bool = false) {
        self.id = UUID()
        self.points = []
        self.colorHex = colorHex
        self.lineWidth = lineWidth
        self.opacity = opacity
        self.isEraser = isEraser
    }
}

struct Note: Codable, Identifiable, Sendable {
    let id: UUID
    var title: String
    var strokes: [Stroke]
    var createdAt: Date
    var updatedAt: Date

    init(title: String = "Untitled") {
        self.id = UUID()
        self.title = title
        self.strokes = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
