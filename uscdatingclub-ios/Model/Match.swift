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
    let date: Date
    let distance: Double //meters
    let percents: [Percent]
    
    var elapsedTime: ElapsedTime {
        return Date.init().timeIntervalSince1970.getElapsedTime(since: date.timeIntervalSince1970)
    }
    
    var timeLeftString: String {
        let timeRemainingString = "\(2 - elapsedTime.minutes)m \(59 - elapsedTime.seconds)s"
        return timeRemainingString
    }
    
    init(matchPartner: MatchPartner) {
        userId = matchPartner.id
        userName = matchPartner.firstName
        compatibility = matchPartner.compatibility
        date = Date(timeIntervalSince1970: matchPartner.time)
        distance = matchPartner.distance
        percents = [
            Percent(trait: "skiing", avgPercent: CGFloat.random(in: 20..<40), youPercent: 60, matchPercent: 90),
            Percent(trait: "spontaneity", avgPercent: CGFloat.random(in: 20..<40), youPercent: 80, matchPercent: 60),
            Percent(trait: "creativity", avgPercent: CGFloat.random(in: 20..<40), youPercent: 85, matchPercent: 100),
        ]
    }
}
