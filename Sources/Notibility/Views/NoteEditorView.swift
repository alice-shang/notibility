import SwiftUI

struct NoteEditorView: View {
    @Environment(DocumentStore.self) private var store
    @Binding var note: Note
    let save: (Note) -> Void

    @State private var flashText: String?
    @State private var flashTint: Color = .accentColor

    @State private var showingFontPicker = false
    @State private var activeDrawingTool: DrawingTool?
    @State private var pencilColor: Color = .gray
    @State private var pencilWidth: CGFloat = 1.5
    @State private var penColor: Color = .black
    @State private var penWidth: CGFloat = 2.5

    private var selectedFont: NoteFont {
        NoteFont(rawValue: note.fontName) ?? .system
    }

    private var activeColor: Binding<Color> {
        activeDrawingTool == .pencil ? $pencilColor : $penColor
    }

    private var activeWidth: Binding<CGFloat> {
        activeDrawingTool == .pencil ? $pencilWidth : $penWidth
    }

    private var activeWidthRange: ClosedRange<CGFloat> {
        activeDrawingTool == .pencil ? 1...8 : 1...10
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                HStack {
                    FloatingIconButton(systemImage: "house.fill") {
                        store.selectedNoteID = nil
                    }
                    .help("Back to Notes")

                    Spacer()

                    Text(note.updatedAt, format: .relative(presentation: .named))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)

                // Title
                TextField("Note title", text: $note.title)
                    .font(.title.bold())
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 24)
                    .padding(.top, 6)
                    .padding(.bottom, 8)
                    .onChange(of: note.title) { _, _ in save(note) }

                Divider()
                    .opacity(0.6)

                // Body
                ZStack {
                    TextEditor(text: $note.content)
                        .font(selectedFont.font())
                        .lineSpacing(3)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .onChange(of: note.content) { _, _ in save(note) }

                    DrawingCanvasView(
                        strokes: $note.strokes,
                        activeTool: activeDrawingTool,
                        pencilColor: pencilColor,
                        pencilWidth: pencilWidth,
                        penColor: penColor,
                        penWidth: penWidth
                    ) {
                        save(note)
                    }
                }
            }

            VStack(spacing: 10) {
                FloatingIconButton(systemImage: "pencil", isActive: activeDrawingTool == .pencil) {
                    activeDrawingTool = activeDrawingTool == .pencil ? nil : .pencil
                }
                .help("Pencil")

                FloatingIconButton(systemImage: "pencil.tip", isActive: activeDrawingTool == .pen) {
                    activeDrawingTool = activeDrawingTool == .pen ? nil : .pen
                }
                .help("Pen")

                FloatingIconButton(systemImage: "eraser", isActive: activeDrawingTool == .eraser) {
                    activeDrawingTool = activeDrawingTool == .eraser ? nil : .eraser
                }
                .help("Eraser")

                FloatingIconButton(text: "Aa") {
                    showingFontPicker = true
                }
                .help("Font")
                .popover(isPresented: $showingFontPicker) {
                    FontPickerPopover(current: selectedFont) { picked in
                        note.fontName = picked.rawValue
                        save(note)
                        showingFontPicker = false
                    }
                }
            }
            .padding(.trailing, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)

            if activeDrawingTool == .pencil || activeDrawingTool == .pen {
                DrawingStyleBar(color: activeColor, lineWidth: activeWidth, widthRange: activeWidthRange)
                    .padding(.top, 52)
                    .padding(.trailing, 16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            AnalogTimerView(onPhaseFlash: { text, tint in
                flashTint = tint
                flashText = text
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if flashText == text { flashText = nil }
                }
            })
            .padding(14)

            if let flashText {
                Text(flashText)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 28)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.regularMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(flashTint.opacity(0.16))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .strokeBorder(flashTint.opacity(0.35), lineWidth: 1)
                            )
                    )
                    .shadow(color: .black.opacity(0.18), radius: 20, y: 8)
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
            }
        }
        .background(.background)
        .animation(.easeOut(duration: 0.25), value: flashText)
        .animation(.easeOut(duration: 0.2), value: activeDrawingTool)
    }
}

struct FloatingIconButton: View {
    var systemImage: String? = nil
    var text: String? = nil
    var isActive: Bool = false
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 12, weight: .semibold))
                } else if let text {
                    Text(text)
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .foregroundStyle(isActive ? .white : .primary)
            .frame(width: 28, height: 28)
            .background(isActive ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.regularMaterial), in: Circle())
            .overlay(
                Circle()
                    .strokeBorder(.secondary.opacity(isActive ? 0 : (isHovering ? 0.35 : 0.15)), lineWidth: 1)
            )
            .shadow(color: .black.opacity(isHovering ? 0.18 : 0.08), radius: isHovering ? 5 : 2, y: 1)
            .scaleEffect(isHovering ? 1.08 : 1)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) { isHovering = hovering }
        }
    }
}
