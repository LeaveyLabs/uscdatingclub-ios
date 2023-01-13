//
//  NotificationsManager.swift
//  mist-ios
//
//  Created by Adam Monterey on 8/29/22.
//

import UserNotifications
import UIKit
import FirebaseAnalytics

//MARK: - Structs

//Internal Notifications
extension Notification.Name {
    static let locationStatusDidUpdate = Notification.Name("locationStatusDidUpdate")
    static let remoteConfigDidActivate = Notification.Name("remoteConfigDidActivate")
    static let permissionsWereRevoked = Notification.Name("permissionsWereRevoked")
    static let matchAccepted = Notification.Name("matchAccepted")
    static let matchReceived = Notification.Name("matchReceived")
}

//Remote Notifications
enum NotificationTypes: String, CaseIterable {
    case match = "match"
    case accept = "accept"
}

extension Notification {
    enum extra: String {
        case type = "type"
        case data = "data"
    }
}

struct NotificationResponseHandler {
    var notificationType: NotificationTypes
    var newMatchPartner: MatchPartner?
    var newMatchAcceptance: MatchAcceptance?
}

//MARK: - NotificationsManager

class NotificationsManager: NSObject {
    
    private var center: UNUserNotificationCenter = UNUserNotificationCenter.current()
    static let shared = NotificationsManager()
    var currentlyLaunchedAppNotification: UNNotification?
    
    private override init() {
        super.init()
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
    
    //we just need to make sure to also check the currently launched notification, and make sure we don't handle anything newer than that

    func checkPreviouslyReceivedNotifications() {
        Task {
            guard await isNotificationsEnabled() else { return }
            print("most recent saved notification", mostRecentSavedNotification())
            
            //The below function returns all the notifications currently visible in the NotificationCenter on their device
            //As soon as the user clicks on a notification to open the app, that notification is gone from the notification center (and thus won't be returned from the below function). That action should be handled in AppDelegate
            let notifications = await center.deliveredNotifications().sorted(by: { $0.date.isMoreRecentThan($1.date)} )
                        
            let threeMinsAgo = Calendar.current.date(byAdding: .minute, value: -3, to: Date())!
            guard let mostRecentReceivedNotif = notifications.first ?? mostRecentSavedNotification(), mostRecentReceivedNotif.date.isMoreRecentThan(threeMinsAgo) else {
                return
            }
            print("opened app with delivered notifications:", notifications)

            if let currentlyLaunchedAppNotification {
                guard mostRecentReceivedNotif.date.isMoreRecentThan(currentlyLaunchedAppNotification.date) else {
                    return
                }
            }
                        
            let notificationResponseHandler = generateNotificationResponseHandler(mostRecentReceivedNotif)
            
            DispatchQueue.main.async {
                let loadingVC = LoadingVC.create(notificationResponseHandler: notificationResponseHandler)
                transitionToViewController(loadingVC, duration: 0)
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
    
    func generateNotificationResponseHandler(_ notification: UNNotification) -> NotificationResponseHandler? {
        guard
            let userInfo = notification.request.content.userInfo as? [String : AnyObject],
            let notificationTypeString = userInfo[Notification.extra.type.rawValue] as? String,
            let notificationType = NotificationTypes.init(rawValue: notificationTypeString)
        else { return nil }
        
        saveNotification(notification)
        
        do {
            var handler = NotificationResponseHandler(notificationType: notificationType)
            switch notificationType {
                case .match:
                    guard let json = userInfo[Notification.extra.data.rawValue] else { return nil }
                    let data = try JSONSerialization.data(withJSONObject: json as Any, options: .prettyPrinted)
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    handler.newMatchPartner = try decoder.decode(MatchPartner.self, from: data)
                case .accept:
                    guard let json = userInfo[Notification.extra.data.rawValue] else { return nil }
                    let data = try JSONSerialization.data(withJSONObject: json as Any, options: .prettyPrinted)
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    handler.newMatchAcceptance = try decoder.decode(MatchAcceptance.self, from: data)
            }
            return handler
        } catch {
            let analyticsId = "notiifcation"
            let analyticsTitle = "displayingVCafterRemoteNotificationFailed"
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
              AnalyticsParameterItemID: "id-\(analyticsId)",
              AnalyticsParameterItemName: analyticsTitle,
            ])
            return nil
        }
    }
    
    //MARK: - Local Storage
    
    let MostRecentNotifiationStorageKey: String = "mostRecentNotification"
    
    func mostRecentSavedNotification() -> UNNotification? {
        return UserDefaults.standard.object(forKey: MostRecentNotifiationStorageKey) as? UNNotification ?? nil
    }
    
    func saveNotification(_ notification: UNNotification) {
        Task {
            UserDefaults.standard.setValue(notification, forKey: MostRecentNotifiationStorageKey)
        }
    }
        
}
