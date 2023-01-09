//
//  LocationManager.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2022/12/21.
//

import Foundation
import CoreLocation
import FirebaseAnalytics
import FirebaseAnalyticsSwift

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    //MARK: - Properties
    
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var locationAccuracy: CLAccuracyAuthorization?
    @Published var lastLocation: CLLocation?
    
    var properAuthorizations: Bool {
        return (locationManager.authorizationStatus == .authorizedAlways &&
                locationManager.accuracyAuthorization == .fullAccuracy)
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }

    private override init() {
        super.init()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        locationManager.distanceFilter = 5 //update after moving x meters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //within a few meters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = false
    }
    
    //MARK: - CLLocationManagerDelegate
    
    //this function is (usually?) also called when the app is running in the background and the user changes authorization from settings... but this can't be a guarantee
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(#function, statusString, locationAccuracy == .fullAccuracy ? "Full acc" : "Reduced acc")
        NotificationCenter.default.post(name: .locationStatusDidUpdate, object: "myObject", userInfo: ["key": "Value"])

        locationStatus = status
        locationAccuracy = manager.accuracyAuthorization
        
        //Auto-request always permissions after in-use permissions granted
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            DispatchQueue.main.async{
                self.locationManager.requestAlwaysAuthorization()
            }
        }
        
        if properAuthorizations {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        print(#function, location)
        
        if let lastLocation {
            postToDatabase(lat: lastLocation.coordinate.latitude, long: lastLocation.coordinate.longitude)
        }
        
        //TODO: idea: should we stop and then start location services here to restart them and potentially prolong the total background time?
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, error.localizedDescription)
        let analyticsId = "location"
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
          AnalyticsParameterItemID: "id-\(analyticsId)",
        ])
    }
    
    //MARK: - Helpers
    
    func requestPermissionServices() throws {
        if locationStatus == .authorizedWhenInUse ||
            locationStatus == .denied ||
            locationAccuracy == .reducedAccuracy {
            throw PermissionsError()
        }
                        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationServices() {
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startMonitoringLocationPushes { data, error in
            if let data {
                let token = data.reduce("", {$0 + String(format: "%02X", $1)})
                print("location pushes good to go. APNs token for location pushes:", token)
            } else if let error {
                print("error with location pushes", error)
            }
        }
    }
    
    func stopLocationServices() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopMonitoringLocationPushes()
    }
        
    func isLocationServicesProperlyAuthorized() -> Bool {
        return properAuthorizations
    }
    
    func postToDatabase(lat: Double, long: Double) {
        //TODO: why is the analytics not posting?
        Analytics.logEvent("updateLocationSuccess", parameters: nil)
        Task {
            try await UserAPI.updateLocation(latitude: lat, longitude: long, email: UserService.singleton.getEmail())
        }
    }
    
}

//            let db = Firestore.firestore()
//            db.collection("location").document("hi").setData([
//                "latestTime":Date(),
//                "updates":updates
//            ])
