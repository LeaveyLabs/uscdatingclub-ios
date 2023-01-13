//
//  PermissionsVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2022/12/29.
//

import UIKit

class PermissionsVC: UIViewController {
    
    @IBOutlet var notificationsButton: SimpleButton!
    @IBOutlet var locationButton: SimpleButton!
    @IBOutlet var backgroundRefreshButton: SimpleButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var learnMoreButton: UIButton!
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var label3: UILabel!
    @IBOutlet var checkmarkImageView1: UIImageView!
    @IBOutlet var checkmarkImageView2: UIImageView!
    @IBOutlet var checkmarkImageView3: UIImageView!

    let GOODTOGO_ALPHA = 0.5

    var goodToGo: Bool {
        false
//        view1.alpha == GOODTOGO_ALPHA && view2.alpha == GOODTOGO_ALPHA && view3.alpha == GOODTOGO_ALPHA
    }

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

        NotificationCenter.default.addObserver(self, selector: #selector(delayedRerender), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(delayedRerender), name: .locationStatusDidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(delayedRerender), name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Setup
    
    func setupButtons() {
        locationButton.internalButton.addTarget(self, action: #selector(locationButtonDidTapped), for: .touchUpInside)
        notificationsButton.internalButton.addTarget(self, action: #selector(notificationsButtonDidTapped), for: .touchUpInside)
        backgroundRefreshButton.internalButton.addTarget(self, action: #selector(backgroundRefreshButtonDidTapped), for: .touchUpInside)
        learnMoreButton.addTarget(self, action: #selector(learnMoreButtonPressed), for: .touchUpInside)
        learnMoreButton.setTitleColor(.customWhite.withAlphaComponent(0.7), for: .normal)
    }
    
    @objc func delayedRerender() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            rerender()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [self] in
                if goodToGo {
                    LocationManager.shared.startLocationServices()
                    finish()
                }
            }
        }
    }
    
    func finish() {
        if let _ = parent as? UINavigationController {
            transitionToStoryboard(storyboardID: Constants.SBID.SB.Main, duration: 0.5)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc func rerender() {
        if LocationManager.shared.isLocationServicesProperlyAuthorized() {
            DispatchQueue.main.async { [self] in
                locationButton.alpha = 1
                locationButton.configure(title: "location enabled",  systemImage: "location")
            }
        } else {
            DispatchQueue.main.async { [self] in
                locationButton.alpha = GOODTOGO_ALPHA
                locationButton.configure(title: "share location", subtitle: "precise, always",  systemImage: "location")
            }
        }
        Task {
            let isEnabled = await NotificationsManager.shared.isNotificationsEnabled()
            DispatchQueue.main.async { [self] in
                if isEnabled {
                    notificationsButton.alpha = 1
                    notificationsButton.configure(title: "notifications enabled", systemImage: "bell")
                } else {
                    notificationsButton.alpha = GOODTOGO_ALPHA
                    notificationsButton.configure(title: "turn on notifications", systemImage: "bell")
                }
            }
        }
        
        if UIApplication.shared.backgroundRefreshStatus == .available || ProcessInfo.processInfo.isLowPowerModeEnabled {
            backgroundRefreshButton.alpha = 1
            backgroundRefreshButton.configure(title: "background app refresh enabled",  systemImage: "arrow.clockwise.circle")
        } else {
            backgroundRefreshButton.alpha = GOODTOGO_ALPHA
            backgroundRefreshButton.configure(title: "turn on background app refresh",  systemImage: "arrow.clockwise.circle")
        }
    }
    
    //MARK: - Interaction
    
    @objc func learnMoreButtonPressed() {
        openURL(Constants.faqLink)
    }
    
    @objc func locationButtonDidTapped() {
        do {
            try LocationManager.shared.requestPermissionServices()
        } catch {
            AlertManager.showSettingsAlertController(title: "open settings to share location", message: "precise, always", settingsType: .location, on: self)
        }
    }
    
    @objc func notificationsButtonDidTapped() {
        NotificationsManager.shared.askForNewNotificationPermissionsIfNecessary { granted in
            DispatchQueue.main.async { [self] in
                if !granted {
                    AlertManager.showSettingsAlertController(title: "open settings to turn on notifications", message: "", settingsType: .notifications, on: self)
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
