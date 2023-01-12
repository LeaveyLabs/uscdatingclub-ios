//
//  NotificationsManager.swift
//  mist-ios
//
//  Created by Adam Monterey on 8/29/22.
//

import UserNotifications
import UIKit

extension Notification.Name {
    static let locationStatusDidUpdate = Notification.Name("locationStatusDidUpdate")
    static let remoteConfigDidActivate = Notification.Name("remoteConfigDidActivate")
    static let permissionsWereRevoked = Notification.Name("permissionsWereRevoked")
    static let matchAccepted = Notification.Name("matchAccepted")
    static let matchReceived = Notification.Name("matchReceived")
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
    
    func isNotificationsEnabled(closure: @escaping (Bool) -> Void) {
        center.getNotificationSettings { setting in
            closure(setting.authorizationStatus == .authorized)
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
                closure(false)
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
