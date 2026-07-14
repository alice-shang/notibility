import SwiftUI

struct DrawingCanvasView: View {
    @Binding var strokes: [DrawingStroke]
    var activeTool: DrawingTool?
    var pencilColor: Color
    var pencilWidth: CGFloat
    var penColor: Color
    var penWidth: CGFloat
    var onStrokesChanged: () -> Void

    @State private var currentPoints: [CGPoint] = []

    private let eraserRadius: CGFloat = 14

    var body: some View {
        Canvas { context, _ in
            for stroke in strokes {
                draw(stroke, in: &context)
            }
            if let activeTool, activeTool != .eraser, currentPoints.count > 1 {
                draw(
                    DrawingStroke(
                        tool: activeTool,
                        points: currentPoints,
                        color: CodableColor(activeTool == .pencil ? pencilColor : penColor),
                        lineWidth: activeTool == .pencil ? pencilWidth : penWidth
                    ),
                    in: &context
                )
            }
        }
        .contentShape(Rectangle())
        .allowsHitTesting(activeTool != nil)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    guard let activeTool else { return }
                    if activeTool == .eraser {
                        eraseStrokes(near: value.location)
                    } else {
                        currentPoints.append(value.location)
                    }
                }
                .onEnded { _ in
                    defer { currentPoints = [] }
                    guard let activeTool, activeTool != .eraser, currentPoints.count > 1 else { return }
                    strokes.append(
                        DrawingStroke(
                            tool: activeTool,
                            points: currentPoints,
                            color: CodableColor(activeTool == .pencil ? pencilColor : penColor),
                            lineWidth: activeTool == .pencil ? pencilWidth : penWidth
                        )
                    )
                    onStrokesChanged()
                }
        )
    }

    private func eraseStrokes(near point: CGPoint) {
        let before = strokes.count
        strokes.removeAll { stroke in
            stroke.points.contains { hypot($0.x - point.x, $0.y - point.y) < eraserRadius }
        }
        if strokes.count != before {
            onStrokesChanged()
        }
    }

    private func draw(_ stroke: DrawingStroke, in context: inout GraphicsContext) {
        guard stroke.points.count > 1 else { return }
        var path = Path()
        path.move(to: stroke.points[0])
        for point in stroke.points.dropFirst() {
            path.addLine(to: point)
        }
        context.stroke(path, with: .color(stroke.color.color), style: StrokeStyle(lineWidth: stroke.lineWidth, lineCap: .round, lineJoin: .round))
    }
}
