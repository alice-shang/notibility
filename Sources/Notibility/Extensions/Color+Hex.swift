import SwiftUI

extension Color {
    func toHex() -> String {
        let ns = NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self)
        return String(
            format: "#%02X%02X%02X",
            Int(min(max(ns.redComponent, 0), 1) * 255),
            Int(min(max(ns.greenComponent, 0), 1) * 255),
            Int(min(max(ns.blueComponent, 0), 1) * 255)
        )
    }

    init?(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard h.count == 6 else { return nil }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}
