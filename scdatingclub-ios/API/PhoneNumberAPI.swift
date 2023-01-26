//
//  PhoneNumberAPI.swift
//  scdatingclub-ios
//
//  Created by Kevin Sun on 12/29/22.
//

import Foundation

typealias ResetToken = String

struct PhoneNumberError: Codable {
    let phone_number: [String]?
    let code: [String]?
    let token: [String]?
    // Error
    let non_field_errors: [String]?
    let detail: String?
}

class PhoneNumberAPI {
    // Paths to API endpoints
    enum Endpoints: String {
        case sendCode = "send-phone-code/"
        case verifyCode = "verify-phone-code/"
    }
    
    // Parameters for API
    enum ParameterKeys: String {
        case phone = "phone_number"
        case proxyUuid = "proxy_uuid"
        case code = "code"
        case isRegistration = "is_registration"
    }
    
    static let PHONE_NUMBER_RECOVERY_MESSAGE = "Please try again"
    
    static func filterPhoneNumberErrors(data:Data, response:HTTPURLResponse) throws {
        let statusCode = response.statusCode
        
        if isSuccess(statusCode: statusCode) { return }
        if isClientError(statusCode: statusCode) {
            let error = try JSONDecoder().decode(PhoneNumberError.self, from: data)
            
            if let phoneNumberErrors = error.phone_number,
               let phoneNumberError = phoneNumberErrors.first {
                throw APIError.ClientError(phoneNumberError, PHONE_NUMBER_RECOVERY_MESSAGE)
            }
            if let codeErrors = error.code,
               let codeError = codeErrors.first {
                throw APIError.ClientError(codeError, PHONE_NUMBER_RECOVERY_MESSAGE)
            }
            
        }
        throw APIError.Unknown
    }
    
    
    static func requestCode(phoneNumber:String, uuid:String) async throws {
        let url = "\(Env.BASE_URL)\(Endpoints.sendCode.rawValue)"
        let params:[String:String] = [
            ParameterKeys.phone.rawValue: phoneNumber,
            ParameterKeys.proxyUuid.rawValue: uuid,
        ]
        let json = try JSONEncoder().encode(params)
        let (data, response) = try await BasicAPI.basicHTTPCallWithoutToken(url: url, jsonData: json, method: HTTPMethods.POST.rawValue)
        try filterPhoneNumberErrors(data: data, response: response)
    }
    
    static func verifyCode(phoneNumber:String, code:String, uuid:String) async throws -> CompleteUser? {
        let url = "\(Env.BASE_URL)\(Endpoints.verifyCode.rawValue)"
        let params:[String:String] = [
            ParameterKeys.phone.rawValue: phoneNumber,
            ParameterKeys.code.rawValue: code,
            ParameterKeys.proxyUuid.rawValue: uuid,
        ]
        let json = try JSONEncoder().encode(params)
        let (data, response) = try await BasicAPI.basicHTTPCallWithoutToken(url: url, jsonData: json, method: HTTPMethods.PATCH.rawValue)
        try filterPhoneNumberErrors(data: data, response: response)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let completeUser = try decoder.decode(CompleteUser.self, from: data)
            setGlobalAuthToken(token: completeUser.token)
            return completeUser            
        }
        catch is DecodingError {
            return nil
        }
    }
}
