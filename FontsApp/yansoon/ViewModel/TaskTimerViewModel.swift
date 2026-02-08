//
//  TaskTimerViewModel.swift
//  yansoon
//
//  Created by Noura Faiz Alfaiz on 08/02/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class TaskTimerViewModel: ObservableObject {
    @Published private(set) var model: TaskTimerModel
    @Published private(set) var isRunning: Bool = false
    
    let taskId: UUID
    let taskTitle: String
    let estimatedMinutes: Double
    
    weak var appState: AppStateViewModel?
    
    private var tickingTask: Task<Void, Never>?
    
    init(task: TodoTask, appState: AppStateViewModel?) {
        self.taskId = task.id
        self.taskTitle = task.title
        self.estimatedMinutes = task.estimatedMinutes
        self.appState = appState
        
        let totalSeconds = Int(task.estimatedMinutes * 60)
        let alreadyWorkedSeconds = Int(task.actualMinutes * 60)
        self.model = TaskTimerModel(totalSeconds: totalSeconds, alreadyWorkedSeconds: alreadyWorkedSeconds)
    }
    
    deinit {
        tickingTask?.cancel()
    }
    
    // لا نبدأ تلقائياً. المستخدم يضغط Start.
    func start() {
        guard !isRunning else { return }
        isRunning = true
        if model.state == .idle || model.state == .paused {
            model.state = .running
        }
        startTicking()
    }
    
    func pause() {
        guard isRunning else { return }
        isRunning = false
        model.state = .paused
        tickingTask?.cancel()
        tickingTask = nil
        persistProgress()
    }
    
    func resume() {
        guard !isRunning else { return }
        isRunning = true
        model.state = .running
        startTicking()
    }
    
    func primaryButtonTapped() {
        switch model.state {
        case .idle:
            start()
        case .running:
            pause()
        case .paused:
            resume()
        case .finished:
            break
        }
    }
    
    func done() {
        tickingTask?.cancel()
        tickingTask = nil
        isRunning = false
        model.state = .finished
        persistProgress(markCompleted: true)
    }
    
    private func startTicking() {
        tickingTask?.cancel()
        tickingTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    self.tick()
                }
            }
        }
    }
    
    private func tick() {
        if model.remainingSeconds > 0 {
            model.remainingSeconds -= 1
        } else {
            model.overrunSeconds += 1
        }
        persistProgress()
    }
    
    private func persistProgress(markCompleted: Bool = false) {
        guard let appState else { return }
        let workedWithinPlan = model.totalSeconds - max(model.remainingSeconds, 0)
        let totalWorkedSeconds = max(0, workedWithinPlan) + max(0, model.overrunSeconds)
        let totalWorkedMinutes = Double(totalWorkedSeconds) / 60.0
        
        appState.updateTaskActualTime(taskId: taskId, minutes: totalWorkedMinutes)
        if markCompleted {
            if let idx = appState.tasks.firstIndex(where: { $0.id == taskId }) {
                var t = appState.tasks[idx]
                t.isCompleted = true
                appState.updateTask(t)
            }
        }
    }
}

