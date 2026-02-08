import SwiftUI
import Combine

enum AppearanceMode: String, CaseIterable, Identifiable {
    case light, dark
    var id: String { rawValue }
    var title: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

final class SettingsViewModel: ObservableObject {
    // تخزين محلي بدون لمس StorageManager
    @AppStorage("settings_useDefault") var useDefaultSettings: Bool = false
    @AppStorage("settings_appearanceMode") var appearanceRaw: String = AppearanceMode.dark.rawValue
    
    @Published var highHours: Double = 8.0
    @Published var mediumHours: Double = 6.0
    @Published var lowHours: Double = 4.0
    
    weak var appState: AppStateViewModel?
    
    var appearanceMode: AppearanceMode {
        get { AppearanceMode(rawValue: appearanceRaw) ?? .dark }
        set { appearanceRaw = newValue.rawValue }
    }
    
    func bind(appState: AppStateViewModel) {
        self.appState = appState
        // Initialize from app state
        highHours = appState.energySettings.highEnergyHours
        mediumHours = appState.energySettings.mediumEnergyHours
        lowHours = appState.energySettings.lowEnergyHours
    }
    
    func setDefaultIfNeeded() {
        guard useDefaultSettings else { return }
        let def = EnergySettings.default
        highHours = def.highEnergyHours
        mediumHours = def.mediumEnergyHours
        lowHours = def.lowEnergyHours
        applyAll()
    }
    
    func updateHigh(_ value: Double) {
        highHours = value
        appState?.updateHours(value, for: .high)
    }
    
    func updateMedium(_ value: Double) {
        mediumHours = value
        appState?.updateHours(value, for: .medium)
    }
    
    func updateLow(_ value: Double) {
        lowHours = value
        appState?.updateHours(value, for: .low)
    }
    
    func applyAll() {
        appState?.updateHours(highHours, for: .high)
        appState?.updateHours(mediumHours, for: .medium)
        appState?.updateHours(lowHours, for: .low)
    }
    
    func progress(for level: EnergyLevel) -> Double {
        let hours: Double
        switch level {
        case .high: hours = highHours
        case .medium: hours = mediumHours
        case .low: hours = lowHours
        }
        return min(hours / level.maxHours, 1.0)
    }
    
    func isOverAverage(level: EnergyLevel) -> Bool {
        let hours: Double
        switch level {
        case .high: hours = highHours
        case .medium: hours = mediumHours
        case .low: hours = lowHours
        }
        return hours > level.averageHours
    }
}
