//
//  PermissionsManager.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/07.
//

import UIKit

struct PermissionsManager {
    
    static func areAllPermissionsGranted(closure: @escaping (Bool) -> Void) {
        NotificationsManager.shared.isNotificationsEnabled(closure: { isNotificationsEnabled in
            DispatchQueue.main.async {
                let areGranted = isNotificationsEnabled && LocationManager.shared.isLocationServicesProperlyAuthorized() && (UIApplication.shared.backgroundRefreshStatus == .available || ProcessInfo.processInfo.isLowPowerModeEnabled)
                closure(areGranted)
            }
        })
    }
    
    static func requestPermissionsIfNecessary() {
        guard UserService.singleton.isLoggedIntoAnAccount else { return }

        //slight delay just in case settings aren't persisted right away
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            areAllPermissionsGranted { areAllGranted in
                guard !areAllGranted else { return }
                DispatchQueue.main.async {
                    guard
                        let visibleVC = SceneDelegate.visibleViewController,
                        !visibleVC .isKind(of: PermissionsVC.self)
                    else { return }
                    let permissionsVC = PermissionsVC.create()
                    permissionsVC.modalPresentationStyle = .fullScreen
                    visibleVC.present(permissionsVC, animated: true)
                }
            }
        }
    }
}
