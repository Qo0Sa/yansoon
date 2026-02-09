//
//  NotificationManger.swift
//  yansoon
//
//  Created by Rana Alngashy on 21/08/1447 AH.
//
//
//  NotificationManager.swift
//  yansoon
//
//  Created by Assistant
//  Manages energy check-in notifications based on selected energy level
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
    /// - High Energy: 3 hours (180 minutes)
    /// - Medium Energy: 90 minutes
    /// - Low Energy: 60 minutes
    func scheduleEnergyCheckIn(for energyLevel: EnergyLevel) {
        print("🔔 [NotificationManager] scheduleEnergyCheckIn called for: \(energyLevel.title)")
        
        // Cancel any existing notifications first
        cancelEnergyCheckIn()
        
        // 🧪 TEST MODE - Using seconds instead of minutes for easy testing
        let intervalSeconds: Double
        switch energyLevel {
        case .high:
            intervalSeconds = 60  // 1 minute (production: 180 minutes)
        case .medium:
            intervalSeconds = 45  // 45 seconds (production: 90 minutes)
        case .low:
            intervalSeconds = 30  // 30 seconds (production: 60 minutes)
        }
        
        print("⏱️ [NotificationManager] Will fire in \(Int(intervalSeconds)) seconds")
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Check In"
        content.body = "How's your energy level now? Let's reassess to stay balanced."
        content.sound = .default
        content.badge = 1
        
        // Add custom data to identify this notification
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
                // Verify it was added
                self.printPendingNotifications()
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
                        let minutes = Int(trigger.timeInterval / 60)
                        print("  - \(request.identifier): in \(minutes) minutes")
                    }
                }
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String, type == "energyCheckIn" {
            // Post notification to navigate to energy selection
            NotificationCenter.default.post(
                name: .showEnergySelection,
                object: nil
            )
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
