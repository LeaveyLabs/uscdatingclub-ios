//
//  LaunchViewController.swift
//  mist-ios
//
//  Created by Adam Novak on 2022/06/06.
//

import UIKit
import FirebaseAnalytics

func loadEverything() async throws {
    try await withThrowingTaskGroup(of: Void.self) { group in
//        group.addTask { try await ConversationService.singleton.loadInitialMessageThreads() }
//        group.addTask { await UsersService.singleton.loadUsersAssociatedWithContacts() }
        try await group.waitForAll()
    }
}

class LoadingVC: UIViewController {
    
    //MARK: - Properties
    
    //UI
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Flags
    var didLoadEverything = false
    var wasUpdateFoundAvailable = false
    var notificationResponseHandler: NotificationResponseHandler?
    
    //MARK: - Initialization
    
    class func create(notificationResponseHandler: NotificationResponseHandler? = nil) -> LoadingVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Misc, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.Loading) as! LoadingVC
        print("HANDLER:", notificationResponseHandler)
        vc.notificationResponseHandler = notificationResponseHandler
        return vc
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if notificationResponseHandler != nil {
            goToNotification()
        } else {
            goToHome()
        }
    }
    
    //MARK: - GoTos
    
//    func goToAuth() {
//        DispatchQueue.main.asyncAfter(deadline: .now()) {
//            guard !self.wasUpdateFoundAvailable else { return }
//            transitionToStoryboard(storyboardID: Constants.SBID.SB.Auth,
//                                   duration: 0) { _ in}
//        }
//    }
    
    func goToHome() {
        DispatchQueue.main.async {
            transitionToStoryboard(storyboardID: Constants.SBID.SB.Main,
                                    duration: 0) { _ in }
        }
    }
    
    func goToNotification() {
        setupDelayedActivityIndicator()
        Task {
            try await loadAndGoToNotification(failCount: 0)
        }
    }
    
    func loadAndGoToNotification(failCount: Int) async throws {
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { try await loadEverything() }
                group.addTask { try await self.loadNotificationData() }
                try await group.waitForAll()
            }
            didLoadEverything = true
            guard !wasUpdateFoundAvailable else { return }
            DispatchQueue.main.async {
                self.transitionToNotificationScreen()
            }
        } catch {
            try await handleInitialLoadError(error, reloadType: .notification, failCount: failCount)
        }
    }
    
    //MARK: - Notifications
    
    @MainActor
    func transitionToNotificationScreen() {
        guard let handler = notificationResponseHandler else { return }
        
        switch handler.notificationType {
        case .match:
            guard let matchPartner = handler.newMatchPartner else {
                fatalError()
            }
            let matchInfo = MatchInfo(matchPartner: matchPartner)
            let matchFoundTableVC = MatchFoundTableVC.create(matchInfo: matchInfo)
            transitionToViewController(matchFoundTableVC, duration: 0) { _ in }
        case .accept:
            guard let acceptance = handler.newMatchAcceptance else {
                fatalError()
                //TODO: post to crashlytics
            }
            let matchInfo = MatchInfo(matchAcceptance: acceptance)
            let coordinateVC = CoordinateVC.create(matchInfo: matchInfo)
            transitionToViewController(coordinateVC, duration: 0) { _ in }
        default:
            break
        }
    }
    
    func loadNotificationData() async throws {
        guard let handler = notificationResponseHandler else { return }
        switch handler.notificationType {
            default:
                break
        }
    }
    
    //MARK: - Helpers
    
    func setupDelayedActivityIndicator() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self, !self.didLoadEverything else { return }
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    enum InitialReloadType {
        case notification
    }
    
    func handleInitialLoadError(_ error: Error, reloadType: InitialReloadType, failCount: Int) async throws {
        if let apiError = error as? APIError, apiError == .Unauthorized {
            try await UserService.singleton.kickUserToHomeScreenAndLogOut()
            return
        }
        if failCount >= 2 {
            AlertManager.displayError(error)
        }
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 3)
        switch reloadType {
        case .notification:
            try await self.loadAndGoToNotification(failCount: failCount + 1)
        }
    }
    
}
