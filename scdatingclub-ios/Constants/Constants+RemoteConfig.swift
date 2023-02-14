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
    case updateAvailableVersion, updateAvailableFeatures, updateMandatoryVersion
    case minutesToRespond, minutesToConnect, minutesUntilFeedbackNotification
    case onlyUscStudents
    case shareFeedbackButtonTitle
}

//MARK: = Variables

extension Constants {
    
    //    static let maxContinuousScreenTime = remoteConfig.configValue(forKey: RemoteConfigKeys.maxContinuousScreenTime.rawValue).numberValue as? Int ?? 40
    static let updateAvailableVersion = remoteConfig.configValue(forKey: RemoteConfigKeys.updateAvailableVersion.rawValue).stringValue ?? "0.0.0"
    static let updateMandatoryVersion: String = remoteConfig.configValue(forKey: RemoteConfigKeys.updateMandatoryVersion.rawValue).stringValue ?? "0.0.0"
    static let updateAvailableFeatures: Features = Features(json: remoteConfig.configValue(forKey: RemoteConfigKeys.updateAvailableFeatures.rawValue).jsonValue as? [String:Any] ?? [:]) ?? Features()

    static let minutesToRespond: Int = remoteConfig.configValue(forKey: RemoteConfigKeys.minutesToRespond.rawValue).numberValue as? Int ?? 5
    static let minutesToConnect: Int = remoteConfig.configValue(forKey: RemoteConfigKeys.minutesToConnect.rawValue).numberValue as? Int ?? 5
    static let minutesUntilFeedbackNotification: Int = remoteConfig.configValue(forKey: RemoteConfigKeys.minutesUntilFeedbackNotification.rawValue).numberValue as? Int ?? 30
    
    static let onlyUscStudents: Bool = remoteConfig.configValue(forKey: RemoteConfigKeys.onlyUscStudents.rawValue).boolValue
    static let shareFeedbackButtonTitle: String = remoteConfig.configValue(forKey: RemoteConfigKeys.shareFeedbackButtonTitle.rawValue).stringValue ?? "text us"

    //why is the below approach giving me errors?
//    static let faqLink = URL(string: remoteConfig.configValue(forKey: RemoteConfigKeys.appStoreLink.rawValue).stringValue ?? "https://scdatingclub.com/faq")!

}

extension Constants {
    
    static var remoteConfig: RemoteConfig {
        RemoteConfig.remoteConfig()
    }
    
    static func fetchRemoteConfig() {
        guard Env.environment == .prod else {
            Constants.fetchRemoteConfigDebug()
            return
        }

        setupRemoteConfigDefaults()
        remoteConfig.fetchAndActivate { fetchStatus, error in
            guard error == nil else {
                print(error!)
                return
            }
            remoteConfig.activate()
            print("Retrieved remote config")
            NotificationCenter.default.post(name: .remoteConfigDidActivate, object: nil)
        }
    }
    
    static func fetchRemoteConfigDebug() {
        let debugSettings = RemoteConfigSettings()
        debugSettings.minimumFetchInterval = 0
        remoteConfig.configSettings = debugSettings
        
//        setupRemoteConfigDefaults()
        remoteConfig.fetch(withExpirationDuration: 0) { fetchStatus, error in
            guard error == nil else {
                print(error!)
                return
            }
            remoteConfig.activate()
            print("Retrieved remote config debug", shareFeedbackButtonTitle, updateAvailableVersion)
            NotificationCenter.default.post(name: .remoteConfigDidActivate, object: nil)
        }
    }
    
    static var remoteConfigDefaults: [String: NSObject] = [
        RemoteConfigKeys.shareFeedbackButtonTitle.rawValue: "text us" as NSObject,
        RemoteConfigKeys.onlyUscStudents.rawValue: true as NSObject,

        RemoteConfigKeys.minutesToRespond.rawValue: 5 as NSObject,
        RemoteConfigKeys.minutesToConnect.rawValue: 5 as NSObject,
        RemoteConfigKeys.minutesUntilFeedbackNotification.rawValue: 30 as NSObject,
    ]
    
    private static func setupRemoteConfigDefaults() {
        remoteConfig.setDefaults(remoteConfigDefaults)
    }
    
}
