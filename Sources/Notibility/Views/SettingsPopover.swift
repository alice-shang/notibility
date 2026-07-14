import SwiftUI

struct SettingsPopover: View {
    @AppStorage("appearanceMode") private var appearanceModeRaw: String = AppearanceMode.system.rawValue
    @AppStorage("systemFontName") private var systemFontName: String = NoteFont.system.rawValue

    private var systemFont: NoteFont {
        NoteFont(rawValue: systemFontName) ?? .system
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Display")
                .font(systemFont.font(size: 17).weight(.semibold))

            VStack(alignment: .leading, spacing: 6) {
                Text("Appearance")
                    .font(systemFont.font(size: 11))
                    .foregroundStyle(.secondary)

                Picker("Appearance", selection: $appearanceModeRaw) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("System Font")
                    .font(systemFont.font(size: 11))
                    .foregroundStyle(.secondary)

                VStack(spacing: 1) {
                    ForEach(NoteFont.allCases, id: \.self) { (option: NoteFont) in
                        FontOptionRow(option: option, isSelected: option.rawValue == systemFontName) {
                            systemFontName = option.rawValue
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(width: 230)
    }
}
