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
    
    private enum Keys {
        static let energySettings = "yansoon.energySettings"
        static let currentMode = "yansoon.currentMode"
        static let tasks = "yansoon.tasks"
        static let setupComplete = "yansoon.setupComplete"
    }
    
    
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
    
    func saveCurrentMode(_ mode: EnergyLevel) {
        defaults.set(mode.rawValue, forKey: Keys.currentMode)
    }
    
    func loadCurrentMode() -> EnergyLevel? {
        guard defaults.object(forKey: Keys.currentMode) != nil else { return nil }
        let raw = defaults.integer(forKey: Keys.currentMode)
        return EnergyLevel(rawValue: raw)
    }
    
    
    func saveTasks(_ tasks: [TodoTask]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            defaults.set(encoded, forKey: Keys.tasks)
        }
    }
    
    func loadTasks() -> [TodoTask] {
        guard let data = defaults.data(forKey: Keys.tasks),
              let tasks = try? JSONDecoder().decode([TodoTask].self, from: data) else {
            return []
        }
        return tasks
    }
    
    func setSetupComplete(_ complete: Bool) {
        defaults.set(complete, forKey: Keys.setupComplete)
    }
    
    func isSetupComplete() -> Bool {
        return defaults.bool(forKey: Keys.setupComplete)
    }
    
    func clearAll() {
        defaults.removeObject(forKey: Keys.energySettings)
        defaults.removeObject(forKey: Keys.currentMode)
        defaults.removeObject(forKey: Keys.tasks)
        defaults.removeObject(forKey: Keys.setupComplete)
    }
    
    
    func clearCurrentMode() {
        defaults.removeObject(forKey: Keys.currentMode)
    }
}
