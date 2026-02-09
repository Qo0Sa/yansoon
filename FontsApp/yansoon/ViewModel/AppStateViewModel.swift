//
//  AppStateViewModel.swift
//  yansoon

//

import Foundation
import SwiftUI
import Combine

class AppStateViewModel: ObservableObject {
    
    @Published var energySettings: EnergySettings
    @Published var currentMode: EnergyLevel
    @Published var tasks: [TodoTask] = []
    @Published var isSetupComplete: Bool
    
    // The variable that triggers the sheet
    @Published var showEnergySelectionPrompt: Bool = false
    
    private let notificationManager = NotificationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    var totalHoursForCurrentMode: Double { energySettings.hours(for: currentMode) }
    var totalWorkedMinutes: Double { tasks.reduce(0) { $0 + $1.actualMinutes } }
    var totalWorkedHours: Double { totalWorkedMinutes / 60.0 }
    var progress: Double {
        guard totalHoursForCurrentMode > 0 else { return 0 }
        return min(totalWorkedHours / totalHoursForCurrentMode, 1.0)
    }
    var remainingHours: Double { max(0, totalHoursForCurrentMode - totalWorkedHours) }
    var progressText: String { String(format: "%.1f / %.1f hrs", totalWorkedHours, totalHoursForCurrentMode) }
    
    init() {
        let storage = StorageManager.shared
        self.energySettings = storage.loadEnergySettings()
        self.currentMode = storage.loadCurrentMode() ?? .high
        self.tasks = storage.loadTasks()
        self.isSetupComplete = storage.isSetupComplete()
        
        setupAutoSave()
        
        // 1. IMPORTANT: Start listening for the notification here
        setupNotificationObserver()
    }
    
    // 2. This function listens for the signal from NotificationManager
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEnergyCheckInNotification),
            name: .showEnergySelection, // This connects to the name in NotificationManager
            object: nil
        )
    }
    
    // 3. This runs when the signal is received
    @objc private func handleEnergyCheckInNotification() {
        print("⚡️ [AppState] Notification signal received! Opening sheet...")
        DispatchQueue.main.async { [weak self] in
            self?.showEnergySelectionPrompt = true
        }
    }
    
    private func setupAutoSave() {
        $energySettings.dropFirst().debounce(for: 0.5, scheduler: DispatchQueue.main).sink { StorageManager.shared.saveEnergySettings($0) }.store(in: &cancellables)
        $currentMode.dropFirst().sink { StorageManager.shared.saveCurrentMode($0) }.store(in: &cancellables)
        $tasks.dropFirst().debounce(for: 0.5, scheduler: DispatchQueue.main).sink { StorageManager.shared.saveTasks($0) }.store(in: &cancellables)
        $isSetupComplete.dropFirst().sink { StorageManager.shared.setSetupComplete($0) }.store(in: &cancellables)
    }
    
    func updateHours(_ hours: Double, for level: EnergyLevel) { energySettings.setHours(hours, for: level) }
    func completeSetup() { isSetupComplete = true }
    
    func switchMode(to newMode: EnergyLevel) {
        guard newMode != currentMode else { return }
        currentMode = newMode
        resetAllTaskProgress()
        scheduleEnergyCheckIn()
    }
    
    private func resetAllTaskProgress() {
        for index in tasks.indices {
            tasks[index].actualMinutes = 0.0
            tasks[index].isCompleted = false
        }
    }
    
    func scheduleEnergyCheckIn() {
        notificationManager.scheduleEnergyCheckIn(for: currentMode)
    }
    
    func requestNotificationPermission() async -> Bool {
        return await notificationManager.requestAuthorization()
    }
    
    func dismissEnergyPrompt() {
        showEnergySelectionPrompt = false
    }
    
    func addTask(_ task: TodoTask) { tasks.append(task) }
    func deleteTask(at offsets: IndexSet) { tasks.remove(atOffsets: offsets) }
    func updateTask(_ task: TodoTask) { if let index = tasks.firstIndex(where: { $0.id == task.id }) { tasks[index] = task } }
    func toggleTaskCompletion(_ taskId: UUID) { if let index = tasks.firstIndex(where: { $0.id == taskId }) { tasks[index].isCompleted.toggle() } }
    func updateTaskActualTime(taskId: UUID, minutes: Double) { if let index = tasks.firstIndex(where: { $0.id == taskId }) { tasks[index].actualMinutes = minutes } }
    
    func resetApp() {
        StorageManager.shared.clearAll()
        energySettings = .default
        currentMode = .high
        tasks = []
        isSetupComplete = false
        notificationManager.cancelAllNotifications()
    }
}
// Note: I removed the extension here because it already exists in NotificationManager.swift
