//
//  AppStateViewModel.swift
//  yansoon
//
//
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
    @Published var showEnergySelectionPrompt: Bool = false
    
    private let notificationManager = NotificationManager.shared
    
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
        setupNotificationObserver()
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
    
    func updateHours(_ hours: Double, for level: EnergyLevel) {
        energySettings.setHours(hours, for: level)
    }
    
    func completeSetup() {
        isSetupComplete = true
    }
    
    func switchMode(to newMode: EnergyLevel) {
        guard newMode != currentMode else {
            print("⚠️ [AppState] Attempted to switch to same mode: \(newMode.title)")
            return
        }
        print("🔄 [AppState] Switching mode from \(currentMode.title) to \(newMode.title)")
        currentMode = newMode
        resetAllTaskProgress()
        
        // Schedule notification for energy check-in
        print("📅 [AppState] Calling scheduleEnergyCheckIn()...")
        scheduleEnergyCheckIn()
    }
    
    private func resetAllTaskProgress() {
        for index in tasks.indices {
            tasks[index].actualMinutes = 0.0
            tasks[index].isCompleted = false
        }
    }
    
    // MARK: - Notification Handling
    
    private func setupNotificationObserver() {
        print("👂 [AppState] Setting up notification observer")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEnergyCheckInNotification),
            name: .showEnergySelection,
            object: nil
        )
    }
    
    @objc private func handleEnergyCheckInNotification() {
        print("🔔 [AppState] Received energy check-in notification!")
        DispatchQueue.main.async { [weak self] in
            self?.showEnergySelectionPrompt = true
        }
    }
    
    func scheduleEnergyCheckIn() {
        print("📲 [AppState] scheduleEnergyCheckIn called for mode: \(currentMode.title)")
        notificationManager.scheduleEnergyCheckIn(for: currentMode)
    }
    
    func requestNotificationPermission() async -> Bool {
        return await notificationManager.requestAuthorization()
    }
    
    func dismissEnergyPrompt() {
        showEnergySelectionPrompt = false
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
        notificationManager.cancelAllNotifications()
    }
}
