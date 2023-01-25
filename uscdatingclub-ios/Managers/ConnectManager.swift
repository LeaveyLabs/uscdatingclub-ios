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
    func newSecondElapsed()
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
        LocationManager.shared.resetDistanceFilter()
    }

    //MARK: - Public Interface
        
    func startRelativeLocationCalculation() {
        print("Starting relative locaiton claculation")
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
        NotificationCenter.default.addObserver(forName: .locationDidUpdate, object: nil, queue: .main) { notification in
            do {
                print("SENDING LOCATION")
                try self.locationSocket?.sendLocation(location: LocationManager.shared.lastLocation!.coordinate)
            } catch {
                print("error sending location to socket", error)
            }
            self.updateRelativePositioning()
        }
        
        //PARTNER LOCATION
        do {
            locationSocket = try LocationSocket(sender: UserService.singleton.getId(), receiver: matchInfo.userId)
            locationSocket!.partnerLocationDidChange = onPartnerLocationDidChange
        } catch {
            //TODO: post to crashlytics
            print("error opening location socket", error)
        }
    }
    
    func startRespondSession() {
        Task {
            while true {
                if finished { return }
                if matchInfo.elapsedTime.minutes == Constants.minutesToRespond {
                    delegate.timeRanOut()
                    return
                }
                delegate.newSecondElapsed()
                
                try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
            }
        }
    }
    
    func startConnectSession() {
        startRelativeLocationCalculation()
        Task {
            while true {
                if finished { return }
                if matchInfo.elapsedTime.minutes == Constants.minutesToConnect {
                    delegate.timeRanOut()
                    return
                }
                delegate.newSecondElapsed()
                
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
            print("error getting current location")
            return
        }
        guard let deviceHeading = motionManager.deviceMotion?.heading else {
            print("error getting current heading")
            return
        }
        
        let fixedMatchCoordinate = CLLocationCoordinate2D(latitude: 34.02172249062856, longitude: -118.2830645563657) //right in front of leavey library
        let matchCoordinate = locationSocket?.partnerLocation ?? matchInfo.location
        let matchLocation = CLLocation(latitude: matchCoordinate.latitude, longitude: matchCoordinate.longitude)
        let distance = currentLocation.distance(from: matchLocation)
        
        let locationHeading = currentLocation.coordinate.heading(to: matchLocation.coordinate)
        let relativeHeading = -(deviceHeading - locationHeading).degreesToRadians
        
        delegate.newRelativePositioning(heading: relativeHeading, distance: distance)
    }

}
