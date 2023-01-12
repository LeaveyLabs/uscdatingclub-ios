//
//  NotificationResponseHandler.swift
//  mist-ios
//
//  Created by Adam Monterey on 9/15/22.


import Foundation
import FirebaseAnalytics

enum NotificationTypes: String, CaseIterable {
    case match = "match"
    case accept = "accept"
}

//extension Notification.Name {
//    static let newMistboxMist = Notification.Name("newMistboxMist")
//    static let newDM = Notification.Name("newDM")
//    static let newMentionedMist = Notification.Name("tag")
//}

struct MatchPartner: Codable {
    let id: Int
    let firstName: String
}

struct MatchAcceptance: Codable {
    let id: Int
    let firstName: String
}

extension Notification {
    enum extra: String {
        case type = "type"
        case data = "data"
    }
}

struct NotificationResponseHandler {
    var notificationType: NotificationTypes
    var newMatchPartner: MatchPartner?
    var newMatchAcceptance: MatchAcceptance?
}

func generateNotificationResponseHandler(_ notificationResponse: UNNotificationResponse) -> NotificationResponseHandler? {
    guard
        let userInfo = notificationResponse.notification.request.content.userInfo as? [String : AnyObject],
        let notificationTypeString = userInfo[Notification.extra.type.rawValue] as? String,
        let notificationType = NotificationTypes.init(rawValue: notificationTypeString)
    else { return nil }
    
    do {
        var handler = NotificationResponseHandler(notificationType: notificationType)
        switch notificationType {
            case .match:
                guard let json = userInfo[Notification.extra.data.rawValue] else { return nil }
                let data = try JSONSerialization.data(withJSONObject: json as Any, options: .prettyPrinted)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                handler.newMatchPartner = try decoder.decode(MatchPartner.self, from: data)
                
            case .accept:
                guard let json = userInfo[Notification.extra.data.rawValue] else { return nil }
                let data = try JSONSerialization.data(withJSONObject: json as Any, options: .prettyPrinted)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                handler.newMatchAcceptance = try decoder.decode(MatchAcceptance.self, from: data)
        }
        return handler
    } catch {
        let analyticsId = "notiifcation"
        let analyticsTitle = "displayingVCafterRemoteNotificationFailed"
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
          AnalyticsParameterItemID: "id-\(analyticsId)",
          AnalyticsParameterItemName: analyticsTitle,
        ])
        return nil
    }
}
