//
//  NotificationManger.swift
//  yansoon
//
//  Created by Rana Alngashy on 21/08/1447 AH.
//

import Foundation
import UserNotifications
import Combine
import UIKit

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
        cancelEnergyCheckIn()
        
        // 🧪 TEST MODE - Change minutes to seconds
        let intervalSeconds: Double  // Changed from intervalMinutes
        switch energyLevel {
        case .high:
            intervalSeconds = 60      // 1 minute (was 180 minutes)
        case .medium:
            intervalSeconds = 45      // 45 seconds (was 90 minutes)
        case .low:
            intervalSeconds = 30      // 30 seconds (was 60 minutes)
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Check In"
        content.body = "How's your energy level now? Let's reassess to stay balanced."
        content.sound = .default
        content.badge = 1
        
        content.userInfo = [
            "type": "energyCheckIn",
            "energyLevel": energyLevel.rawValue
        ]
        
        // Change this line - remove the * 60
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: intervalSeconds,  // Was: intervalMinutes * 60
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: energyCheckInIdentifier,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            } else {
                print("✅ Scheduled energy check-in notification for \(energyLevel.title) in \(Int(intervalSeconds)) SECONDS")  // Update print
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
