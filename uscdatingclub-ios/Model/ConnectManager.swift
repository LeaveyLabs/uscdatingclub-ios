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
    func newTimeElapsed(newTime: String)
    func timeRanOut()
    func newRelativePositioning(heading: CGFloat, distance: Double)
}

class ConnectManager: NSObject {

    //MARK: - Properties

    let startTime: Date
    let delegate: ConnectManagerDelegate
    let motionManager: CMMotionManager
    
    //MARK: - Initializer
    
    init(startTime: Date, delegate: ConnectManagerDelegate) {
        self.startTime = startTime
        self.delegate = delegate
        motionManager = CMMotionManager()
        super.init()
    }
    
    deinit {
        LocationManager.shared.resetDistanceFilter() //TODO: will this suffice
    }

    //MARK: - Setup
    
    func startLocationCalculation() {
        //TODO: should the queue be main though?
        
        motionManager.startGyroUpdates(to: .main) { gyroData, error in
            if let error {
                print("GYRO ERROR", error)
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
                let timeLeft = timeLeft(fromDate: startTime)
                delegate.newTimeElapsed(newTime: timeLeft)
                
                let elapsedTime = Date.init().timeIntervalSince1970.getElapsedTime(since: startTime.timeIntervalSince1970)

                if elapsedTime.minutes == 5 {
                    delegate.timeRanOut()
                    return
                }
                try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
            }
        }
    }
    
    //MARK: - Helpers
    
    func timeLeft(fromDate: Date) -> String {
        let elapsedTime = Date.init().timeIntervalSince1970.getElapsedTime(since: startTime.timeIntervalSince1970)
        let timeRemainingString = "\(4 - elapsedTime.minutes)m \(59 - elapsedTime.seconds)s"
        return timeRemainingString
    }
    
    func updateRelativePositioning() {
        guard let currentLocation = LocationManager.shared.lastLocation else {
            print("ERROR GETTING CURRENT LOCATION, IT'S NIL")
            return
        }
        
        let matchLocation = CLLocation(latitude: 35.96169926794049, longitude: -86.79752282310865)
        let heading = currentLocation.coordinate.heading(to: matchLocation.coordinate)
        let distance = currentLocation.distance(from: matchLocation)
        
        delegate.newRelativePositioning(heading: heading, distance: distance)
    }

}
