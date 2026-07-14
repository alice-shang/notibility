import CoreGraphics
import Foundation

enum DrawingTool: String, Codable {
    case pencil
    case pen
    case eraser
}

struct DrawingStroke: Codable, Identifiable {
    var id = UUID()
    var tool: DrawingTool
    var points: [CGPoint]
    var color: CodableColor
    var lineWidth: CGFloat
}
