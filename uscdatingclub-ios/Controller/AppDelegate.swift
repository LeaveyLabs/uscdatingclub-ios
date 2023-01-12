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
        
    //MARK: - Alert Notifications
    
    //user was not in app
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("will present notification while NOT in app")

        guard var visibleVC = SceneDelegate.visibleViewController else {
            return //the app wasn't running in the background. scene delegate will handle
        }
        //delete the below if the above works
//        guard var _ = UIApplication.shared.windows.first?.rootViewController else {
//            return
//        }
                
//        let loadingVC = UIStoryboard(name: Constants.SBID.SB.Misc, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.Loading) as! LoadingVC
//        if let notificationResponseHandler = generateNotificationResponseHandler(response) {
//            loadingVC.notificationResponseHandler = notificationResponseHandler
//        }
//        visibleVC = loadingVC
////        UIApplication.shared.windows.first?.rootViewController = loadingVC
//
//        completionHandler()
    }

    //user was in app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("will present notification while in app")
        
        Task {
            await handleNotificationWhileInApp(notification)
        }
                
        completionHandler([.sound]) //when the user is in the app, we don't want to do an ios system displays
    }
    
    func handleNotificationWhileInApp(_ notification: UNNotification) async {
        guard let notificationResponseHandler = generateNotificationResponseHandler(notification) else {
            return
        }
        if let partner = notificationResponseHandler.newMatchPartner {
            DispatchQueue.main.async {
                transitionToViewController(MatchFoundVC.create(matchInfo: MatchInfo(matchPartner: partner)), duration: 0.5)
            }
        } else if let _ = notificationResponseHandler.newMatchAcceptance {
            //TODO: open socket?
            NotificationCenter.default.post(name: .matchAccepted, object: nil)
        }
    }
    
    //MARK: - Background / silent notifications
    
//    When sending messages with the content_available key (equivalent to APNs's content-available, the messages will be delivered as silent notifications, waking your app in the background for tasks like background data refresh. Unlike foreground notifications, these notifications must be handled via the function below
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {
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


