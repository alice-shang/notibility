import SwiftUI

struct DrawingStyleBar: View {
    @Binding var color: Color
    @Binding var lineWidth: CGFloat
    let widthRange: ClosedRange<CGFloat>

    private let palette: [Color] = [.black, .gray, .red, .orange, .green, .blue, .purple]

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 5) {
                ForEach(palette, id: \.self) { swatch in
                    Circle()
                        .fill(swatch)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle().stroke(Color.primary.opacity(0.15), lineWidth: 1)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 2)
                                .padding(-2)
                                .opacity(swatch == color ? 1 : 0)
                        )
                        .onTapGesture { color = swatch }
                }
            }

            Divider()
                .frame(height: 16)

            HStack(spacing: 6) {
                Image(systemName: "lineweight")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Slider(value: $lineWidth, in: widthRange)
                    .frame(width: 70)
                Circle()
                    .fill(color)
                    .frame(width: max(4, lineWidth), height: max(4, lineWidth))
                    .frame(width: 14)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: Capsule())
        .overlay(
            Capsule().strokeBorder(.secondary.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
    }
}
