//
//  LocationPushService.swift
//  locationPushExtension
//
//  Created by Adam Novak on 2023/01/08.
//

import CoreLocation
import FirebaseCore
import FirebaseAnalytics
import FirebaseAnalyticsSwift

class LocationPushService: NSObject, CLLocationPushServiceExtension, CLLocationManagerDelegate {

    var completion: (() -> Void)?
    var locationManager: CLLocationManager?

    func didReceiveLocationPushPayload(_ payload: [String : Any], completion: @escaping () -> Void) {
        self.completion = completion
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        self.locationManager!.requestLocation()
    }
    
    func serviceExtensionWillTerminate() {
        // Called just before the extension will be terminated by the system.
        self.completion?()
    }

    // MARK: - CLLocationManagerDelegate methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Process the location(s) as appropriate
        FirebaseApp.configure()

        
        guard let location = locations.first?.coordinate else {
            Analytics.logEvent("updateLocationFailure", parameters: [
                "reason": "location"
            ])
            self.completion?()
            return
        }
        
        do {
            let data = try Data(contentsOf: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(Constants.Filesystem.AccountPath))
            let frontendCompleteUser = try JSONDecoder().decode(FrontendCompleteUser.self, from: data)
            Task {
                try await UserAPI.updateLocation(latitude: location.latitude,
                                                 longitude: location.longitude,
                                                 email: frontendCompleteUser.email)
                self.completion?()
            }
        } catch {
            Analytics.logEvent("updateLocationFailture", parameters: [
                "reason": "error"
            ])
            self.completion?()
        }

        // If sharing the locations to another user, end-to-end encrypt them to protect privacy
        
        // When finished, always call completion()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.completion?()
    }

}
