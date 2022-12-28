//
//  NotificationResponseHandler.swift
//  mist-ios
//
//  Created by Adam Monterey on 9/15/22.


import Foundation
import FirebaseAnalytics

enum NotificationTypes: String, CaseIterable {
    case match = "match"
}

//extension Notification.Name {
//    static let newMistboxMist = Notification.Name("newMistboxMist")
//    static let newDM = Notification.Name("newDM")
//    static let newMentionedMist = Notification.Name("tag")
//}

extension Notification {
    enum extra: String {
        case type = "type"
        case data = "data"
    }
}

struct NotificationResponseHandler {
    var notificationType: NotificationTypes
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
//            handler.newMatchRequest = try JSONDecoder().decode(MatchRequest.self, from: data)
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
