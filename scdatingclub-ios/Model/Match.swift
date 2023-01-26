//
//  Match.swift
//  scdatingclub-ios
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
    let numericalSimilarities: [NumericalSimilarity]
    let textSimilarities: [TextSimilarity]
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
    let compatibility: Int
    let numericalSimilarities: [NumericalSimilarity]
    let textSimilarities: [TextSimilarity]
}

//MARK: - Frontend

struct NumericalSimilarity: Codable {
    let trait: String
    let avgPercent: CGFloat
    let youPercent: CGFloat
    let partnerPercent: CGFloat
}

struct TextSimilarity: Codable {
    let trait: String
    let sharedResponse: String
}

struct MatchInfo: Codable {
    let partnerId: Int
    let partnerName: String
    let compatibility: Int
    let date: Date
    let distance: Double //meters
    
    var numericalSimilarities: [NumericalSimilarity] //var because of xcode compiler quirk which won't let us use a function call
    let textSimilarities: [TextSimilarity]
    
    let latitude: Double
    let longitude: Double
    
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var elapsedTime: ElapsedTime {
        return Date.init().timeIntervalSince1970.getElapsedTime(since: date.timeIntervalSince1970)
    }
    
    //TODO: make the below code minimum 0:00
    
    var timeLeftToRespondString: String {
        let minsLeft = Constants.minutesToRespond - 1 - elapsedTime.minutes
        let secsLeft = 59 - elapsedTime.seconds
        if minsLeft < 0 {
            return "0m 0s"
        }
        return "\(minsLeft)m \(secsLeft)s"
    }
    
    var timeLeftToConnectString: String {
        let minsLeft = Constants.minutesToConnect - 1 - elapsedTime.minutes
        let secsLeft = 59 - elapsedTime.seconds
        if minsLeft < 0 {
            return "0m 0s"
        }
        return "\(minsLeft)m \(secsLeft)s"
    }
    
    init(matchPartner: MatchPartner) {
        partnerId = matchPartner.id
        partnerName = matchPartner.firstName
        compatibility = matchPartner.compatibility
        date = Date(timeIntervalSince1970: matchPartner.time)
        distance = matchPartner.distance
        textSimilarities = matchPartner.textSimilarities
        latitude = matchPartner.latitude
        longitude = matchPartner.longitude
        
        numericalSimilarities = matchPartner.numericalSimilarities
        numericalSimilarities = adjustLastNumericalSimilarity(matchPartner.firstName.count, existingNumericalSimilarities: numericalSimilarities)
    }
    
    init(matchAcceptance: MatchAcceptance) {
        partnerId = matchAcceptance.id
        partnerName = matchAcceptance.firstName
        compatibility = matchAcceptance.compatibility
        date = Date(timeIntervalSince1970: matchAcceptance.time)
        textSimilarities = matchAcceptance.textSimilarities
        latitude = matchAcceptance.latitude
        longitude = matchAcceptance.longitude
        distance = matchAcceptance.distance
        
        numericalSimilarities = matchAcceptance.numericalSimilarities
        numericalSimilarities = adjustLastNumericalSimilarity(matchAcceptance.firstName.count, existingNumericalSimilarities: numericalSimilarities)
    }
    
    func adjustLastNumericalSimilarity(_ partnerNameLength: Int, existingNumericalSimilarities: [NumericalSimilarity]) -> [NumericalSimilarity] {
        guard let lastSimilarity = existingNumericalSimilarities.last else { return existingNumericalSimilarities }
        
        var adjustedPartnerPercent = lastSimilarity.partnerPercent
        var adjustedYouPercent = lastSimilarity.youPercent

        //Don't let matchLabel hang off right end
        let matchNameLength = CGFloat(partnerNameLength)
        adjustedPartnerPercent = min(100 - matchNameLength / 2, adjustedPartnerPercent)

        //Don't let matchLabel and youLabel crossover
        let distanceBetween = abs(adjustedPartnerPercent - adjustedYouPercent)
        let correction = matchNameLength - distanceBetween
        if correction > 0 {
            if adjustedPartnerPercent + correction <= 100 {
                adjustedPartnerPercent += correction
            } else if adjustedYouPercent + correction <= 100 {
                adjustedYouPercent += correction
            } else {
                if adjustedPartnerPercent > adjustedYouPercent {
                    adjustedYouPercent -= correction
                } else {
                    adjustedPartnerPercent -= correction
                }
            }
        }

        var adjustedNumericalSimilarities: [NumericalSimilarity] = existingNumericalSimilarities
        adjustedNumericalSimilarities.removeLast()
        adjustedNumericalSimilarities.append(NumericalSimilarity(trait: lastSimilarity.trait, avgPercent: lastSimilarity.avgPercent, youPercent: adjustedYouPercent, partnerPercent: adjustedPartnerPercent))
        
        return adjustedNumericalSimilarities
    }
}