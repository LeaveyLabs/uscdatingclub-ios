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
        var params = "\(ParameterKeys.user1Id.rawValue)=\(user1Id)&\(ParameterKeys.user2Id.rawValue)=\(user2Id)"
        let queryUrl = "\(url)?\(params)"
        let (data, _) = try await BasicAPI.basicHTTPCallWithoutToken(url: queryUrl, jsonData: Data(), method: HTTPMethods.GET.rawValue)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([Message].self, from: data)
    }
}
