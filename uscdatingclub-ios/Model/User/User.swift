//
//  User.swift
//  mist-ios
//
//  Created by Adam Novak on 2022/03/06.
//

import Foundation
import UIKit

//MARK: - Protocols

protocol ReadOnlyUserType {
    var id: Int { get }
    var firstName: String { get }
    var lastName: String { get }
//    var picture: String { get }
}

protocol CompleteUserType: ReadOnlyUserType {
    var phoneNumber: String { get }
    var email: String { get }
    var sexIdentity: String { get }
    var sexPreference: String { get }
    var isMatchable: Bool { get }
    var surveyResponses: [SurveyResponse] { get }
    var token: String { get }
}

//MARK: - Structs

struct ReadOnlyUser: Codable, ReadOnlyUserType, Hashable {
    
    let id: Int
    let firstName: String
    let lastName: String
//    let picture: String
    
    //Equatable
    static func == (lhs: ReadOnlyUser, rhs: ReadOnlyUser) -> Bool { return lhs.id == rhs.id }
    
    //Hashable
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct CompleteUser: Codable, CompleteUserType {
    
    let id: Int
    let firstName: String
    let lastName: String
//    let picture: String
    let email: String
    let sexIdentity: String
    let sexPreference: String
    let phoneNumber: String
    var isMatchable: Bool
    var surveyResponses: [SurveyResponse]
    let token: String
    
    //Equatable
    static func == (lhs: CompleteUser, rhs: CompleteUser) -> Bool { return lhs.id == rhs.id }
    
}

struct FrontendCompleteUser: Codable, CompleteUserType, ReadOnlyUserType {
    
    // CompleteUserBackendProperties
    let id: Int
    var email: String
    var phoneNumber: String
    var firstName: String
    var lastName: String
    //    var picture: String
    var sexIdentity: String
    var sexPreference: String
    var isMatchable: Bool
    var surveyResponses: [SurveyResponse]
    let token: String
    
    // Complete-only properties
    //    var profilePicWrapper: ProfilePicWrapper
    
    init(completeUser: CompleteUser) { //}, profilePicWrapper: ProfilePicWrapper) {
        self.id = completeUser.id
        self.phoneNumber = completeUser.phoneNumber
        self.email = completeUser.email
        self.firstName = completeUser.firstName
        self.lastName = completeUser.lastName
//        self.picture = completeUser.picture
        self.sexIdentity = completeUser.sexIdentity
        self.sexPreference = completeUser.sexPreference
//        self.profilePicWrapper = profilePicWrapper
        self.isMatchable = completeUser.isMatchable
        self.surveyResponses = completeUser.surveyResponses
        self.token = completeUser.token
    }
    
    //Custom Codable 1, so that decoding a user when new properties are necessary doesn't force a logout
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case phoneNumber
        case firstName
        case lastName
        case sexIdentity
        case sexPreference
        case isMatchable
        case surveyResponses
        case token
    }
    
    //Custom Codable 2
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        email = try values.decode(String.self, forKey: .email)
        phoneNumber = try values.decode(String.self, forKey: .phoneNumber)
        firstName = try values.decode(String.self, forKey: .firstName)
        lastName = try values.decode(String.self, forKey: .lastName)
        sexIdentity = try values.decode(String.self, forKey: .sexIdentity)
        sexPreference = try values.decode(String.self, forKey: .sexPreference)
        surveyResponses = try values.decode([SurveyResponse].self, forKey: .surveyResponses)
        token = try values.decode(String.self, forKey: .token)
        isMatchable = try values.decodeIfPresent(Bool.self, forKey: .isMatchable) ?? false
    }
    
    //Equatable
    static func == (lhs: FrontendCompleteUser, rhs: FrontendCompleteUser) -> Bool { return lhs.id == rhs.id }
    
    static let nilUser = FrontendCompleteUser(completeUser: CompleteUser(id: -1, firstName: "", lastName: "", email: "", sexIdentity: "", sexPreference: "", phoneNumber: "", isMatchable: false, surveyResponses: [], token: ""))
}
