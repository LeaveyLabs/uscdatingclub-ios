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
    
    func getNotificationStatus()async -> UNAuthorizationStatus {
        return await center.notificationSettings().authorizationStatus
    }
    
    func isNotificationsEnabled() async -> Bool {
        return await center.notificationSettings().authorizationStatus == .authorized
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
    
    func handleExistingNotifications() {
        Task {
            guard await isNotificationsEnabled() else { return }
            
//            let notificationRequests = await UNUserNotificationCenter.current().pendingNotificationRequests() //this is just for local notifications
            
            //The below function returns all the notifications currently visible in the NotificationCenter on their device
            //As soon as the user clicks on a notification to open the app, that notification is gone from the notification center (and thus won't be returned from the below function). That action should be handled in AppDelegate
            let notifications = await UNUserNotificationCenter.current().deliveredNotifications()
            guard notifications.count > 0 else { return }
            print("opened app with delivered notifications:", notifications)
            
//            DispatchQueue.main.async {
//                UIApplication.shared.applicationIconBadgeNumber = 0
//            }
//            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
    
    //TODO: save matchInfo notification in userDefaults as "mostRecentMatchInfo" after receiving it from anywhere in the code
    //if it appears you don't have any notifications, as one last check, check userDefaults to make sure you don't have an existing match
        
}
