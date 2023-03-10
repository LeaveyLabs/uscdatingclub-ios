//
//  User.swift
//  mist-ios
//
//  Created by Adam Novak on 2022/03/06.
//

import Foundation
import UIKit
import MessageKit

//MARK: - Protocols

protocol ReadOnlyUserType {
    var id: Int { get }
    var firstLastName: String { get }
    var firstName: String { get }
    var lastName: String { get }
//    var picture: String { get }
}

protocol CompleteUserType: ReadOnlyUserType {
    var phoneNumber: String { get }
    var email: String { get }
    var sexIdentity: String { get }
    var sexPreference: String { get }
    var school: String? { get }
    var isMatchable: Bool { get }
    var surveyResponses: [SurveyResponse] { get }
    var token: String { get }
    var isSuperuser: Bool { get }
}

//MARK: - Structs

struct ReadOnlyUser: ReadOnlyUserType, SenderType, Codable, Hashable {
    
    let id: Int
    let firstName: String
    let lastName: String
    var firstLastName: String { firstName + " " + lastName }
//    let picture: String
    
    //MessageKit's SenderType
    var senderId: String { return String(id) }
    var displayName: String { return firstName }
    
    //Equatable
    static func == (lhs: ReadOnlyUser, rhs: ReadOnlyUser) -> Bool { return lhs.id == rhs.id }
    
    //Hashable
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct CompleteUser: Codable, CompleteUserType, SenderType {
    
    let id: Int
    let firstName: String
    let lastName: String
    var firstLastName: String { firstName + " " + lastName }
    var school: String? { email.slice(from: "@", to: "." )}
//    let picture: String
    let email: String
    let sexIdentity: String
    let sexPreference: String
    let phoneNumber: String
    let isMatchable: Bool
    let surveyResponses: [SurveyResponse]
    let token: String
    let isSuperuser: Bool
    
    //MessageKit's SenderType
    var senderId: String { return String(id) }
    var displayName: String { return firstName }
    
    //Equatable
    static func == (lhs: CompleteUser, rhs: CompleteUser) -> Bool { return lhs.id == rhs.id }
    
}

struct FrontendCompleteUser: Codable, CompleteUserType, ReadOnlyUserType {
    
    // CompleteUserBackendProperties
    let id: Int
    let email: String
    let phoneNumber: String
    let firstName: String
    let lastName: String
    var firstLastName: String { firstName + " " + lastName }
    var school: String? { email.slice(from: "@", to: "." )}
    //    var picture: String
    let sexIdentity: String
    let sexPreference: String
    let isMatchable: Bool
    let surveyResponses: [SurveyResponse]
    let token: String
    let isSuperuser: Bool
    
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
        self.isSuperuser = completeUser.isSuperuser
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
        case isSuperuser
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
        isSuperuser = try values.decodeIfPresent(Bool.self, forKey: .isSuperuser) ?? false
    }
    
    //Equatable
    static func == (lhs: FrontendCompleteUser, rhs: FrontendCompleteUser) -> Bool { return lhs.id == rhs.id }
    
    static let nilUser = FrontendCompleteUser(completeUser: CompleteUser(id: -1, firstName: "", lastName: "", email: "", sexIdentity: "", sexPreference: "", phoneNumber: "", isMatchable: false, surveyResponses: [], token: "", isSuperuser: false))
}
