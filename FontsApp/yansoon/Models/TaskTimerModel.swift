//
//  TaskTimerModel.swift
//  yansoon
//
//  Created by Noura Faiz Alfaiz on 08/02/2026.
//

import Foundation

enum TaskTimerState: Equatable {
    case idle
    case running
    case paused
    case finished // user tapped Done
}

struct TaskTimerModel: Equatable {
    // Total planned duration (seconds) from task.estimatedMinutes
    var totalSeconds: Int
    // Seconds remaining within planned duration
    var remainingSeconds: Int
    // Seconds beyond planned duration (off-limit, red)
    var overrunSeconds: Int
    // Current state
    var state: TaskTimerState = .idle
    
    init(totalSeconds: Int, alreadyWorkedSeconds: Int = 0) {
        self.totalSeconds = max(0, totalSeconds)
        let remaining = totalSeconds - alreadyWorkedSeconds
        if remaining >= 0 {
            self.remainingSeconds = remaining
            self.overrunSeconds = 0
        } else {
            self.remainingSeconds = 0
            self.overrunSeconds = -remaining
        }
    }
    
    // 0...1 of the orange ring (planned time)
    var plannedProgress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(max(remainingSeconds, 0)) / Double(totalSeconds)
    }
    
    // Red ring progress grows from 0 upward after planned time is exhausted.
    // You can optionally clamp or scale if you want a cap. Here we map 0...totalSeconds as 0...1 for visual parity.
    var offLimitProgress: Double {
        guard totalSeconds > 0 else { return 0 }
        return min(Double(overrunSeconds) / Double(totalSeconds), 1.0)
    }
    
    var isInOffLimit: Bool {
        remainingSeconds <= 0 && overrunSeconds > 0
    }
    
    // Display time centered: if within planned time show remaining, else show +overrun
    var displayTime: String {
        if remainingSeconds > 0 {
            return Self.formatClock(remainingSeconds)
        } else {
            return "+\(Self.formatClock(overrunSeconds))"
        }
    }
    
    static func formatClock(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

