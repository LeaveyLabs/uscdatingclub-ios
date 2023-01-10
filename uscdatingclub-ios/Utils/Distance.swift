//
//  Map.swift
//  mist-ios
//
//  Created by Adam Monterey on 6/17/22.
//

import Foundation

extension Double {
    
    func convertLatDeltaToKms(_ latDelta: Double) -> Double {
        return latDelta * 69 * 1.6
    }

    func metersToFeet() -> Double {
        return self * 3.280839895
    }

    func feetToMiles() -> Double {
        return self / 5280
    }
    
}

func prettyDistance(meters: Double) -> String {
    let feet = meters.metersToFeet()
    if feet >= 1000 {
        return "\(Int(feet.feetToMiles())) miles"
    } else {
        return "\(Int(feet)) feet"
    }
}
