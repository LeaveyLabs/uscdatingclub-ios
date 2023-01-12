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
    
    //MARK: - Initializer
    
    init(matchInfo: MatchInfo, delegate: ConnectManagerDelegate) {
        self.matchInfo = matchInfo
        self.delegate = delegate
        motionManager = CMMotionManager()
        LocationManager.shared.lastConnectTime = matchInfo.time.timeIntervalSince1970
        super.init()
    }
    
    deinit {
        LocationManager.shared.resetDistanceFilter() //TODO: this won't relaly suffice
    }

    //MARK: - Public Interface
    
    func startLocationCalculation() {
        //TODO: should the queue be main though?
        
        motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main) { cmDeviceMotion, error in
            if let error {
                print("MOTION ERROR", error)
                return
            }
            self.updateRelativePositioning()
        }
        LocationManager.shared.updateDistancefilter(to: 0)
        
        //TODO: reset distance filter automatically after 5 minutes
        
        //TODO: start sharing location to the socket
        NotificationCenter.default.addObserver(forName: .locationStatusDidUpdate, object: nil, queue: nil) { notification in
            self.updateRelativePositioning()
        }
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
        
        //TODO: feed in data from the socket
        let matchLocation = CLLocation(latitude: 34.022123871588995, longitude: -118.28505424318654)
        let distance = currentLocation.distance(from: matchLocation)
        
        let locationHeading = currentLocation.coordinate.heading(to: matchLocation.coordinate)
        let relativeHeading = -(deviceHeading - locationHeading).degreesToRadians
        
        delegate.newRelativePositioning(heading: relativeHeading, distance: distance)
    }

}
