//
//  ConnectManager.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/09.
//

import Foundation

protocol ConnectManagerDelegate {
    func newTimeElapsed(newTime: String)
    func timeRanOut()
}

class ConnectManager: NSObject {

    //MARK: - Properties

    let startTime: Date
    let delegate: ConnectManagerDelegate
    
    //MARK: - Initializer
    
    init(startTime: Date, delegate: ConnectManagerDelegate) {
        self.startTime = startTime
        self.delegate = delegate
        super.init()
        startTimer()
    }

    //MARK: - Setup

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
    
    func timeLeft(fromDate: Date) -> String {
        let elapsedTime = Date.init().timeIntervalSince1970.getElapsedTime(since: startTime.timeIntervalSince1970)
        let timeRemainingString = "\(5 - elapsedTime.minutes)m \(60 - elapsedTime.seconds)s"
        return timeRemainingString
    }

}
