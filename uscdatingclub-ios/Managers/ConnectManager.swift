//
//  ConnectManager.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/09.
//

import Foundation
import MapKit
import CoreMotion

protocol ConnectManagerDelegate {
    func newTimeElapsed()
    func timeRanOut()
    func newRelativePositioning(heading: CGFloat, distance: Double)
}

class ConnectManager: NSObject {

    //MARK: - Properties

    private var finished: Bool = false
    let matchInfo: MatchInfo
    let delegate: ConnectManagerDelegate
    let motionManager: CMMotionManager
    var locationSocket: LocationSocket?
    
    //MARK: - Initializer
    
    init(matchInfo: MatchInfo, delegate: ConnectManagerDelegate) {
        self.matchInfo = matchInfo
        self.delegate = delegate
        motionManager = CMMotionManager()
        LocationManager.shared.lastConnectTime = matchInfo.date.timeIntervalSince1970
        super.init()
    }
    
    deinit {
        LocationManager.shared.resetDistanceFilter() //TODO: this won't suffice
    }

    //MARK: - Public Interface
        
    func startRelativeLocationCalculation() {
        //MY HEADING
        motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main) { cmDeviceMotion, error in
            if let error {
                print("MOTION ERROR", error)
                return
            }
            self.updateRelativePositioning()
        }
        
        //MY LOCATION
        LocationManager.shared.updateDistancefilter(to: 0)
        NotificationCenter.default.addObserver(forName: .locationStatusDidUpdate, object: nil, queue: nil) { notification in
            self.updateRelativePositioning()
        }
        
        //PARTNER LOCATION
        do {
            self.locationSocket = try LocationSocket(sender: UserService.singleton.getId(), receiver: matchInfo.userId)
        } catch {
            //TODO: post to crashlytics
            print("error opening location socket", error)
        }
        self.locationSocket?.partnerLocationDidChange = self.onPartnerLocationDidChange
    }

    func startTimer() {
        Task {
            while true {
                if finished { return }
                if matchInfo.elapsedTime.minutes == 3 {
                    delegate.timeRanOut()
                    return
                }
                delegate.newTimeElapsed()
                
                try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
            }
        }
    }
    
    func endConnection() {
        finished = true
        NotificationCenter.default.removeObserver(self)
        LocationManager.shared.resetDistanceFilter()
    }
    
    func onPartnerLocationDidChange(location:CLLocationCoordinate2D) {
        updateRelativePositioning()
        return
    }
    
    //MARK: - Helpers
    
    func updateRelativePositioning() {
        guard let currentLocation = LocationManager.shared.lastLocation else {
            print("ERROR GETTING CURRENT LOCATION, IT'S NIL")
            return
        }
        guard let deviceHeading = motionManager.deviceMotion?.heading else {
            print("ERROR GETTING CURRENT LOCATION, IT'S NIL")
            return
        }
                
        let matchCoordinate = locationSocket?.partnerLocation ?? matchInfo.location
        let matchLocation = CLLocation(latitude: matchCoordinate.latitude, longitude: matchCoordinate.longitude)
        let distance = currentLocation.distance(from: matchLocation)
        
        let locationHeading = currentLocation.coordinate.heading(to: matchLocation.coordinate)
        let relativeHeading = -(deviceHeading - locationHeading).degreesToRadians
        
        delegate.newRelativePositioning(heading: relativeHeading, distance: distance)
    }

}
