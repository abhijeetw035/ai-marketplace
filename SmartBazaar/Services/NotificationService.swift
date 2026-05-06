import UserNotifications
import Foundation

// MARK: - Push Notification Service

final class NotificationService {
    static let shared = NotificationService()
    private init() {}
    
    // MARK: - Permission
    
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("NotificationService: Permission error — \(error)")
            return false
        }
    }
    
    // MARK: - Local Notification Triggers
    
    /// Called when a new message arrives while the app is in the foreground
    func scheduleMessageNotification(senderName: String, preview: String, chatId: String) {
        let content = UNMutableNotificationContent()
        content.title = senderName
        content.body = preview
        content.sound = .default
        content.badge = 1
        content.userInfo = ["chat_id": chatId, "type": "message"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: "msg_\(chatId)_\(UUID().uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Notify seller when their listing gets saved to a wishlist
    func scheduleWishlistNotification(listingTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "Someone saved your listing!"
        content.body = ""\(listingTitle)" was added to a buyer's wishlist."
        content.sound = .default
        content.userInfo = ["type": "wishlist_save"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(identifier: "wishlist_\(UUID().uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Notify when offline sync finishes
    func scheduleSyncCompleteNotification(count: Int) {
        guard count > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "You're back online"
        content.body = "\(count) pending action\(count == 1 ? "" : "s") synced successfully."
        content.sound = .default
        content.userInfo = ["type": "sync_complete"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: "sync_\(UUID().uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Badge Reset
    
    func resetBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
