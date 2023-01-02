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
    var first_name: String { get }
    var last_name: String { get }
//    var picture: String { get }
}

protocol CompleteUserType: ReadOnlyUserType {
    var phone_number: String { get }
    var email: String { get }
    var sexualIdentity: String { get }
    var sexualPreference: String { get }
}

//MARK: - Structs

struct ReadOnlyUser: Codable, ReadOnlyUserType, Hashable {
    
    let id: Int
    let first_name: String
    let last_name: String
//    let picture: String
    
    //Equatable
    static func == (lhs: ReadOnlyUser, rhs: ReadOnlyUser) -> Bool { return lhs.id == rhs.id }
    
    //Hashable
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct CompleteUser: Codable, CompleteUserType {
    
    let id: Int
    let first_name: String
    let last_name: String
//    let picture: String
    let email: String
    let sexualIdentity: String
    let sexualPreference: String
    let phone_number: String
    
    //Equatable
    static func == (lhs: CompleteUser, rhs: CompleteUser) -> Bool { return lhs.id == rhs.id }
}

struct FrontendCompleteUser: Codable, CompleteUserType, ReadOnlyUserType {
    
    // CompleteUserBackendProperties
    let id: Int
    let phone_number: String
    var email: String
    var first_name: String
    var last_name: String
    //    var picture: String
    var sexualIdentity: String
    var sexualPreference: String
    
    // Complete-only properties
    //    var profilePicWrapper: ProfilePicWrapper
    
    init(completeUser: CompleteUser) { //}, profilePicWrapper: ProfilePicWrapper) {
        self.id = completeUser.id
        self.phone_number = completeUser.phone_number
        self.email = completeUser.email
        self.first_name = completeUser.first_name
        self.last_name = completeUser.last_name
//        self.picture = completeUser.picture
        self.sexualIdentity = completeUser.sexualIdentity
        self.sexualPreference = completeUser.sexualPreference
//        self.profilePicWrapper = profilePicWrapper
    }
    
    //Equatable
    static func == (lhs: FrontendCompleteUser, rhs: FrontendCompleteUser) -> Bool { return lhs.id == rhs.id }
    
    static let nilUser = FrontendCompleteUser(completeUser: CompleteUser(id: -1, first_name: "", last_name: "", email: "", sexualIdentity: "", sexualPreference: "", phone_number: ""))
}
