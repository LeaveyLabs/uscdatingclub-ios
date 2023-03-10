//
//  SceneDelegate.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2022/12/28.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    //MARK: - Properties
    
    var window: UIWindow?
    
    static var visibleViewController: UIViewController? {
        get {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let delegate = windowScene.delegate as? SceneDelegate, let window = delegate.window else { return nil }
            guard let rootVC = window.rootViewController else { return nil }
            return getVisibleViewController(rootVC)
        }
    }
    
    static private func getVisibleViewController(_ rootViewController: UIViewController) -> UIViewController? {
        if let presentedViewController = rootViewController.presentedViewController {
            return getVisibleViewController(presentedViewController)
        }

        if let navigationController = rootViewController as? UINavigationController {
            return navigationController.visibleViewController
        }

        if let tabBarController = rootViewController as? UITabBarController {
            if let selectedTabVC = tabBarController.selectedViewController {
                return getVisibleViewController(selectedTabVC)
            }
            return tabBarController
        }

        return rootViewController
    }
    
    //MARK: - Helpers
    
    
    
    //MARK: - SceneDelegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        if !UserService.singleton.isLoggedIntoAnAccount {
            window.rootViewController = UIStoryboard(name: Constants.SBID.SB.Auth, bundle: nil).instantiateInitialViewController()
        } else {
            let loadingVC = LoadingVC.create()
            if let notification = connectionOptions.notificationResponse?.notification,
               let notificationResponseHandler = NotificationsManager.shared.generateNotificationResponseHandler(notification) {
                loadingVC.notificationResponseHandler = notificationResponseHandler
            }
            window.rootViewController = loadingVC
        }

        if let isOnWaitList = UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.isOnWaitList) as? Bool,
           isOnWaitList {
            window.rootViewController = UIStoryboard(name: Constants.SBID.SB.Auth, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.WaitList)
        }
        
        window.makeKeyAndVisible()

    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
        NotificationsManager.shared.checkPreviouslyReceivedMatchNotification()
        PermissionsManager.ensureNecessaryPermissionsAreGranted()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

