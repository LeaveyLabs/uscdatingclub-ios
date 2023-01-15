//
//  MatchAPI.swift
//  uscdatingclub-ios
//
//  Created by Kevin Sun on 1/11/23.
//

import Foundation
import UIKit


//https://github.com/kean/Nuke

struct MatchError: Codable {
    let user_id: [String]?
    let partner_id: [String]?
    
    let non_field_errors: [String]?
    let detail: String?
}

class MatchAPI {
    // Paths to API endpoints
    enum Endpoints: String {
        case acceptMatch = "accept-match/"
        // REST
        case matches = "matches/"
    }
    
    // Parameters for API
    enum ParameterKeys: String {
        case userId = "user_id"
        case partnerId = "partner_id"
    }
    
    static let MATCH_RECOVERY_MESSAGE = "try again later"
    
    static func throwAPIError(error: MatchError) throws {
        if let userErrors = error.user_id,
            let userError = userErrors.first {
            throw APIError.ClientError(userError, MATCH_RECOVERY_MESSAGE)
        }
        if let partnerErrors = error.partner_id,
            let partnerError = partnerErrors.first {
            throw APIError.ClientError(partnerError, MATCH_RECOVERY_MESSAGE)
        }
    }
    
    static func filterMatchErrors(data:Data, response:HTTPURLResponse) throws {
        let statusCode = response.statusCode
        
        if isSuccess(statusCode: statusCode) { return }
        if isClientError(statusCode: statusCode) {
            let error = try JSONDecoder().decode(MatchError.self, from: data)
            try throwAPIError(error: error)
        }
        throw APIError.Unknown
    }
    
    static func acceptMatch(userId:Int, partnerId:Int) async throws {
        let url = "\(Env.BASE_URL)\(Endpoints.acceptMatch.rawValue)"
        let params:[String:Int] = [
            ParameterKeys.userId.rawValue: userId,
            ParameterKeys.partnerId.rawValue: partnerId
        ]
        let json = try JSONEncoder().encode(params)
        let (data, response) = try await BasicAPI.basicHTTPCallWithToken(url: url, jsonData: json, method: HTTPMethods.PATCH.rawValue)
        try filterMatchErrors(data: data, response: response)
    }
}

