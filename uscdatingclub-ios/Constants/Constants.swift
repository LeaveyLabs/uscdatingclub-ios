//
//  Constants.swift
//  timewellspent-ios
//
//  Created by Adam Novak on 2022/11/19.
//

import Foundation

enum Constants {
    
    struct Font {
        static let Light: String = "Avenir-Light"
        static let Roman: String = "Avenir-Roman"
        static let Medium: String = "Avenir-Medium"
        static let Heavy: String = "Avenir-Heavy"
        static let Book: String = "Avenir-Book"
        static let Black: String = "Avenir-Black"
        static let Size: CGFloat = 20
    }
    
    static let maxPasswordLength = 1000

    // Note: all nib names should be the same ss their storyboard ID
    struct SBID {
        struct View {
            //Post
            static let Post = "PostView"
        }
        struct SB {
            static let Main = "Main"
            static let Launch = "Launch"
            static let Auth = "Auth"
            static let Misc = "Misc"
        }
        struct Cell {
            static let HowItWorksCell = "HowItWorksCell"
            static let SurveyCell = "SurveyCell"
        }
        struct VC {
            //Home
            static let About = "AboutVC"
            static let Radar = "RadarVC"
            static let Account = "AccountVC"
            //Settings
            static let Settings = "SettingsVC"
            static let UpdateProfile = "UpdateProfileSettingVC"
            static let DefaultSettings = "DefaultsSettingsVC"
            //Navigation Controllers
            
            //TabBar
            static let TabBarController = "TabBarController"
            //Misc
            static let Permissions = "PermissionsVC"
            static let HowItWorks = "HowItWorksVC"
            static let UpdateAvailable = "UpdateAvailableVC"
            static let Loading = "LoadingVC"
            //Auth
            static let AuthNav = "AuthNavVC"
            static let EnterNumber = "EnterNumberVC"
            static let ConfirmCode = "ConfirmCodeVC"
            static let EnterEmail = "EnterEmailVC"
            static let CreateProfile = "CreateProfileVC"
            static let EnterBios = "EnterBiosVC"
            
            //Reset password
    //            static let RequestReset = "RequestResetNumberViewController"
    //            static let RequestResetPassword = "RequestResetPasswordViewController"
    //            static let ValidateResetPassword = "ValidateResetPasswordViewController"
    //            static let FinalizeResetPassword = "FinalizeResetPasswordViewController"
            
        }
        struct Segue {
            static let ToExplain = "ToExplain"
        }
    }
    
}
