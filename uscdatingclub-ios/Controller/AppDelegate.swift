//
//  AppDelegate.swift
//  timewellspent-ios
//
//  Created by Adam Novak on 2022/11/11.
//

import Foundation
import SwiftUI
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIStackView.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).spacing = -10

        UNUserNotificationCenter.current().delegate = self
        NotificationsManager.shared.registerForNotificationsOnStartupIfAccessExists()
        
        NotificationCenter.default.addObserver(forName: .remoteConfigDidActivate, object: nil, queue: .main) { notification in
            Version.checkForNewUpdate()
        }
                
        FirebaseApp.configure()
//        Constants.fetchRemoteConfig()
        Constants.fetchRemoteConfigDebug()
                
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        LocationManager.shared.resetDistanceFilter()
    }

}


extension AppDelegate: UNUserNotificationCenterDelegate {

    // These delegate methods MUST live in App Delegate and nowhere else!
    
    //MARK: - Notification Registration
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("didRegisterForRemoteNotificationsWithDeviceToken")
        
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        setGlobalDeviceToken(token: token)
        Task {
            try await DeviceAPI.registerCurrentDeviceWithUser(user: UserService.singleton.getId())
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFAILtoRegisterForRemoteNotificationsWithError")
    }
        
    //MARK: - Notification Handling
    
    //user launched app via a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("launched app via notification")
        NotificationsManager.shared.currentlyLaunchedAppNotification = response.notification
        handleAppLaunchViaNotification(response)
        completionHandler()
    }

    //user received notification while in app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("receved notification while in app")
        Task { await handleReceivedNotificationWhileInApp(notification) }
        completionHandler([.sound]) //when the user is in the app, we don't want to do an ios system displays
    }
    
    func handleReceivedNotificationWhileInApp(_ notification: UNNotification) async {
        guard let notificationResponseHandler = NotificationsManager.shared.generateNotificationResponseHandler(notification) else {
            return
        }
        if let partner = notificationResponseHandler.newMatchPartner {
            AlertManager.showAlert(title: "you've been matched with \(partner.firstName)!", subtitle: "you have \(Constants.minutesToRespond) minutes to respond", primaryActionTitle: "see your compatibility", primaryActionHandler: {
                transitionToViewController(MatchFoundTableVC.create(matchInfo: MatchInfo(matchPartner: partner)), duration: 0.5)
            }, on: SceneDelegate.visibleViewController!)
        } else if let _ = notificationResponseHandler.newMatchAcceptance {
            NotificationCenter.default.post(name: .matchAccepted, object: nil)
        }
    }
    
    func handleAppLaunchViaNotification(_ notificationResponse: UNNotificationResponse) {
        //TODO: wait do i need to do the below?
        //isnt the below hanlded through scene delegate?
        
//        guard let notificationResponseHandler = NotificationsManager.shared.generateNotificationResponseHandler(notificationResponse.notification) else {
//            return
//        }
//        let loadingVC = LoadingVC.create()
//        loadingVC.notificationResponseHandler = notificationResponseHandler
//        transitionToViewController(loadingVC, duration: 0)
    }
    
    //MARK: - Background / silent notifications
    
//    When sending messages with the content_available key (equivalent to APNs's content-available, the messages will be delivered as silent notifications, waking your app in the background for tasks like background data refresh. Unlike foreground notifications, these notifications must be handled via the function below
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {

        
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
//      if let messageID = userInfo[gcmMessageIDKey] {
//        print("Message ID: \(messageID)")
//      }
//
//      // Print full message.
//      print(userInfo)

      return UIBackgroundFetchResult.newData
    }
    
}


