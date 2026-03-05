//
//  YansoonActivityAttributes.swift
//  yansoon
//
//  ⚠️ In Xcode: Add this file to BOTH the main app target AND the widget extension target.
//  (Select the file → File Inspector → Target Membership → tick both)
//

import ActivityKit
import Foundation

struct YansoonActivityAttributes: ActivityAttributes {

    // MARK: - Static data (set once at activity start, never changes)
    let taskTitle: String
    let estimatedSeconds: Int

    // MARK: - Dynamic data (updated as timer runs)
    struct ContentState: Codable, Hashable {
        /// Virtual start date adjusted for paused time.
        /// Use with Text(timerStartDate, style: .timer) — it ticks automatically on
        /// Lock Screen and Dynamic Island without needing per-second updates.
        var timerStartDate: Date

        /// Frozen elapsed seconds — only used for display when isPaused = true.
        var elapsedSeconds: Int

        /// Whether the timer is currently paused.
        var isPaused: Bool

        /// Whether the task has exceeded its estimated time.
        var isOverrun: Bool

        /// 0.0 → 1.0 progress through the estimated time.
        var progress: Double

        /// Exact moment estimated time runs out — used by TimelineView to
        /// auto-switch to red/frozen display even while app is suspended.
        var expiryDate: Date
    }
}
