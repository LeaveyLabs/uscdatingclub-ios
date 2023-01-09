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
    
    static func ensurePermissionsAreGranted() {
        areAllPermissionsGranted { granted in
            if !granted {
                LocationManager.shared.stopLocationServices()
                NotificationCenter.default.post(name: .permissionsWereRevoked, object: nil)
            }
        }
    }
    
}
