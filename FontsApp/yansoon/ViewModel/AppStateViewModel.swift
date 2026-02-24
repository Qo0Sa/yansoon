//
//  AppStateViewModel.swift
//  yansoon
//
//
//  AppStateViewModel.swift
//  yansoon
//

import Foundation
import SwiftUI
import Combine

final class AppStateViewModel: ObservableObject {
    
    @Published var energySettings: EnergySettings
    @Published var currentMode: EnergyLevel
    @Published var tasks: [TodoTask]
    @Published var isSetupComplete: Bool
    
    // Triggers for Sheets and Alerts
    @Published var showEnergySelectionPrompt: Bool = false
    @Published var showPostTaskPopUp: Bool = false // Part 3 Pop-up trigger

    private let notificationManager = NotificationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
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
        let workedH = Int(totalWorkedHours)
        let workedM = Int((totalWorkedHours - Double(workedH)) * 60)
        
        let totalH = Int(totalHoursForCurrentMode)
        let totalM = Int((totalHoursForCurrentMode - Double(totalH)) * 60)
        
        return "\(workedH)h \(workedM)m / \(totalH)h \(totalM)m"
    }
    
    // MARK: - Init
    init() {
        let storage = StorageManager.shared
        self.energySettings = storage.loadEnergySettings()
        self.currentMode = storage.loadCurrentMode() ?? .high
        self.tasks = storage.loadTasks()
        self.isSetupComplete = storage.isSetupComplete()
        
        setupAutoSave()
    }
    
    // MARK: - Auto Save Logic
    private func setupAutoSave() {
        $energySettings
            .dropFirst()
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { StorageManager.shared.saveEnergySettings($0) }
            .store(in: &cancellables)
        
        $currentMode
            .dropFirst()
            .sink { StorageManager.shared.saveCurrentMode($0) }
            .store(in: &cancellables)
        
        $tasks
            .dropFirst()
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { StorageManager.shared.saveTasks($0) }
            .store(in: &cancellables)
        
        $isSetupComplete
            .dropFirst()
            .sink { StorageManager.shared.setSetupComplete($0) }
            .store(in: &cancellables)
    }
    
    // MARK: - Setup & Mode Management
    func completeSetup() {
        isSetupComplete = true
    }
    
    func updateHours(_ hours: Double, for level: EnergyLevel) {
        energySettings.setHours(hours, for: level)
    }
    
    func switchMode(to newMode: EnergyLevel) {
        guard newMode != currentMode else { return }
        currentMode = newMode
        resetAllTaskProgress()
        // Note: Manual scheduling removed to favor Part 3 reactive logic.
    }
    
    private func resetAllTaskProgress() {
        for index in tasks.indices {
            tasks[index].actualMinutes = 0.0
            tasks[index].isCompleted = false
        }
    }
    
    // MARK: - Part 3: Return to App Logic
    /// Called when the app becomes active to check if a "Done" pop-up is pending
    func handleReturnToApp() {
        if UserDefaults.standard.bool(forKey: "pending_done_check") {
            showPostTaskPopUp = true
            UserDefaults.standard.set(false, forKey: "pending_done_check")
        }
    }
    
    // MARK: - Notification Permissions
    func requestNotificationPermission() async -> Bool {
        await notificationManager.requestAuthorization()
    }
    
    func dismissEnergyPrompt() {
        showEnergySelectionPrompt = false
    }
    
    // MARK: - Task Management
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
    
    func markTaskDone(_ taskId: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        tasks[index].isCompleted = true
        tasks[index].isTimerRunning = false
    }
    
    func addCompletedTime(taskId: UUID, minutes: Double) {
        guard minutes > 0 else { return }
        guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        tasks[index].actualMinutes += minutes
    }

    func clearCompletedTasks() {
        tasks.removeAll(where: { $0.isCompleted })
    }
    
    // MARK: - Reset App
    func resetApp() {
        StorageManager.shared.clearAll()
        energySettings = .default
        currentMode = .high
        tasks = []
        isSetupComplete = false
        notificationManager.cancelAllNotifications()
    }
}
