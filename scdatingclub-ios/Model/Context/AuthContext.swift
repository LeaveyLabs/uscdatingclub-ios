//
//  AuthContext.swift
//  mist-ios
//
//  Created by Adam Novak on 2022/05/25.
//

import UIKit

struct AuthContext {
    static let APPLE_PHONE_NUMBER: String = "13103103101"
    static let APPLE_CODE: String = "123456"
    
    static let uuid: String = UUID().uuidString
    
    static var email: String = ""
    static var phoneNumber: String = ""
    static var firstName: String = ""
    static var lastName: String = ""
    static var profilePic: UIImage? = UIImage(systemName: "")
//    static var sexualIdentity: String = ""
//    static var sexualPreference: String = ""
//    static var dob: String = ""
//    static var resetToken: ResetToken = ""
    
    static func reset() {
        email = ""
        phoneNumber = ""
        firstName = ""
        lastName = ""
        profilePic = UIImage(systemName: "")
//        sexualIdentity = ""
//        sexualPreference = ""
//        dob = ""
//        resetToken = ""
    }
}
