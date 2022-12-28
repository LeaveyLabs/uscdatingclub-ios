//
//  Feature.swift
//  timewellspent-ios
//
//  Created by Adam Novak on 2022/11/20.
//

import Foundation

struct Feature: Hashable {
    let sysemImageName: String
    let title: String
    let description: String
}

struct Features: Hashable {
    var newFeatures: [Feature] = []
    
    static let defaultFeatures: [Feature] = [
        Feature(sysemImageName: "shield", title: "Block Friends", description: "You can now block friends immediately, no worries"),
        Feature(sysemImageName: "person", title: "Create Account", description: "Make all the accounts you'd like with our new create account feature."),
        Feature(sysemImageName: "person", title: "Create Account", description: "Make all the accounts you'd like with our new create account feature.")
    ]
}

extension Features {
    init?(json: [String: Any]) {
        guard
            let newFeatures = json["newFeatures"] as? [[String:Any]]
        else { return nil }
        
        var features: [Feature] = []
        for feature in newFeatures {
            guard
                let systemImageName = feature["systemImageName"] as? String,
                let title = feature["title"] as? String,
                let description = feature["description"] as? String
            else { continue }
            
            features.append(Feature(sysemImageName: systemImageName,
                                    title: title,
                                    description: description))
        }
        self.newFeatures = features
    }
}
