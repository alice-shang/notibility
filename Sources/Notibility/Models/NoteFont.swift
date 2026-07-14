import SwiftUI

enum NoteFont: String, CaseIterable {
    case system = "Default"
    case serif = "Serif"
    case mono = "Monospaced"
    case rounded = "Rounded"
    case georgia = "Georgia"
    case avenir = "Avenir Next"
    case timesNewRoman = "Times New Roman"
    case helvetica = "Helvetica Neue"

    var displayName: String { rawValue }

    func font(size: CGFloat = 15) -> Font {
        switch self {
        case .system: return .system(size: size)
        case .serif: return .system(size: size, design: .serif)
        case .mono: return .system(size: size, design: .monospaced)
        case .rounded: return .system(size: size, design: .rounded)
        case .georgia: return .custom("Georgia", size: size)
        case .avenir: return .custom("Avenir Next", size: size)
        case .timesNewRoman: return .custom("Times New Roman", size: size)
        case .helvetica: return .custom("Helvetica Neue", size: size)
        }
    }
}
