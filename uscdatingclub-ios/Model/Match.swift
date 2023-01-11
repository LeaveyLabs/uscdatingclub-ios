//
//  Match.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/10.
//

import Foundation

struct Percent {
    let trait: String
    let avgPercent: CGFloat
    let youPercent: CGFloat
    let matchPercent: CGFloat
}

struct MatchInfo {
    let userId: Int
    let userName: String
    let compatibility: Int
    let time: Date
    let distance: Double //meters
    let percents: [Percent]
    
    var elapsedTime: ElapsedTime {
        return Date.init().timeIntervalSince1970.getElapsedTime(since: time.timeIntervalSince1970)
    }
    
    var timeLeftString: String {
        let timeRemainingString = "\(2 - elapsedTime.minutes)m \(59 - elapsedTime.seconds)s"
        return timeRemainingString
    }
}
