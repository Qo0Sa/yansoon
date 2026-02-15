//
//  TaskTimerViewModel.swift
//  yansoon
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

    // ✅ Date-based
    private var startDate: Date?
    private var pauseDate: Date?
    private var totalPausedSeconds: Int = 0

    // ✅ keys
    private var keyPrefix: String { "task_timer_\(taskId.uuidString)" }
    private var startKey: String { "\(keyPrefix)_start" }
    private var pauseKey: String { "\(keyPrefix)_pause" }
    private var pausedSumKey: String { "\(keyPrefix)_pausedSum" }
    private var stateKey: String { "\(keyPrefix)_state" } // 0 idle, 1 running, 2 paused, 3 finished

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

        // لو كان Running قبل والخلفية وقفتنا، نرجع نحدث UI فقط
        if model.state == .running {
            isRunning = true
            startTickingUIOnly()
        }
    }

    deinit {
        tickingTask?.cancel()
    }

    // MARK: - Public
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
        stopTicking()
        isRunning = false
        recalcFromClock()
        model.state = .finished

        persistProgress()      // ✅ بدون markCompleted
        clearTimerState()
    }


    /// ✅ نستخدمها لما يرجع التطبيق foreground أو onAppear
    func syncNow() {
        recalcFromClock()
        persistProgress()
    }

    // MARK: - UI refresh only
    private func startTickingUIOnly() {
        stopTicking()
        tickingTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // تحديث UI
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

    // MARK: - Date-based calculation
    private func recalcFromClock() {
        guard let start = startDate else { return }

        let totalAllocated = model.totalSeconds
        let now = Date()

        // لو paused نحسب لحد وقت الوقف
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
        }
    }

    // MARK: - Persist worked time to AppState (نفس فكرتك)
    private func persistProgress(markCompleted: Bool = false) {
        guard let appState else { return }

        let workedWithinPlan = model.totalSeconds - max(model.remainingSeconds, 0)
        let totalWorkedSeconds = max(0, workedWithinPlan) + max(0, model.overrunSeconds)
        let totalWorkedMinutes = Double(totalWorkedSeconds) / 60.0

        appState.updateTaskActualTime(taskId: taskId, minutes: totalWorkedMinutes)

      
    }

    // MARK: - UserDefaults state
    private func persistTimerState() {
        let ud = UserDefaults.standard
        ud.set(startDate, forKey: startKey)
        ud.set(pauseDate, forKey: pauseKey)
        ud.set(totalPausedSeconds, forKey: pausedSumKey)

        let s: Int
        switch model.state {
        case .idle: s = 0
        case .running: s = 1
        case .paused: s = 2
        case .finished: s = 3
        }
        ud.set(s, forKey: stateKey)
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
        default: break
        }
    }

    private func clearTimerState() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: startKey)
        ud.removeObject(forKey: pauseKey)
        ud.removeObject(forKey: pausedSumKey)
        ud.removeObject(forKey: stateKey)
    }
}
