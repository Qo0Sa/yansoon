//
//  NotificationManger.swift
//  yansoon
//


import Foundation
import UserNotifications
import UIKit
import Combine

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let energyCheckInIdentifier = "energyCheckIn"
    
    override init() {
        super.init()
        // Critical: Set delegate immediately to handle taps
        notificationCenter.delegate = self
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                authorizationStatus = granted ? .authorized : .denied
            }
            return granted
        } catch {
            print("❌ Notification authorization error: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() {
        Task {
            let settings = await notificationCenter.notificationSettings()
            await MainActor.run {
                authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    // MARK: - Schedule Energy Check-In
    
    /// Schedules a notification based on the current energy level
    func scheduleEnergyCheckIn(for energyLevel: EnergyLevel) {
        print("🔔 [NotificationManager] scheduleEnergyCheckIn called for: \(energyLevel.title)")
        
        // Cancel any existing notifications first to avoid duplicates
        cancelEnergyCheckIn()
        
        // 🧪 TEST MODE - Using seconds instead of minutes for easy testing
        // Change these values back to * 60 for minutes when releasing the app
        let intervalSeconds: Double
        switch energyLevel {
        case .high:
            intervalSeconds = 10  // 10 seconds (Quick test)
        case .medium:
            intervalSeconds = 20  // 20 seconds
        case .low:
            intervalSeconds = 30  // 30 seconds
        }
        
        print("⏱️ [NotificationManager] Will fire in \(Int(intervalSeconds)) seconds")
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Check In ⚡️"
        content.body = "How is your energy level now? Tap to reassess."
        content.sound = .default
        content.badge = 1
        
        // Add custom data to identify this notification type
        content.userInfo = [
            "type": "energyCheckIn",
            "energyLevel": energyLevel.rawValue
        ]
        
        // Create trigger (time interval in seconds)
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: intervalSeconds,
            repeats: false
        )
        
        // Create request
        let request = UNNotificationRequest(
            identifier: energyCheckInIdentifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ [NotificationManager] Failed to schedule: \(error)")
            } else {
                print("✅ [NotificationManager] Successfully scheduled for \(energyLevel.title) in \(Int(intervalSeconds)) seconds")
            }
        }
    }
    
    // MARK: - Cancel Notifications
    
    func cancelEnergyCheckIn() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [energyCheckInIdentifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [energyCheckInIdentifier])
        print("🗑️ Cancelled energy check-in notifications")
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // MARK: - Debugging
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
    
    func printPendingNotifications() {
        Task {
            let pending = await getPendingNotifications()
            if pending.isEmpty {
                print("📭 No pending notifications")
            } else {
                print("📬 Pending notifications:")
                for request in pending {
                    if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                        print("  - \(request.identifier): fires in approx \(Int(trigger.timeInterval)) seconds")
                    }
                }
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in FOREGROUND (so banner still appears)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner, sound, and badge even if app is open
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification TAP (Click)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Check if this is our energy check-in notification
        if let type = userInfo["type"] as? String, type == "energyCheckIn" {
            print("👆 Notification Tapped! Posting .showEnergySelection event...")
            
            // Post notification to SwiftUI to open the Sheet
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .showEnergySelection,
                    object: nil
                )
            }
        }
        
        // Clear badge
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let showEnergySelection = Notification.Name("showEnergySelection")
}
