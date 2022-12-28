//
//  RemoteConfig.swift
//  timewellspent-ios
//
//  Created by Adam Novak on 2022/11/20.
//

import Foundation
import FirebaseRemoteConfig
import FirebaseRemoteConfigSwift

enum RemoteConfigKeys: String, CaseIterable {
    case updateAvailableVersion, updateAvailableFeatures
    case appStoreLink, landingPageLink, privacyPageLink, feedbackLink
}

//MARK: = Variables

extension Constants {
    
    //    static let maxContinuousScreenTime = remoteConfig.configValue(forKey: RemoteConfigKeys.maxContinuousScreenTime.rawValue).numberValue as? Int ?? 40
    static let updateAvailableVersion = remoteConfig.configValue(forKey: RemoteConfigKeys.updateAvailableVersion.rawValue).stringValue ?? "0.0.0"
    static let updateAvailableFeatures: Features = Features(json: remoteConfig.configValue(forKey: RemoteConfigKeys.updateAvailableFeatures.rawValue).jsonValue as? [String:Any] ?? [:]) ?? Features()
    static let appStoreLink = NSURL(string: remoteConfig.configValue(forKey: RemoteConfigKeys.appStoreLink.rawValue).stringValue ?? "https://apple.com")!
    static let landingPageLink = NSURL(string: remoteConfig.configValue(forKey: RemoteConfigKeys.appStoreLink.rawValue).stringValue ?? "https://uscdatingclub.com")!
    static let privacyPageLink = NSURL(string: remoteConfig.configValue(forKey: RemoteConfigKeys.appStoreLink.rawValue).stringValue ?? "https://uscdatingclub.com/privacy")!
    static let feedbackLink = NSURL(string: remoteConfig.configValue(forKey: RemoteConfigKeys.appStoreLink.rawValue).stringValue ?? "https://forms.gle/G4pN8MyiXrk9doREA")!
    
}

extension Constants {
    
    static var remoteConfig: RemoteConfig {
        RemoteConfig.remoteConfig()
    }
    
    static func fetchRemoteConfig() {
//        setupRemoteConfigDefaults()
        remoteConfig.fetchAndActivate { fetchStatus, error in
            guard error == nil else {
                print(error!)
                return
            }
            remoteConfig.activate()
            print("Retrieved remote config")
        }
    }
    
    static func fetchRemoteConfigDebug() {
        let debugSettings = RemoteConfigSettings()
        debugSettings.minimumFetchInterval = 0
        remoteConfig.configSettings = debugSettings
        
        remoteConfig.fetch(withExpirationDuration: 0) { fetchStatus, error in
            guard error == nil else {
                print(error!)
                return
            }
            remoteConfig.activate()
            print("Retrieved remote config debug")
        }
    }
    
}
    
    
    //This isn't really needed, since we can just do ?? 15 below
//    static var remoteConfigDefaults: [String: NSObject] = [
//        RemoteConfigKeys.minContinuousScreenTime.rawValue: 15 as NSObject,
//        RemoteConfigKeys.maxContinuousScreenTime.rawValue: 40 as NSObject,
//    ]
    
//    private static func setupRemoteConfigDefaults() {
//        remoteConfig.setDefaults(remoteConfigDefaults)
//    }
    
