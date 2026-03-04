import Foundation
import SwiftUI
import Combine
import UserNotifications

@MainActor
final class TaskTimerViewModel: ObservableObject {
    @Published private(set) var model: TaskTimerModel
    @Published private(set) var isRunning: Bool = false
    @Published var showTimeExceededAlert: Bool = false

    let taskId: UUID
    let taskTitle: String
    let estimatedMinutes: Double

    weak var appState: AppStateViewModel?
    private var tickingTask: Task<Void, Never>?

    // Date-based state
    private var startDate: Date?
    private var pauseDate: Date?
    private var totalPausedSeconds: Int = 0
    private var hasHandledOverrun: Bool = false

    // Reliable foreground tracking via NotificationCenter
    private var isAppInForeground: Bool = true
    private var foregroundObserver: NSObjectProtocol?
    private var backgroundObserver: NSObjectProtocol?

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

        // Track foreground/background reliably
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.isAppInForeground = true
            // Cancel the overrun notification that was sent while in background
            // so it doesn't pop up as a banner now that user is back in the app
            // Cancel pre-scheduled overrun notification — we'll handle it in-app instead
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: ["overrun-\(self.taskId.uuidString)"]
            )
            UNUserNotificationCenter.current().removeDeliveredNotifications(
                withIdentifiers: ["overrun-\(self.taskId.uuidString)"]
            )
            // If overrun happened while away, show the in-app alert now
            if self.hasHandledOverrun && self.model.state == .paused {
                self.showTimeExceededAlert = true
            }
        }
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.isAppInForeground = false
            // Pre-schedule overrun notification for exact expiry time so iOS
            // delivers it even while the app is fully suspended
            self.scheduleOverrunNotificationIfNeeded()
        }
    }

    deinit {
        tickingTask?.cancel()
        if let obs = foregroundObserver { NotificationCenter.default.removeObserver(obs) }
        if let obs = backgroundObserver { NotificationCenter.default.removeObserver(obs) }
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
        // Cancel pre-scheduled overrun notification when user manually pauses
        cancelOverrunNotification()
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
        // After the overrun was handled, hasHandledOverrun stays true so no re-notification
        // But if user resumed before overrun, refresh the pre-scheduled notification timing
        if !hasHandledOverrun {
            scheduleOverrunNotificationIfNeeded()
        }
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
        cancelOverrunNotification()
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
            
            // Auto-pause on overrun — only once, guarded so resume works freely after
            if model.overrunSeconds >= 10 && model.state == .running && !hasHandledOverrun {
                hasHandledOverrun = true
                pause()
                if isAppInForeground {
                    // In-app → show alert directly in TaskTimerView
                    showTimeExceededAlert = true
                }
                // If out-of-app: notification was already pre-scheduled when app backgrounded
            }
        }
    }

    /// Pre-schedules overrun notification for exactly when estimated time expires.
    /// iOS delivers this even when the app is fully suspended.
    private func scheduleOverrunNotificationIfNeeded() {
        guard let start = startDate,
              model.state == .running,
              !hasHandledOverrun else { return }

        let expiryDate = start.addingTimeInterval(Double(model.totalSeconds + totalPausedSeconds))
        let secondsUntilExpiry = expiryDate.timeIntervalSinceNow

        guard secondsUntilExpiry > 0 else { return }

        cancelOverrunNotification() // remove any stale one first

        let identifier = "overrun-\(taskId.uuidString)"
        let content = UNMutableNotificationContent()
        content.title = "Time Exceeded!"
        content.body = "Your task timer has been paused. Open Yansoon to continue."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: secondsUntilExpiry, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelOverrunNotification() {
        let identifier = "overrun-\(taskId.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
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
