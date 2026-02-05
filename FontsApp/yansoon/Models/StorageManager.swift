//
//  StorageManager.swift
//  yansoon
//
//  Created by Sarah on 17/08/1447 AH.
//


import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let energySettings = "energySettings"
        static let currentMode = "currentMode"
        static let tasks = "tasks"
        static let setupComplete = "setupComplete"
    }
    
    // MARK: - Energy Settings
    func saveEnergySettings(_ settings: EnergySettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            defaults.set(encoded, forKey: Keys.energySettings)
        }
    }
    
    func loadEnergySettings() -> EnergySettings {
        guard let data = defaults.data(forKey: Keys.energySettings),
              let settings = try? JSONDecoder().decode(EnergySettings.self, from: data) else {
            return .default
        }
        return settings
    }
    
    // MARK: - Current Mode
    func saveCurrentMode(_ mode: EnergyLevel) {
        defaults.set(mode.rawValue, forKey: Keys.currentMode)
    }
    
    func loadCurrentMode() -> EnergyLevel? {
        let rawValue = defaults.integer(forKey: Keys.currentMode)
        return EnergyLevel(rawValue: rawValue)
    }
    
    // MARK: - Tasks
    func saveTasks(_ tasks: [Task]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            defaults.set(encoded, forKey: Keys.tasks)
        }
    }
    
    func loadTasks() -> [Task] {
        guard let data = defaults.data(forKey: Keys.tasks),
              let tasks = try? JSONDecoder().decode([Task].self, from: data) else {
            return []
        }
        return tasks
    }
    
    // MARK: - Setup Status
    func setSetupComplete(_ complete: Bool) {
        defaults.set(complete, forKey: Keys.setupComplete)
    }
    
    func isSetupComplete() -> Bool {
        return defaults.bool(forKey: Keys.setupComplete)
    }
    
    // MARK: - Clear All Data (للتجربة)
    func clearAll() {
        defaults.removeObject(forKey: Keys.energySettings)
        defaults.removeObject(forKey: Keys.currentMode)
        defaults.removeObject(forKey: Keys.tasks)
        defaults.removeObject(forKey: Keys.setupComplete)
    }
}
