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

    // Date-based state
    private var startDate: Date?
    private var pauseDate: Date?
    private var totalPausedSeconds: Int = 0
    private var hasSentStillWorkingNotification: Bool = false

    // UserDefaults keys
    private var keyPrefix: String { "task_timer_\(taskId.uuidString)" }
    private var startKey: String { "\(keyPrefix)_start" }
    private var pauseKey: String { "\(keyPrefix)_pause" }
    private var pausedSumKey: String { "\(keyPrefix)_pausedSum" }
    private var stateKey: String { "\(keyPrefix)_state" }

    init(task: TodoTask, appState: AppStateViewModel?) {
        self.taskId = task.id
        self.taskTitle = task.title
        self.estimatedMinutes = task.estimatedMinutes
        self.appState = appState

        let totalSeconds = Int(task.estimatedMinutes * 60)
        let alreadyWorkedSeconds = Int(task.actualMinutes * 60)
        self.model = TaskTimerModel(totalSeconds: totalSeconds, alreadyWorkedSeconds: alreadyWorkedSeconds)

        restoreTimerState()
        recalcFromClock()

        if model.state == .running {
            isRunning = true
            startTickingUIOnly()
        }
    }

    deinit {
        tickingTask?.cancel()
    }

    func start() {
        guard model.state != .running else { return }
        if startDate == nil {
            startDate = Date()
            totalPausedSeconds = 0
        }
        pauseDate = nil
        model.state = .running
        isRunning = true
        persistTimerState()
        startTickingUIOnly()
        recalcFromClock()
        persistProgress()
    }

    func pause() {
        guard model.state == .running else { return }
        pauseDate = Date()
        model.state = .paused
        isRunning = false
        stopTicking()
        recalcFromClock()
        persistTimerState()
        persistProgress()
    }

    func resume() {
        guard model.state == .paused else { return }
        if let pausedAt = pauseDate {
            totalPausedSeconds += Int(Date().timeIntervalSince(pausedAt))
        }
        pauseDate = nil
        model.state = .running
        isRunning = true
        persistTimerState()
        startTickingUIOnly()
        recalcFromClock()
        persistProgress()
    }

    func primaryButtonTapped() {
        switch model.state {
        case .idle: start()
        case .running: pause()
        case .paused: resume()
        case .finished: break
        }
    }

    func done() {
        stopTicking()
        isRunning = false
        recalcFromClock()
        model.state = .finished
        persistProgress()
        clearTimerState()
    }

    func syncNow() {
        recalcFromClock()
        persistProgress()
    }

    private func startTickingUIOnly() {
        stopTicking()
        tickingTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    self.recalcFromClock()
                    self.persistProgress()
                }
            }
        }
    }

    private func stopTicking() {
        tickingTask?.cancel()
        tickingTask = nil
    }

    private func recalcFromClock() {
        guard let start = startDate else { return }
        let totalAllocated = model.totalSeconds
        let now = Date()
        let effectiveNow = (model.state == .paused && pauseDate != nil) ? pauseDate! : now

        let elapsedRaw = Int(effectiveNow.timeIntervalSince(start)) - totalPausedSeconds
        let elapsed = max(0, elapsedRaw)
        let remaining = totalAllocated - elapsed

        if remaining > 0 {
            model.remainingSeconds = remaining
            model.overrunSeconds = 0
        } else {
            model.remainingSeconds = 0
            model.overrunSeconds = abs(remaining)
            
            // --- Part 2: 1-hour overrun check & Auto-pause 3600---
            if model.overrunSeconds >= 10 && model.state == .running {
                pause()
                if !hasSentStillWorkingNotification {
                    NotificationManager.shared.sendImmediateNotification(
                        title: "Are you still working?",
                        body: "The timer exceeded 1 hour and has been paused."
                    )
                    hasSentStillWorkingNotification = true
                }
            }
        }
    }

    private func persistProgress() {
        guard let appState else { return }
        let totalWorkedSeconds = (model.totalSeconds - model.remainingSeconds) + model.overrunSeconds
        appState.updateTaskActualTime(taskId: taskId, minutes: Double(totalWorkedSeconds) / 60.0)
    }

    // In TaskTimerViewModel.swift

    private func persistTimerState() {
        let ud = UserDefaults.standard
        ud.set(startDate, forKey: startKey)
        ud.set(pauseDate, forKey: pauseKey)
        ud.set(totalPausedSeconds, forKey: pausedSumKey)

        // Manual mapping instead of rawValue
        let stateInt: Int
        switch model.state {
        case .idle: stateInt = 0
        case .running: stateInt = 1
        case .paused: stateInt = 2
        case .finished: stateInt = 3
        }
        ud.set(stateInt, forKey: stateKey)
    }

    private func restoreTimerState() {
        let ud = UserDefaults.standard
        startDate = ud.object(forKey: startKey) as? Date
        pauseDate = ud.object(forKey: pauseKey) as? Date
        totalPausedSeconds = ud.integer(forKey: pausedSumKey)

        let s = ud.integer(forKey: stateKey)
        switch s {
        case 1: model.state = .running
        case 2: model.state = .paused
        case 3: model.state = .finished
        default: model.state = .idle
        }
    }
    private func clearTimerState() {
        let ud = UserDefaults.standard
        [startKey, pauseKey, pausedSumKey, stateKey].forEach { ud.removeObject(forKey: $0) }
    }
}
