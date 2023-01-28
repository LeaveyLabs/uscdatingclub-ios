//
//  PermissionsVC.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2022/12/29.
//

import UIKit

class PermissionsVC: UIViewController {
    
    @IBOutlet var notificationsButton: SimpleButton!
    @IBOutlet var locationButton: SimpleButton!
    @IBOutlet var backgroundRefreshButton: SimpleButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var noNotificationsButton: SimpleButton!
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var label3: UILabel!
    @IBOutlet var checkmarkImageView1: UIImageView!
    @IBOutlet var checkmarkImageView2: UIImageView!
    @IBOutlet var checkmarkImageView3: UIImageView!

    let NOTALLOWED_ALPHA = 0.5

    var goodToGo: Bool {
        checkmarkImageView1.alpha == 1 && checkmarkImageView2.alpha == 1 && (checkmarkImageView3.alpha == 1 || declinedNotifications)
    }
    
    var declinedNotifications: Bool = false

    //MARK: - Initialization
    
    class func create() -> PermissionsVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Misc, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.Permissions) as! PermissionsVC
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        rerender()
        titleLabel.font = AppFont.bold.size(30)
        label1.font = AppFont2.regular.size(15)
        label2.font = AppFont2.regular.size(15)
        label3.font = AppFont2.regular.size(15)

        NotificationCenter.default.addObserver(self, selector: #selector(delayedRerender), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onResignActive), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(delayedRerender), name: .locationStatusDidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(delayedRerender), name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateUnallowedViews()
        
        if goodToGo {
            finishWithProperPermissions()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Setup
    
    func setupButtons() {
        locationButton.internalButton.addTarget(self, action: #selector(locationButtonDidTapped), for: .touchUpInside)
        notificationsButton.internalButton.addTarget(self, action: #selector(notificationsButtonDidTapped), for: .touchUpInside)
        backgroundRefreshButton.internalButton.addTarget(self, action: #selector(backgroundRefreshButtonDidTapped), for: .touchUpInside)
        noNotificationsButton.internalButton.addTarget(self, action: #selector(noNotificationsButtonPressed), for: .touchUpInside)
        noNotificationsButton.internalButton.titleLabel?.font = AppFont.medium.size(12)
        noNotificationsButton.configure(title: "continue without notifications", systemImage: "")
        noNotificationsButton.alpha = NOTALLOWED_ALPHA
    }
    
    @objc func onResignActive() {
        if locationButton.alpha < 1 {
            locationButton.alpha = NOTALLOWED_ALPHA
            locationButton.transform = .identity
            locationButton.layer.removeAllAnimations()
        }
        if backgroundRefreshButton.alpha < 1 {
            backgroundRefreshButton.alpha = NOTALLOWED_ALPHA
            backgroundRefreshButton.transform = .identity
            backgroundRefreshButton.layer.removeAllAnimations()
        }
        if notificationsButton.alpha < 1 {
            notificationsButton.alpha = NOTALLOWED_ALPHA
            notificationsButton.transform = .identity
            notificationsButton.layer.removeAllAnimations()
        }
    }
    
    @objc func delayedRerender() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            animateUnallowedViews()
            rerender()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [self] in
                if goodToGo {
                    finishWithProperPermissions()
                }
            }
        }
    }
    
    func finishWithProperPermissions() {
        Task {
            do {
                try await UserService.singleton.updateMatchableStatus(active:true)
            } catch {
                //TODO: log to firebase
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) { [self] in
                if let _ = parent as? UINavigationController {
                    transitionToStoryboard(storyboardID: Constants.SBID.SB.Main, duration: 0.5)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        AlertManager.showInfoCentered("you're all set", "\nwhile active, your phone will scan for matches in your immediate area.\n\njust live your life and wait for a notification!", on: SceneDelegate.visibleViewController!)
                    }
                } else {
                    dismiss(animated: true)
                }
            }
        }
    }
    
    //for each non approved view, animate it
    func animateUnallowedViews() {
        if locationButton.alpha < 1 {
            UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction]) { [self] in
                locationButton.alpha = 0.7
                locationButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
        }
        if backgroundRefreshButton.alpha < 1 {
            UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction]) { [self] in
                backgroundRefreshButton.alpha = 0.7
                backgroundRefreshButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
        }
        if notificationsButton.alpha < 1 {
            UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction]) { [self] in
                notificationsButton.alpha = 0.7
                notificationsButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
        }
    }
    
    @objc func rerender() {
        if LocationManager.shared.isLocationServicesProperlyAuthorized() {
            DispatchQueue.main.async { [self] in
                locationButton.alpha = 1
                checkmarkImageView1.alpha = 1
                locationButton.layer.removeAllAnimations()
                locationButton.configure(title: "location enabled",  systemImage: "location")
            }
        } else {
            DispatchQueue.main.async { [self] in
                locationButton.alpha = NOTALLOWED_ALPHA
                checkmarkImageView1.alpha = 0
                locationButton.configure(title: "share location", subtitle: "precise, always",  systemImage: "location")
            }
        }
        
        if UIApplication.shared.backgroundRefreshStatus == .available || ProcessInfo.processInfo.isLowPowerModeEnabled {
            backgroundRefreshButton.alpha = 1
            backgroundRefreshButton.layer.removeAllAnimations()
            checkmarkImageView2.alpha = 1
            backgroundRefreshButton.configure(title: "background app refresh enabled",  systemImage: "arrow.clockwise.circle")
        } else {
            backgroundRefreshButton.alpha = NOTALLOWED_ALPHA
            checkmarkImageView2.alpha = 0
            backgroundRefreshButton.configure(title: "turn on background app refresh",  systemImage: "arrow.clockwise.circle")
        }
        
        Task {
            let isEnabled = await NotificationsManager.shared.isNotificationsEnabled()
            DispatchQueue.main.async { [self] in
                if isEnabled || declinedNotifications {
                    notificationsButton.alpha = 1
                    noNotificationsButton.alpha = 0
                    checkmarkImageView3.alpha = 1
                    notificationsButton.layer.removeAllAnimations()
                    checkmarkImageView3.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: isEnabled ? [.customWhite, .customGreen, .customGreen] : [.customWhite, .gray, .gray]))
                    notificationsButton.configure(title: isEnabled ? "notifications enabled" : "notifications disabled", systemImage: "bell")
                } else {
                    notificationsButton.alpha = NOTALLOWED_ALPHA
                    checkmarkImageView3.alpha = 0
                    notificationsButton.configure(title: "turn on notifications", systemImage: "bell")
                }
            }
        }
    }
    
    //MARK: - Interaction
    
    @MainActor
    @objc func noNotificationsButtonPressed() {
        AlertManager.showAlert(
            title: "are you sure?",
            subtitle: "you only get \(Constants.minutesToRespond) minutes to respond to your match.\n\nwithout notifications, you'll probably miss your chance each time.",
            primaryActionTitle: "continue without notifications",
            primaryActionHandler: {
            DispatchQueue.main.async { [self] in
                declinedNotifications = true
                rerender()
                delayedRerender()
            }
        }, secondaryActionTitle: "go back", secondaryActionHandler: {
            //do nothing
        }, on: self)
    }
    
    @objc func locationButtonDidTapped() {
        do {
            if LocationManager.shared.locationStatus == .notDetermined  {
                AlertManager.showLocationDemoController(on: self)
            } else {
                try LocationManager.shared.requestPermissionServices()
            }
        } catch {
            AlertManager.showSettingsAlertController(title: "\(Constants.appDisplayName) requires \"always, precise\" location to work properly", message: "", settingsType: .location, on: self)
        }
    }
    
    @objc func notificationsButtonDidTapped() {
        NotificationsManager.shared.askForNewNotificationPermissionsIfNecessary { granted in
            DispatchQueue.main.async { [self] in
                if !granted {
                    AlertManager.showSettingsAlertController(title: "turn on notifications in settings", message: "", settingsType: .notifications, on: self)
                } else {
                    rerender()
                }
            }
        }
    }
    
    @objc func backgroundRefreshButtonDidTapped() {
        if UIApplication.shared.backgroundRefreshStatus != .available && !ProcessInfo.processInfo.isLowPowerModeEnabled {
            AlertManager.showSettingsAlertController(title: "turn on background app refresh in settings", message: "", settingsType: .backgroundRefresh, on: SceneDelegate.visibleViewController!)
        }
    }

}

//we use new Apple APIs for minimal battery usage and don’t save any location data.
