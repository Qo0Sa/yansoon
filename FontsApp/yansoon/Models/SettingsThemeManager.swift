import SwiftUI
import Combine

final class SettingsThemeManager: ObservableObject {
    @AppStorage("settings_appearanceMode") private var appearanceRaw: String = AppearanceMode.dark.rawValue
    
    var colorScheme: ColorScheme? {
        let mode = AppearanceMode(rawValue: appearanceRaw) ?? .dark
        switch mode {
        case .light: return .light
        case .dark: return .dark
        }
    }
}
