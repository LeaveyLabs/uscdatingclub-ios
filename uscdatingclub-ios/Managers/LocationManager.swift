//
//  LocationManager.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2022/12/21.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseCore

class PermissionsError: NSError {
    
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
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

    override init() {
        super.init()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        locationManager.distanceFilter = 10 //update after moving x meters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //within a few meters
        locationManager.allowsBackgroundLocationUpdates = true
//        locationManager.showsBackgroundLocationIndicator //what does this do?
    }
    
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
//        let region = CLBeaconRegion
        let region = CLCircularRegion(center: .init(latitude: 0, longitude: 0), radius: 10, identifier: "me")
        locationManager.startMonitoring(for: region)
        
//        locationManager.startMonitoringLocationPushes { data, error in
//            //asdf
//        }
    }
    
    func stopLocationServices() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringLocationPushes()
        locationManager.stopMonitoringSignificantLocationChanges()
//        locationManager.stopMonitoring(for: region)
    }
        
    func isLocationServicesProperlyAuthorized() -> Bool {
        return properAuthorizations
    }
    
    //this function is (usually?) also called when the app is running in the background and the user changes authorization from settings... but this can't be a guarantee
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(#function, statusString, locationAccuracy == .fullAccuracy ? "Full acc" : "Reduced acc")
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
    
    //double check that
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
//        UIApplication.shared.backgroundTimeRemaining
        
        guard let location = locations.last else { return }
        lastLocation = location
        print(#function, location)
        
        postToDatabase()
        
        if properAuthorizations {
            locationManager.startUpdatingLocation() //does calling "start updating location" again right now do anything? we're already updating location... could it prolong the duration, though?
        } else {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, error.localizedDescription)
    }
    
    func postToDatabase() {
        updates += 1
        Task {
            let db = Firestore.firestore()
            db.collection("location").document("hi").setData([
                "latestTime":Date(),
                "updates":updates
            ])
        }
    }
    
}

var updates = 0
