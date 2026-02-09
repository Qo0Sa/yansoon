//
//  AppStateViewModel.swift
//  yansoon
//
//  Created by Assistant
//

import Foundation
import SwiftUI
import Combine

class AppStateViewModel: ObservableObject {
    
    @Published var energySettings: EnergySettings
    @Published var currentMode: EnergyLevel
    @Published var tasks: [TodoTask] = []
    @Published var isSetupComplete: Bool
    
    var totalHoursForCurrentMode: Double {
        energySettings.hours(for: currentMode)
    }
    
    var totalWorkedMinutes: Double {
        tasks.reduce(0) { $0 + $1.actualMinutes }
    }
    
    var totalWorkedHours: Double {
        totalWorkedMinutes / 60.0
    }
    
    var progress: Double {
        guard totalHoursForCurrentMode > 0 else { return 0 }
        return min(totalWorkedHours / totalHoursForCurrentMode, 1.0)
    }
    
    var remainingHours: Double {
        max(0, totalHoursForCurrentMode - totalWorkedHours)
    }
    
    var progressText: String {
        String(format: "%.1f / %.1f hrs", totalWorkedHours, totalHoursForCurrentMode)
    }
    
    init() {
        let storage = StorageManager.shared
        self.energySettings = storage.loadEnergySettings()
        self.currentMode = storage.loadCurrentMode() ?? .high
        self.tasks = storage.loadTasks()
        self.isSetupComplete = storage.isSetupComplete()
        setupAutoSave()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func setupAutoSave() {
        $energySettings
            .dropFirst()
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { settings in
                StorageManager.shared.saveEnergySettings(settings)
            }
            .store(in: &cancellables)
        
        $currentMode
            .dropFirst()
            .sink { mode in
                StorageManager.shared.saveCurrentMode(mode)
            }
            .store(in: &cancellables)
        
        $tasks
            .dropFirst()
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { tasks in
                StorageManager.shared.saveTasks(tasks)
            }
            .store(in: &cancellables)
        
        $isSetupComplete
            .dropFirst()
            .sink { complete in
                StorageManager.shared.setSetupComplete(complete)
            }
            .store(in: &cancellables)
    }
    
    
    func addCompletedTime(taskId: UUID, minutes: Double) {
        guard minutes > 0 else { return }
        guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }

        tasks[index].actualMinutes += minutes

        // اختياري: لو تبين تعلمين التاسك Completed لما يوصل/يتجاوز الوقت المتوقع
        if tasks[index].estimatedMinutes > 0,
           tasks[index].actualMinutes >= tasks[index].estimatedMinutes {
            tasks[index].isCompleted = true
        }
    }
    
    
    
    func updateHours(_ hours: Double, for level: EnergyLevel) {
        energySettings.setHours(hours, for: level)
    }
    
    func completeSetup() {
        isSetupComplete = true
    }
    
    func switchMode(to newMode: EnergyLevel) {
        guard newMode != currentMode else { return }
        currentMode = newMode
        resetAllTaskProgress()
    }
    
    private func resetAllTaskProgress() {
        for index in tasks.indices {
            tasks[index].actualMinutes = 0.0
            tasks[index].isCompleted = false
        }
    }
    
    func addTask(_ task: TodoTask) {
        tasks.append(task)
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    func updateTask(_ task: TodoTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    func toggleTaskCompletion(_ taskId: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    func updateTaskActualTime(taskId: UUID, minutes: Double) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].actualMinutes = minutes
        }
    }
    
    func resetApp() {
        StorageManager.shared.clearAll()
        energySettings = .default
        currentMode = .high
        tasks = []
        isSetupComplete = false
    }
    
    
    
}
