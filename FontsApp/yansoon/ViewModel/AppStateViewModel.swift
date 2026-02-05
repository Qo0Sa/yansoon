//
//  AppStateViewModel.swift
//  yansoon
//
//  Created by Assistant
//

import Foundation
import SwiftUI
import Combine

/// Shared ViewModel - يدير كل الـ state في التطبيق
class AppStateViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var energySettings: EnergySettings
    @Published var currentMode: EnergyLevel
    @Published var tasks: [Task] = []
    @Published var isSetupComplete: Bool
    
    // MARK: - Computed Properties
    
    /// Total hours configured for current mode
    var totalHoursForCurrentMode: Double {
        energySettings.hours(for: currentMode)
    }
    
    /// Total actual worked minutes across all tasks
    var totalWorkedMinutes: Double {
        tasks.reduce(0) { $0 + $1.actualMinutes }
    }
    
    /// Total worked hours
    var totalWorkedHours: Double {
        totalWorkedMinutes / 60.0
    }
    
    /// Progress (0 to 1)
    var progress: Double {
        guard totalHoursForCurrentMode > 0 else { return 0 }
        return min(totalWorkedHours / totalHoursForCurrentMode, 1.0)
    }
    
    /// Remaining hours
    var remainingHours: Double {
        max(0, totalHoursForCurrentMode - totalWorkedHours)
    }
    
    /// Formatted progress string (e.g., "2.5 / 4.5 hrs")
    var progressText: String {
        String(format: "%.1f / %.1f hrs", totalWorkedHours, totalHoursForCurrentMode)
    }
    
    // MARK: - Init
    init() {
        let storage = StorageManager.shared
        
        self.energySettings = storage.loadEnergySettings()
        self.currentMode = storage.loadCurrentMode() ?? .high
        self.tasks = storage.loadTasks()
        self.isSetupComplete = storage.isSetupComplete()
        
        // Auto-save on changes
        setupAutoSave()
    }
    
    // MARK: - Setup Auto-Save
    private var cancellables = Set<AnyCancellable>()
    
    private func setupAutoSave() {
        // Save energy settings
        $energySettings
            .dropFirst() // Skip initial value
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { settings in
                StorageManager.shared.saveEnergySettings(settings)
            }
            .store(in: &cancellables)
        
        // Save current mode
        $currentMode
            .dropFirst()
            .sink { mode in
                StorageManager.shared.saveCurrentMode(mode)
            }
            .store(in: &cancellables)
        
        // Save tasks
        $tasks
            .dropFirst()
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { tasks in
                StorageManager.shared.saveTasks(tasks)
            }
            .store(in: &cancellables)
        
        // Save setup status
        $isSetupComplete
            .dropFirst()
            .sink { complete in
                StorageManager.shared.setSetupComplete(complete)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Setup Methods
    
    /// Update hours for specific energy level during setup
    func updateHours(_ hours: Double, for level: EnergyLevel) {
        energySettings.setHours(hours, for: level)
    }
    
    /// Complete the initial setup
    func completeSetup() {
        isSetupComplete = true
    }
    
    // MARK: - Mode Switching
    
    /// Switch to a different energy mode
    /// - Resets all task progress when switching modes
    func switchMode(to newMode: EnergyLevel) {
        guard newMode != currentMode else { return }
        
        currentMode = newMode
        
        // Reset all task progress
        resetAllTaskProgress()
    }
    
    /// Reset progress for all tasks (when switching modes)
    private func resetAllTaskProgress() {
        for index in tasks.indices {
            tasks[index].actualMinutes = 0.0
            tasks[index].isCompleted = false
        }
    }
    
    // MARK: - Task Management
    
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    func toggleTaskCompletion(_ taskId: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    /// Update actual worked time for a task
    func updateTaskActualTime(taskId: UUID, minutes: Double) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].actualMinutes = minutes
        }
    }
    
    // MARK: - Reset (للتجربة)
    func resetApp() {
        StorageManager.shared.clearAll()
        energySettings = .default
        currentMode = .high
        tasks = []
        isSetupComplete = false
    }
}
