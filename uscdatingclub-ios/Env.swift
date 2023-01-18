//
//  Environment.swift
//  mist-ios
//
//  Created by Adam Monterey on 7/8/22.
//

import Foundation

class Env {
        
    enum EnvType: String {
        case prod, dev
    }
    
    #if DEBUG
    static let environment: EnvType = .dev
    static let BASE_URL: String = "https://usc-dating-club-test.herokuapp.com/"
    static let CHAT_URL: String = "wss://usc-dating-club-socket-test.herokuapp.com/"
    static let Timeout_Duration: Double = 50
//    #if DEBUG
    //^there's also the option for debug/release flags for more specificity within each environment
    #else
    static let environment: EnvType = .prod
    static let BASE_URL: String = "https://usc-dating-club-test.herokuapp.com/"
    static let CHAT_URL: String = "wss://usc-dating-club-socket-test.herokuapp.com/"
    static let Timeout_Duration: Double = 15
    #endif
}

// if using the environment dictionary located within scheme management:
//    static let asdf = ProcessInfo.processInfo.environment["BASE_URL"]!

//if using the environment dictionary from a plist file
//    static let env_dict = Bundle.main.infoDictionary!["LSEnvironment"] as! [String: Any]
