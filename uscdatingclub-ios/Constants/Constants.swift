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
            static let Settings = "SettingsViewController"
            static let PasswordSetting = "PasswordSettingViewController"
            static let UpdateProfile = "UpdateProfileSettingViewController"
            static let DefaultSettings = "DefaultsSettingsViewController"
            //Navigation Controllers
            static let NewPostNavigation = "NewPostNavigationController"
            static let MyActivityNavigation = "MyActivityNavigationController"
            static let AuthNavigation = "AuthNavigationController"
            //TabBar
            static let TabBarController = "TabBarController"
            //Demo
            static let HowItWorks = "HowItWorksVC"
            //Auth
            static let Permissions = "PermissionsVC"
            static let ConfirmEmail = "ConfirmEmailViewController"
//            static let WelcomeTutorial = "WelcomeTutorialViewController"
//            static let UploadProfilePicture = "UploadProfilePictureViewController"
//            static let CreatePassword = "CreatePasswordViewController"
//            static let EnterName = "EnterNameViewController"
//            static let ChooseUsername = "ChooseUsernameViewController"
//            static let SetupTime = "SetupTimeViewController"
            static let EnterBios = "EnterBiosViewController"
//            static let FinishProfile = "FinishProfileViewController"
            static let EnterNumber = "EnterNumberViewController"
            static let ConfirmNumber = "ConfirmNumberViewController"
            static let CreateProfile = "CreateProfileViewController"
            static let ConfirmCode = "ConfirmCodeViewController"
            static let RequestReset = "RequestResetNumberViewController"
//            static let ResetNumber = "ResetNumberViewController"
//            static let ExplainProfile = "ExplainProfileViewController"
            static let EnterEmail = "EnterEmailViewController"
            //Reset password
    //            static let RequestResetPassword = "RequestResetPasswordViewController"
    //            static let ValidateResetPassword = "ValidateResetPasswordViewController"
    //            static let FinalizeResetPassword = "FinalizeResetPasswordViewController"
        }
        struct Segue {
            static let ToNotificationsSetting = "ToNotificationsSetting"
            static let ToListView = "ToListView"
            static let ToExplain = "ToExplain"
        }
    }
    
}
