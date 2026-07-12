import SwiftUI

enum DrawingTool: String, CaseIterable {
    case pen, highlighter, eraser

    var icon: String {
        switch self {
        case .pen: "pencil"
        case .highlighter: "highlighter"
        case .eraser: "eraser"
        }
    }

    var label: String { rawValue.capitalized }
}

struct CanvasView: View {
    @Binding var note: Note
    let save: (Note) -> Void

    @State private var title: String
    @State private var tool: DrawingTool = .pen
    @State private var color: Color = .black
    @State private var lineWidth: Double = 3
    @State private var currentStroke: Stroke?

    init(note: Binding<Note>, save: @escaping (Note) -> Void) {
        _note = note
        self.save = save
        _title = State(initialValue: note.wrappedValue.title)
    }

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            Divider()
            toolBar
            Divider()
            canvas
        }
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var titleBar: some View {
        TextField("Note title", text: $title)
            .font(.title2.bold())
            .textFieldStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .onSubmit {
                note.title = title
                save(note)
            }
    }

    private var toolBar: some View {
        HStack(spacing: 12) {
            Picker("Tool", selection: $tool) {
                ForEach(DrawingTool.allCases, id: \.self) { t in
                    Label(t.label, systemImage: t.icon).tag(t)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 220)

            ColorPicker("Color", selection: $color)
                .labelsHidden()
                .disabled(tool == .eraser)

            Divider().frame(height: 20)

            Label("Size", systemImage: "lineweight")
                .foregroundStyle(.secondary)
                .font(.caption)
            Slider(value: $lineWidth, in: 1...30)
                .frame(width: 100)

            Spacer()

            Button {
                guard !note.strokes.isEmpty else { return }
                note.strokes.removeLast()
                save(note)
            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            .help("Undo last stroke")
            .keyboardShortcut("z")

            Button(role: .destructive) {
                note.strokes = []
                save(note)
            } label: {
                Image(systemName: "trash")
            }
            .help("Clear canvas")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var canvas: some View {
        Canvas { ctx, _ in
            for stroke in note.strokes {
                render(stroke, in: &ctx)
            }
            if let stroke = currentStroke {
                render(stroke, in: &ctx)
            }
        }
        .background(.white)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let pt = StrokePoint(value.location)
                    if currentStroke == nil {
                        currentStroke = Stroke(
                            colorHex: color.toHex(),
                            lineWidth: tool == .highlighter ? lineWidth * 5 : lineWidth,
                            opacity: tool == .highlighter ? 0.35 : 1.0,
                            isEraser: tool == .eraser
                        )
                    }
                    currentStroke?.points.append(pt)
                }
                .onEnded { _ in
                    if let stroke = currentStroke {
                        note.strokes.append(stroke)
                        save(note)
                    }
                    currentStroke = nil
                }
        )
    }

    private func render(_ stroke: Stroke, in ctx: inout GraphicsContext) {
        let pts = stroke.points.map { $0.cgPoint }
        guard pts.count > 1 else { return }

        let path = smoothPath(through: pts)
        let style = StrokeStyle(lineWidth: stroke.lineWidth, lineCap: .round, lineJoin: .round)

        if stroke.isEraser {
            ctx.stroke(path, with: .color(.white), style: style)
        } else {
            let c = Color(hex: stroke.colorHex) ?? .black
            ctx.stroke(path, with: .color(c.opacity(stroke.opacity)), style: style)
        }
    }

    private func smoothPath(through points: [CGPoint]) -> Path {
        var path = Path()
        path.move(to: points[0])
        for i in 1..<points.count - 1 {
            let mid = CGPoint(
                x: (points[i].x + points[i + 1].x) / 2,
                y: (points[i].y + points[i + 1].y) / 2
            )
            path.addQuadCurve(to: mid, control: points[i])
        }
        path.addLine(to: points[points.count - 1])
        return path
    }
}
