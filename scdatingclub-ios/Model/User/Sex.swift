//
//  Sex.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/01/08.
//

import Foundation

enum Sex: String, CaseIterable {
    case blank, f, m, b
    
    var displayName: String {
        switch self {
        case .blank:
            return ""
        case .f:
            return "female"
        case .m:
            return "male"
        case .b:
            return "both"
//            case .other:
//                return "other"
//            case .ratherNotSay:
//                return "rather not say"
        }
    }
    
    var databaseName: String? {
        switch self {
        case .blank:
            return "" //should never be accessed.. throw?
        case .f:
            return "f"
        case .m:
            return "m"
        case .b:
            return "b"
        }
    }
}
