//
//  Constants+Mixpanel.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/02/11.
//

import Foundation
import Mixpanel

extension Dictionary {
    
    //Doesnt work. casting value as? MixpanelType doesnt work properly
//    var mixpanelDictionary: [String: MixpanelType] {
//        let mixpanelDict = Dictionary<String,MixpanelType>(uniqueKeysWithValues:
//            self.compactMap { key, value in
//                if let key = key as? String, let value = value as? MixpanelType {
//                    return (key, value)
//                }
//                return nil
//        })
//        print(mixpanelDict)
//        return mixpanelDict
//    }
    
}

extension Constants {
    
    enum MP {
        
        enum AuthProcess {
            static let EventName = "AuthProcess"
            static let Kind = "Kind"
            static let Signup = "Signup"
            static let Login = "Login"
            static let Waitlist = "Waitlist"
        }
        
        enum OpenEmailButtonTapped {
            static let EventName = "OpenEmailButtonTapped"
        }
        enum OpenTextUsButtonTapped {
            static let EventName = "OpenTextUsButtonTapped"
        }
        enum OpenShareAppButtonTapped {
            static let EventName = "OpenShareAppButtonTapped"
        }
        enum OpenFeedbackSurvey {
            static let EventName = "OpenFeedbackSurvey"
        }
        enum TakeScreenshot {
            static let EventName = "TakeScreenshot"
            static let VisibleScreen = "VisibleScreen"
        }
        
        enum Permissions {
            static let EventName = "Permissions"
            static let NotificationsEnabled = "NotificationsEnabled"
        }
        
        enum TakeTest {
            static let EventName = "TakeTest"
            static let IsFirstTest = "IsFirstTest"
        }
        
        enum Profile {
            static let School = "School"
            static let SexualIdentity = "SexualIdentity"
            static let SexualPreference = "SexualPreference"
            static let TakeTest = "TakeTest"

            static let CoordinateOpen = "CoordinateOpen"
            static let MatchOpen = "MatchOpen"
            static let MatchAccept = "MatchAccept"
        }
        
        enum MatchOpen {
            static let EventName = "MatchOpen"
            static let match_id = "match_id" //to match the backend
            static let time_remaining = "time_remaining"
        }
        
        enum MatchAccept {
            static let EventName = "MatchAccept"
            static let time_remaining = "time_remaining"
        }
        
        enum CoordinateOpen {
            static let EventName = "CoordinateOpen"
            static let time_remaining = "time_remaining"
        }
        
    }

}
