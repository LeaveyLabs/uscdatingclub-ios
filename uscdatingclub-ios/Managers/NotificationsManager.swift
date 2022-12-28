//
//  NotificationsManager.swift
//  mist-ios
//
//  Created by Adam Monterey on 8/29/22.
//

import Foundation
import UserNotifications
import UIKit

enum NotificationTypes: String {
    case tag = "tag"
    case message = "message"
    case match = "match"
    case comment = "comment"
}

//extension Notification.Name {
//    static let newMistboxMist = Notification.Name("newMistboxMist")
//    static let newDM = Notification.Name("newDM")
//    static let newMentionedMist = Notification.Name("tag")
//}

extension Notification {
    enum extra: String {
        case type = "type"
        case data = "data"
    }
}

class NotificationsManager: NSObject {
    
    private var center: UNUserNotificationCenter = UNUserNotificationCenter.current()
    static let shared = NotificationsManager()
    
    private override init() {
        super.init()
    }
    
    //MARK: - Posting
    
    func post() {
//        NotificationCenter.default.post(name: .newDM,
//                                        object: nil,
//                                        userInfo:[Notification.Key.key1: "value", "key1": 1234])
    }
    
    //MARK: - Permission and Status
    
    func getNotificationStatus(closure: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { setting in
            closure(setting.authorizationStatus)
        }
    }
    
    func registerForNotificationsOnStartupIfAccessExists() {
        center.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    print("REGISTERED FOR NOTIFICATIONS")
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        })
    }
    
    func askForNewNotificationPermissionsIfNecessary(closure: @escaping (_ granted: Bool) -> Void = { _ in } ) {
        center.getNotificationSettings(completionHandler: { [self] (settings) in
            switch settings.authorizationStatus {
            case .denied:
                DispatchQueue.main.async {
                    //swift messages?
                    
//                    AlertManager.showSettingsAlertController(title: "share notifications in settings", message: "", on: controller) { approved in
//                        closure(approved)
//                    }
                }
            case .notDetermined:
                self.center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                    if granted {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                    closure(granted)
                }
            default:
                closure(true)
            }
        })
    }
        
}
