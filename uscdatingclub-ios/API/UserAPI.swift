//
//  UserAPI.swift
//  uscdatingclub-ios
//
//  Created by Kevin Sun on 12/29/22.
//

import Foundation
import UIKit

extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}

//https://github.com/kean/Nuke

struct UserError: Codable {
    let email: [String]?
    let phone_number: [String]?
    let first_name: [String]?
    let last_name: [String]?
    let sex_identity: [String]?
    let sex_preference: [String]?
    let latitude: [String]?
    let longitude: [String]?
    
    let non_field_errors: [String]?
    let detail: String?
}

class UserAPI {
    // Paths to API endpoints
    enum Endpoints: String {
        case registerUser = "register-user/"
        case postSurveyAnswers = "post-survey-answers/"
        case updateLocation = "update-location/"
        case matchUsers = "match-users/"
        case deleteAccount = "delete-account/"
    }
    
    // Parameters for API
    enum ParameterKeys: String {
        case email = "email"
        case phone = "phone_number"
        case firstName = "first_name"
        case lastName = "last_name"
        case sexIdentity = "sex_identity"
        case sexPreference = "sex_preference"
        case latitude = "latitude"
        case longitude = "longitude"
        case responses = "responses"
    }
    
    static let USER_RECOVERY_MESSAGE = "try again later"
    
    static func throwAPIError(error: UserError) throws {
        if let emailErrors = error.email,
            let emailError = emailErrors.first {
            throw APIError.ClientError(emailError, USER_RECOVERY_MESSAGE)
        }
        if let firstNameErrors = error.first_name,
           let firstNameError = firstNameErrors.first {
            throw APIError.ClientError(firstNameError, USER_RECOVERY_MESSAGE)
        }
        if let lastNameErrors = error.last_name,
           let lastNameError = lastNameErrors.first {
            throw APIError.ClientError(lastNameError, USER_RECOVERY_MESSAGE)
        }
        if let sexIdentityErrors = error.sex_identity,
           let sexIdentityError = sexIdentityErrors.first{
            throw APIError.ClientError(sexIdentityError, USER_RECOVERY_MESSAGE)
        }
        if let sexPreferenceErrors = error.sex_preference,
           let sexPreferenceError = sexPreferenceErrors.first{
            throw APIError.ClientError(sexPreferenceError, USER_RECOVERY_MESSAGE)
        }
        if let latitudeErrors = error.latitude,
           let latitudeError = latitudeErrors.first{
            throw APIError.ClientError(latitudeError, USER_RECOVERY_MESSAGE)
        }
        if let longitudeErrors = error.longitude,
           let longitudeError = longitudeErrors.first{
            throw APIError.ClientError(longitudeError, USER_RECOVERY_MESSAGE)
        }
        if let detailError = error.detail {
            throw APIError.ClientError(detailError, USER_RECOVERY_MESSAGE)
        }
    }
    
    static func filterUserErrors(data:Data, response:HTTPURLResponse) throws {
        let statusCode = response.statusCode
        
        if isSuccess(statusCode: statusCode) { return }
        if isClientError(statusCode: statusCode) {
            let error = try JSONDecoder().decode(UserError.self, from: data)
            try throwAPIError(error: error)
        }
        throw APIError.Unknown
    }
    
    static func registerUser(email:String,
                             phoneNumber:String,
                             firstName: String,
                             lastName: String,
                             sexIdentity: Int,
                             sexPreference: Int) async throws {
        let url =  "\(Env.BASE_URL)\(Endpoints.registerUser.rawValue)"
        let params:[String:String] = [
            ParameterKeys.email.rawValue: email,
            ParameterKeys.phone.rawValue: phoneNumber,
            ParameterKeys.firstName.rawValue: firstName,
            ParameterKeys.lastName.rawValue: lastName,
            ParameterKeys.sexIdentity.rawValue: String(sexIdentity),
            ParameterKeys.sexPreference.rawValue: String(sexPreference),
        ]
        let json = try JSONEncoder().encode(params)
        let (data, response) = try await BasicAPI.basicHTTPCallWithToken(url: url, jsonData: json, method: HTTPMethods.POST.rawValue)
        try filterUserErrors(data: data, response: response)
    }
    
    static func postSurveyAnswers(email:String,
                                  responses:[Int]) async throws {
        let url = "\(Env.BASE_URL)\(Endpoints.postSurveyAnswers.rawValue)"
        var params:[String:String] = [
            ParameterKeys.email.rawValue: email,
        ]
        for response in responses {
            params[ParameterKeys.responses.rawValue] = String(response)
        }
        let json = try JSONEncoder().encode(params)
        let (data, response) = try await BasicAPI.basicHTTPCallWithToken(url: url, jsonData: json, method: HTTPMethods.POST.rawValue)
        try filterUserErrors(data: data, response: response)
    }
    
    static func updateLocation(latitude:Double, longitude:Double, email:String) async throws {
        let url =  "\(Env.BASE_URL)\(Endpoints.updateLocation.rawValue)"
        let params:[String:String] = [
            ParameterKeys.email.rawValue: email,
            ParameterKeys.latitude.rawValue: String(latitude),
            ParameterKeys.longitude.rawValue: String(longitude),
        ]
        let json = try JSONEncoder().encode(params)
        let (data, response) = try await BasicAPI.basicHTTPCallWithToken(url: url, jsonData: json, method: HTTPMethods.PATCH.rawValue)
        try filterUserErrors(data: data, response: response)
    }
    
    static func deleteUser(email:String) async throws {
        let url =  "\(Env.BASE_URL)\(Endpoints.deleteAccount.rawValue)"
        let params:[String:String] = [
            ParameterKeys.email.rawValue: email,
        ]
        let json = try JSONEncoder().encode(params)
        let (data, response) = try await BasicAPI.basicHTTPCallWithToken(url: url, jsonData: json, method: HTTPMethods.DELETE.rawValue)
        try filterUserErrors(data: data, response: response)
    }
}
