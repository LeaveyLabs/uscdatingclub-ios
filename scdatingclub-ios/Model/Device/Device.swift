//
//  Device.swift
//  mist-ios
//
//  Created by Adam Monterey on 9/3/22.
//

import Foundation

struct Device: Codable {
    var hasRatedApp: Bool = false
    var hasSeenTutorial: Bool = false
    var hasReceivedFeedbackNotification: Bool = false
    var lastReceivedNewUpdateAlertVersion: String = "0.0.0"

    enum CodingKeys: String, CodingKey {
        case hasRatedApp
        case hasSeenTutorial
        case lastReceivedNewUpdateAlertVersion
        case hasReceivedFeedbackNotification
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        hasRatedApp = try values.decodeIfPresent(Bool.self, forKey: .hasRatedApp) ?? false
        hasSeenTutorial = try values.decodeIfPresent(Bool.self, forKey: .hasSeenTutorial) ?? true
        lastReceivedNewUpdateAlertVersion = try values.decodeIfPresent(String.self, forKey: .lastReceivedNewUpdateAlertVersion) ?? "0.0.0"
        hasReceivedFeedbackNotification = try values.decodeIfPresent(Bool.self, forKey: .hasReceivedFeedbackNotification) ?? false
    }
    
    init() {
        hasRatedApp = false
        hasSeenTutorial = false
        hasReceivedFeedbackNotification = false
        lastReceivedNewUpdateAlertVersion = "0.0.0"
    }
    
}
