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
    
    var goodToGo: Bool {
        locationButton.internalButton.backgroundColor == .customGreen && notificationsButton.internalButton.backgroundColor == .customGreen
    }

    //MARK: - Initialization
    
    class func create() -> PermissionsVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Auth, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.Permissions) as! PermissionsVC
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        rerender()
        
        NotificationCenter.default.addObserver(self, selector: #selector(delayedRerender), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(delayedRerender), name: .locationStatusDidUpdate, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Setup
    
    func setupButtons() {
        locationButton.internalButton.addTarget(self, action: #selector(locationButtonDidTapped), for: .touchUpInside)
        notificationsButton.internalButton.addTarget(self, action: #selector(notificationsButtonDidTapped), for: .touchUpInside)
    }
    
    @objc func delayedRerender() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            rerender()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [self] in
                if goodToGo {
                    LocationManager.shared.startLocationServices()
                    dismiss(animated: true)
                }
            }
        }
    }
    
    @objc func rerender() {
        if LocationManager.shared.isLocationServicesProperlyAuthorized() {
            DispatchQueue.main.async { [self] in
                locationButton.internalButton.backgroundColor = .customGreen
                locationButton.configure(title: "location enabled",  systemImage: "location")
            }
        } else {
            DispatchQueue.main.async { [self] in
                locationButton.internalButton.backgroundColor = .customWhite
                locationButton.configure(title: "share location\nprecise, always", subtitle: "precise, always",  systemImage: "location")
            }
        }
        
        NotificationsManager.shared.isNotificationsEnabled(closure: { [self] isEnabled in
            if isEnabled {
                DispatchQueue.main.async { [self] in
                    notificationsButton.internalButton.backgroundColor = .customGreen
                    notificationsButton.configure(title: "notifications enabled", systemImage: "bell")
                }
            } else {
                DispatchQueue.main.async { [self] in
                    notificationsButton.internalButton.backgroundColor = .customWhite
                    notificationsButton.configure(title: "turn on notifications", systemImage: "bell")
                }
            }
        })
    }
    
    //MARK: - Interaction
    
    @objc func locationButtonDidTapped() {
        do {
            try LocationManager.shared.requestPermissionServices()
        } catch {
            AlertManager.showSettingsAlertController(title: "open settings to share location (preicse, always)", message: "", on: self)
        }
    }
    
    @objc func notificationsButtonDidTapped() {
        NotificationsManager.shared.askForNewNotificationPermissionsIfNecessary { granted in
            DispatchQueue.main.async { [self] in
                if !granted {
                    AlertManager.showSettingsAlertController(title: "open settings to turn on notifications", message: "", on: self)
                } else {
                    rerender()
                }
            }
        }
    }

}
