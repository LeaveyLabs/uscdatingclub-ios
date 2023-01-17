//
//  EmailWhitelist.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/16.
//

import Foundation

struct EmailWhitelist: Hashable {
    var emails: [String] = []
}

extension EmailWhitelist {
    init?(json: [String: Any]) {
        guard
            let emails = json["emails"] as? [String]
        else { return nil }
        
        self.emails = emails
    }
}
