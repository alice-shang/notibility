import SwiftUI

struct FontPickerPopover: View {
    @AppStorage("systemFontName") private var systemFontName: String = NoteFont.system.rawValue

    let current: NoteFont
    let onSelect: (NoteFont) -> Void

    private var systemFont: NoteFont {
        NoteFont(rawValue: systemFontName) ?? .system
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Font")
                .font(systemFont.font(size: 15).weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 6)

            Divider()

            VStack(spacing: 1) {
                ForEach(NoteFont.allCases, id: \.self) { (option: NoteFont) in
                    FontOptionRow(option: option, isSelected: option == current) {
                        onSelect(option)
                    }
                }
            }
            .padding(6)
        }
        .frame(width: 210)
    }
}
