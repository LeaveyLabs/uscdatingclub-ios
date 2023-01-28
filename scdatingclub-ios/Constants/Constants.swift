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
    
    struct Filesystem {
        static let AccountPath: String = "myaccount.json"
    }
    
    struct UserDefaultsKeys {
        static let isOnWaitList: String = "isOnWaitList"
        static let MostRecentNotifiationStorageKey: String = "mostRecentNotification"
        static let MostRecentMeetUpButtonPressDate: String = "mostRecentMeetUpBuyttonPressDate"
    }

    static let appDisplayName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String
    static let appTechnicalName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String

    static let defaultMailLink = URL(string: "mailto://")!
    static let gmailLink = URL(string: "googlegmail://")!
    static let faqLink = URL(string: "https://scdatingclub.com/faq")!
    static let appStoreLink = URL(string: "https://apps.apple.com/app/apple-store/id1661018857")!
    static let landingPageLink = URL(string: "https://scdatingclub.com")!
    static let privacyPageLink = URL(string: "https://scdatingclub.com/privacy")!
    static let termsLink = URL(string: "https://scdatingclub.com/terms")!
    static let feedbackLink = URL(string: "https://forms.gle/151vRvEa11Tnn3CC7")!
    static let contactLink = URL(string: "mailto:leaveylabs@gmail.com")!

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
            static let Connect = "Connect"
        }
        struct Cell {
            static let HowItWorksCell = "HowItWorksCell"
            static let SpectrumTestCell = "SpectrumTestCell"
            static let SelectionHeaderCell = "SelectionHeaderTestCell"
            static let SelectionCell = "SelectionTestCell"
            static let SelectionTableViewCell = "SelectionTableViewCell"
            static let SimpleButtonCell = "SimpleButtonCell"
            static let SimpleEntryCell = "SimpleEntryCell"
            static let SimpleTitleCell = "SimpleTitleCell"
            static let PermissionsCell = "PermissionsCell"
            //Match
            static let ConnectHeaderCell = "ConnectHeaderCell"
            static let ConnectTitleCell = "ConnectTitleCell"
            static let ConnectSpectrumCell = "ConnectSpectrumCell"
            static let ConnectInterestsCell = "ConnectInterestsCell"
        }
        struct VC {
            //Home
            static let About = "AboutVC"
            static let Radar = "RadarVC"
            static let Account = "AccountVC"
            static let TakeTheTest = "TakeTheTestVC"
            static let ForgeMatch = "ForgeMatchVC"
            //Test
            static let TestText = "TestTextVC"
            static let TestQuestions = "TestQuestionsVC"
            //Settings
            static let EditAccount = "EditAccountVC"
            //Navigation Controllers
            
            //Connect
            static let MatchFoundTable = "MatchFoundTableVC"
            static let MatchFound = "MatchFoundVC"
            static let Coordinate = "CoordinateVC"
            static let CoordinateChat = "CoordinateChatVC"
            //TabBar
            static let TabBarController = "TabBarController"
            //Misc
            static let Permissions = "PermissionsVC"
            static let PermissionsTable = "PermissionsTableVC"
            static let HowItWorks = "HowItWorksVC"
            static let UpdateAvailable = "UpdateAvailableVC"
            static let Loading = "LoadingVC"
            static let Sheet = "SheetVC"
            //Auth
            static let ScreenDemo = "ScreenDemoVC"
            static let AuthStart = "AuthStartVC"
            static let AuthStartPage = "AuthStartPageVC"
            static let AuthNav = "AuthNavVC"
            static let EnterNumber = "EnterNumberVC"
            static let ConfirmCode = "ConfirmCodeVC"
            static let EnterEmail = "EnterEmailVC"
            static let CreateProfile = "CreateProfileVC"
            static let EnterBios = "EnterBiosVC"
            static let WaitList = "WaitListVC"

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
