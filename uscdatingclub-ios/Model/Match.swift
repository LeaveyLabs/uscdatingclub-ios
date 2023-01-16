//
//  Match.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/10.
//

import Foundation
import CoreLocation

//MARK: - From Backend
struct Match: Codable {
    let user1Id: Int
    let user2Id: Int
}

struct MatchPartner: Codable {
    //Vitals
    let id: Int
    let firstName: String
    let email: String
    
    //Connection
    let time: Double
    let distance: Double
    let latitude: Double
    let longitude: Double
    
    //Compatibility
    let compatibility: Int
    let similarities: [Similarity]
}

struct MatchAcceptance: Codable {
    //Vitals
    let id: Int
    let firstName: String
    let email: String
    
    //Connection
    let time: Double
    let distance: Double
    let latitude: Double
    let longitude: Double
    
    //Compatibility
    let compatibilty: Int
    let similarities: [Similarity]
}

//MARK: - Frontend

struct Similarity: Codable {
    let trait: String
    let avgPercent: CGFloat
    let youPercent: CGFloat
    let matchPercent: CGFloat
}

struct MatchInfo: Codable {
    let userId: Int
    let userName: String
    let compatibility: Int
    let date: Date
    let distance: Double //meters
    let percents: [Similarity]
    let latitude: Double
    let longitude: Double
    
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
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
            Similarity(trait: "skiing", avgPercent: CGFloat.random(in: 20..<40), youPercent: 60, matchPercent: 90),
            Similarity(trait: "spontaneity", avgPercent: CGFloat.random(in: 20..<40), youPercent: 80, matchPercent: 60),
            Similarity(trait: "creativity", avgPercent: CGFloat.random(in: 20..<40), youPercent: 85, matchPercent: 100),
        ]
        latitude = matchPartner.latitude
        longitude = matchPartner.longitude
    }
    
    init(matchAcceptance: MatchAcceptance) {
        userId = matchAcceptance.id
        userName = matchAcceptance.firstName
        compatibility = matchAcceptance.compatibilty
        date = Date(timeIntervalSince1970: matchAcceptance.time)
        percents = [
            Similarity(trait: "skiing", avgPercent: CGFloat.random(in: 20..<40), youPercent: 60, matchPercent: 90),
            Similarity(trait: "spontaneity", avgPercent: CGFloat.random(in: 20..<40), youPercent: 80, matchPercent: 60),
            Similarity(trait: "creativity", avgPercent: CGFloat.random(in: 20..<40), youPercent: 85, matchPercent: 100),
        ]
        latitude = matchAcceptance.latitude
        longitude = matchAcceptance.longitude
        distance = matchAcceptance.distance
    }
}
