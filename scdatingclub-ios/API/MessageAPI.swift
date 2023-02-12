//
//  MessageAPI.swift
//  scdatingclub-ios
//
//  Created by Kevin Sun on 2/12/23.
//

import Foundation


class MessageAPI {
    enum Endpoints: String {
        case messages = "messages/"
    }
    
    enum ParameterKeys: String {
        case user1Id = "user1_id"
        case user2Id = "user2_id"
    }
    
    static func fetchMessages(user1Id: Int, user2Id: Int) async throws -> [Message] {
        let url =  "\(Env.BASE_URL)\(Endpoints.messages.rawValue)"
        let params:[String:Int] = [
            ParameterKeys.user1Id.rawValue: user1Id,
            ParameterKeys.user2Id.rawValue: user2Id,
        ]
        let json = try JSONEncoder().encode(params)
        let (data, _) = try await BasicAPI.basicHTTPCallWithToken(url: url, jsonData: json, method: HTTPMethods.GET.rawValue)
        return try JSONDecoder().decode([Message].self, from: data)
    }
}
