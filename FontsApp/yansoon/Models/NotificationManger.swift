//
//  NotificationManager.swift
//  yansoon
//

import Foundation
import UserNotifications
import UIKit

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        // ✅ Set the delegate so we can control how notifications appear
        UNUserNotificationCenter.current().delegate = self
    }
    
    /// Requests user permission for notifications
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
            print(granted ? "✅ Notification Permission Granted" : "❌ Notification Permission Denied")
            return granted
        } catch {
            print("❌ Authorization Error: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Sends immediate local notifications
    func sendImmediateNotification(title: String, body: String) {
        // 1. Check permissions first (Debug Step)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("⚠️ Cannot send notification: Permission not authorized. Status: \(settings.authorizationStatus.rawValue)")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            content.badge = 0
            
            // Trigger in 1 second
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("🚀 Notification scheduled: \(title)")
                }
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    // MARK: - UNUserNotificationCenterDelegate Methods
    
    // ✅ This function ensures the notification shows up even if the app is open (Foreground)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show Banner and Sound even if app is open
        completionHandler([.banner, .sound, .list])
    }
    
    // Handle tapping the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("👆 User tapped notification")
        
        // This posts the notification that AppStateViewModel listens for (Part 3)
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        
        completionHandler()
    }
}
