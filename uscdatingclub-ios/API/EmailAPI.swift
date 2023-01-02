//
//  EmailAPI.swift
//  uscdatingclub-ios
//
//  Created by Kevin Sun on 12/29/22.
//

import Foundation

// Token Format
struct APIToken: Codable {
    let token:String;
}

// Error Formats
struct EmailError: Codable {
    let email: [String]?
    let code: [String]?
    // Errors
    let non_field_errors: [String]?
    let detail: String?
}

class EmailAPI {
    // Paths to API endpoints
    enum Endpoints: String {
        case sendCode = "send-email-code/"
        case verifyCode = "verify-email-code/"
    }
    
    // Parameters for API
    enum ParameterKeys: String {
        case email = "email"
        case proxyUuid = "proxy_uuid"
        case code = "code"
    }
    
    static let EMAIL_RECOVERY_MESSAGE = "try again"
    
    static func filterEmailErrors(data: Data, response: HTTPURLResponse) throws {
        let statusCode = response.statusCode
        
        if isSuccess(statusCode: statusCode) { return }
        if isClientError(statusCode: statusCode) {
            let error = try JSONDecoder().decode(EmailError.self, from: data)
            if let emailErrors = error.email,
               let emailError = emailErrors.first {
                throw APIError.ClientError(emailError, EMAIL_RECOVERY_MESSAGE)
            }
            if let codeErrors = error.code,
               let codeError = codeErrors.first {
                throw APIError.ClientError(codeError, EMAIL_RECOVERY_MESSAGE)
            }
        }
        throw APIError.Unknown
    }
    
    static func requestCode(email:String, uuid:String) async throws {
        let url = "\(Env.BASE_URL)\(Endpoints.sendCode)"
        let params = [
            ParameterKeys.email.rawValue: email,
            ParameterKeys.proxyUuid.rawValue: uuid,
        ]
        let json = try JSONEncoder().encode(params)
        let (data, response) = try await BasicAPI.basicHTTPCallWithoutToken(url: url, jsonData: json, method: HTTPMethods.POST.rawValue)
        try filterEmailErrors(data: data, response: response)
    }
    
    static func verifyCode(email:String, code:String, uuid:String) async throws {
        let url = "\(Env.BASE_URL)\(Endpoints.verifyCode)"
        let params = [
            ParameterKeys.email.rawValue: email,
            ParameterKeys.code.rawValue: code,
            ParameterKeys.proxyUuid.rawValue: uuid,
        ]
        let json = try JSONEncoder().encode(params)
        let (data, response) = try await BasicAPI.basicHTTPCallWithoutToken(url: url, jsonData: json, method: HTTPMethods.PATCH.rawValue)
        try filterEmailErrors(data: data, response: response)
    }
}
