//
//  UserService.swift
//  mist-ios
//
//  Created by Adam Novak on 2022/03/06.
//

import Foundation
import FirebaseAnalytics
import Mixpanel

class UserService: NSObject {
    
    //MARK: - Properties
    
    static var singleton = UserService()
    
    private var frontendCompleteUser: FrontendCompleteUser?
    private var authedUser: FrontendCompleteUser { //a wrapper for the real underlying frontendCompleteUser. if for some unknown reason, frontendCompleteUser is nil, instead of the app crashing with a force unwrap, we kick them to the home screen and log them out3
        get {
            guard let authedUser = frontendCompleteUser else {
                if isLoggedIntoApp { //another potential check: if the visible view controller belongs to Main storyboard
//                    kickUserToHomeScreenAndLogOut()
                }
                return FrontendCompleteUser.nilUser
            }
            return authedUser
        }
        set {
            frontendCompleteUser = newValue
        }
    }

    //add a local device storage object
//    private let LOCAL_FILE_APPENDING_PATH = "myaccount.json"
//    private var localFileLocation: URL!
    static let LOCAL_FILE_LOCATION = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(Constants.Filesystem.AccountPath)
    
    private var SLEEP_INTERVAL:UInt32 = 30
    
    // Called on startup so that the singleton is created and isLoggedIn is properly initialized
    var isLoggedIntoAnAccount: Bool { //"is there a frontendCompleteUser which represents them?"
        return frontendCompleteUser != nil
    }
    private var isLoggedIntoApp = false //"have they passed beyond the auth process?" becomes true after login or signup or loading a user from the documents directory
    
    
    //MARK: - Initializer
    
    private override init() {
        super.init()
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        localFileLocation = documentsDirectory.appendingPathComponent(LOCAL_FILE_APPENDING_PATH)
        
        if FileManager.default.fileExists(atPath: UserService.LOCAL_FILE_LOCATION.path) {
            self.loadUserFromFilesystem()
            isLoggedIntoApp = true
        }
    }
    
    //MARK: - Getters

    //User
    func getUser() -> FrontendCompleteUser { return authedUser }
    func getUserAsReadOnlyUser() -> ReadOnlyUser {
        return ReadOnlyUser(id: authedUser.id,
                            firstName: authedUser.firstName,
                            lastName: authedUser.lastName)
    }
    
    //Properties
    func getId() -> Int { return authedUser.id }
    func getFirstName() -> String { return authedUser.firstName.capitalizeFirstLetter() }
    func getLastName() -> String { return authedUser.lastName.capitalizeFirstLetter() }
    func getFirstLastName() -> String { return authedUser.firstName.capitalizeFirstLetter() + " " + authedUser.lastName.capitalizeFirstLetter() }
    func getPhoneNumber() -> String? { return authedUser.phoneNumber }
    func getEmail() -> String { return authedUser.email }
    func getSexPreference() -> String { return authedUser.sexPreference }
    func getSexIdentity() -> String { return authedUser.sexIdentity }
    func getIsMatchable() -> Bool { return authedUser.isMatchable }
    func getPhoneNumberPretty() -> String? { return authedUser.phoneNumber.asNationalPhoneNumber }
    func getSurveyResponses() -> [SurveyResponse] { return authedUser.surveyResponses }
    func isFirstTest() -> Bool { return authedUser.surveyResponses.isEmpty }
    func isSuperuser() -> Bool { return authedUser.isSuperuser }

//    func getProfilePic() -> UIImage { return authedUser.profilePicWrapper.image }
    
    //MARK: - Login and create user
    
    // No need to return new user from createAccount() bc new user is globally updated within this function
    func createUser(firstName: String,
                    lastName: String,
                    phoneNumber: String,
                    email: String,
                    sexIdentity: String,
                    sexPreference: String) async throws {
        let newCompleteUser = try await UserAPI.registerUser(email: email,
                                       phoneNumber: phoneNumber,
                                       firstName: firstName,
                                       lastName: lastName,
                                       sexIdentity: sexIdentity,
                                       sexPreference: sexPreference)
        setGlobalAuthToken(token: newCompleteUser.token)
        authedUser = FrontendCompleteUser(completeUser: newCompleteUser)
        Mixpanel.mainInstance().identify(distinctId: String(authedUser.id))
        updateAnalyticsProperties()
//        Mixpanel.mainInstance().createAlias(newCompleteUser.firstLastName,
//                                            distinctId: Mixpanel.mainInstance().distinctId)
        await self.saveUserToFilesystem()
        Task { await waitAndRegisterDeviceToken(id: authedUser.id) }
        isLoggedIntoApp = true
    }

    func logInWith(completeUser: CompleteUser) async throws {
        Task { await waitAndRegisterDeviceToken(id: completeUser.id) }
        authedUser = FrontendCompleteUser(completeUser: completeUser)
        Mixpanel.mainInstance().identify(distinctId: String(authedUser.id))
        updateAnalyticsProperties()
        await self.saveUserToFilesystem()
        isLoggedIntoApp = true
    }
//
//    //MARK: - Update user
//
    func updateUser(firstName: String, lastName: String, sexIdentity: String, sexPreference: String) async throws {
        let updatedUser = CompleteUser(id: authedUser.id, firstName: firstName, lastName: lastName, email:authedUser.email, sexIdentity: sexIdentity, sexPreference: sexPreference, phoneNumber: authedUser.phoneNumber, isMatchable: authedUser.isMatchable, surveyResponses: authedUser.surveyResponses, token: authedUser.token, isSuperuser: authedUser.isSuperuser)
        try await UserAPI.updateUser(id:updatedUser.id, user:updatedUser)
        authedUser = FrontendCompleteUser(completeUser: updatedUser)
        updateAnalyticsProperties()
        Task { await self.saveUserToFilesystem() }
    }
    
    func updateMatchableStatus(active: Bool) async throws {
        let updatedUser = CompleteUser(id: authedUser.id, firstName: authedUser.firstName, lastName: authedUser.lastName, email:authedUser.email, sexIdentity: authedUser.sexIdentity, sexPreference: authedUser.sexPreference, phoneNumber: authedUser.phoneNumber, isMatchable: active, surveyResponses: authedUser.surveyResponses, token: authedUser.token, isSuperuser: authedUser.isSuperuser)
        try await UserAPI.updateMatchableStatus(matchableStatus: active, email: authedUser.email)
        //LocationManager start/stop updating location is handled in RadarVC on rerender right now
        authedUser = FrontendCompleteUser(completeUser: updatedUser)
        updateAnalyticsProperties()
        Task { await self.saveUserToFilesystem() }
    }
    
    func updateTestResponses(newResponses: [SurveyResponse]) async throws {
        let updatedUser = CompleteUser(id: authedUser.id, firstName: authedUser.firstName, lastName: authedUser.lastName, email:authedUser.email, sexIdentity: authedUser.sexIdentity, sexPreference: authedUser.sexPreference, phoneNumber: authedUser.phoneNumber, isMatchable: authedUser.isMatchable, surveyResponses: newResponses, token: authedUser.token, isSuperuser: authedUser.isSuperuser)
        try await UserAPI.postSurveyAnswers(email: authedUser.email, surveyResponses: newResponses)
        authedUser = FrontendCompleteUser(completeUser: updatedUser)
        updateAnalyticsProperties()
        Task { await self.saveUserToFilesystem() }
    }
    
//
//    //MARK: - Logout and delete user

    func kickUserToHomeScreenAndLogOut() async throws {
        //they might already be logged out, so don't try and logout again. this will cause an infinite loop for checkingAuthedUser :(
        if isLoggedIntoAnAccount {
            try await logOutFromDevice()
        }
        DispatchQueue.main.async {
            transitionToAuth()
        }
    }

    func deleteMyAccount() async throws {
        guard isLoggedIntoAnAccount else { return } //prevents infinite loop on authedUser didSet
        try await UserAPI.deleteUser(email: authedUser.email)
        removeLocalUser()
    }
    
    private func logOutFromDevice() async throws {
        try await UserAPI.updateMatchableStatus(matchableStatus: false, email: UserService.singleton.getEmail())
        guard isLoggedIntoAnAccount else { return } //prevents infinite loop on authedUser didSet
        if getGlobalDeviceToken() != "" {
            Task { try await DeviceAPI.disableCurrentDeviceNotificationsForUser(user: authedUser.id) }
        }
        removeLocalUser()
    }
    
    private func removeLocalUser() {
        //reset any caches
        setGlobalAuthToken(token: "")
        Mixpanel.mainInstance().reset()
        Mixpanel.mainInstance().identify(distinctId: UUID().uuidString)
        Mixpanel.mainInstance().flush()
        Analytics.resetAnalyticsData()
        LocationManager.shared.stopLocationServices()
        eraseUserFromFilesystem()
        frontendCompleteUser = nil
        isLoggedIntoApp = false
    }

//    //MARK: - Firebase

    func updateAnalyticsProperties() {
        Mixpanel.mainInstance().people.set(
            properties:[Constants.MP.Profile.SexualIdentity:authedUser.sexIdentity,
                        Constants.MP.Profile.SexualPreference:authedUser.sexPreference,
                        Constants.MP.Profile.School:authedUser.school ?? ""])
        //Firebase
        Analytics.setUserID(String(authedUser.id))
        Analytics.setUserProperty(authedUser.sexIdentity, forName: Constants.MP.Profile.SexualIdentity)
        Analytics.setUserProperty(authedUser.sexPreference, forName: Constants.MP.Profile.SexualPreference)
        Analytics.setUserProperty(authedUser.school ?? "", forName: Constants.MP.Profile.School)
    }

//    //MARK: - Filesystem

    func saveUserToFilesystem() async {
        do {
            let encoder = JSONEncoder()
            let data: Data = try encoder.encode(authedUser)
            let jsonString = String(data: data, encoding: .utf8)!
            try jsonString.write(to: UserService.LOCAL_FILE_LOCATION, atomically: true, encoding: .utf8)
        } catch {
            print("COULD NOT SAVE: \(error)")
        }
    }

    func loadUserFromFilesystem() {
        do {
            let data = try Data(contentsOf: UserService.LOCAL_FILE_LOCATION)
            authedUser = try JSONDecoder().decode(FrontendCompleteUser.self, from: data)
            setGlobalAuthToken(token: authedUser.token) //this shouldn't be necessary, but to be safe
            Task { await waitAndRegisterDeviceToken(id: authedUser.id) }
        } catch {
            print("COULD NOT LOAD: \(error)")
        }
    }

    func eraseUserFromFilesystem() {
        do {
            setGlobalAuthToken(token: "")
            try FileManager.default.removeItem(at: UserService.LOCAL_FILE_LOCATION)
        } catch {
            print("\(error)")
        }
    }

    // MARK: - Device Notifications

    func waitAndRegisterDeviceToken(id:Int) async {
        do {
            while true {
                if getGlobalDeviceToken() != "" && getGlobalAuthToken() != "" {
                    try await DeviceAPI.registerCurrentDeviceWithUser(user: id)
                }
                try await Task.sleep(nanoseconds: NSEC_PER_SEC * UInt64(SLEEP_INTERVAL))
            }
        } catch {
            print("\(error)")
            print("ERROR WAITING TO REGISTER DEVICE TOKEN")
        }
    }
}
