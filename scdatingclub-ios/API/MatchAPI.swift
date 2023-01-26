//
//  MatchAPI.swift
//  scdatingclub-ios
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
        case forceCreateMatch = "force-create-match/"
        case stopSharingLocation = "stop-sharing-location/"
        // REST
        case matches = "matches/"
    }
    
    // Parameters for API
    enum ParameterKeys: String {
        case userId = "user_id"
        case partnerId = "partner_id"
        case user1 = "user1"
        case user2 = "user2"
        case user1Id = "user1_id"
        case user2Id = "user2_id"
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
    
    static func postMatch(user1Id:Int, user2Id:Int) async throws {
        let url = "\(Env.BASE_URL)\(Endpoints.matches.rawValue)"
        let params = [
            ParameterKeys.user1.rawValue: String(user1Id),
            ParameterKeys.user2.rawValue: String(user2Id)
        ]
        let json = try JSONEncoder().encode(params)
        let (data, response) = try await BasicAPI.basicHTTPCallWithToken(url: url, jsonData: json, method: HTTPMethods.POST.rawValue)
        try filterMatchErrors(data: data, response: response)
    }
    
    static func forceCreateMatch(user1Id:Int, user2Id:Int) async throws {
        let url = "\(Env.BASE_URL)\(Endpoints.forceCreateMatch.rawValue)"
        let params = [
            ParameterKeys.user1Id.rawValue: String(user1Id),
            ParameterKeys.user2Id.rawValue: String(user2Id)
        ]
        let json = try JSONEncoder().encode(params)
        let (data, response) = try await BasicAPI.basicHTTPCallWithToken(url: url, jsonData: json, method: HTTPMethods.POST.rawValue)
        try filterMatchErrors(data: data, response: response)
    }
    
    static func stopSharingLocation(selfId:Int, partnerId:Int) async throws {
        let url = "\(Env.BASE_URL)\(Endpoints.stopSharingLocation.rawValue)"
        let params:[String:String] = [
            ParameterKeys.user1Id.rawValue: String(selfId),
            ParameterKeys.user2Id.rawValue: String(partnerId)
        ]
        let json = try JSONEncoder().encode(params)
        let (data, response) = try await BasicAPI.basicHTTPCallWithoutToken(url: url, jsonData: json, method: HTTPMethods.POST.rawValue)
        try filterMatchErrors(data: data, response: response)
    }
}

