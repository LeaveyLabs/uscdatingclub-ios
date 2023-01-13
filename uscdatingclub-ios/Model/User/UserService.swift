//
//  UserService.swift
//  mist-ios
//
//  Created by Adam Novak on 2022/03/06.
//

import Foundation
import FirebaseAnalytics

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
    
    //private initializer because there will only ever be one instance of UserService, the singleton
    private override init() {
        super.init()
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        localFileLocation = documentsDirectory.appendingPathComponent(LOCAL_FILE_APPENDING_PATH)
        
        if FileManager.default.fileExists(atPath: UserService.LOCAL_FILE_LOCATION.path) {
            self.loadUserFromFilesystem()
            setupFirebaseAnalyticsProperties()
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
    func getFirstName() -> String { return authedUser.firstName }
    func getLastName() -> String { return authedUser.lastName }
    func getFirstLastName() -> String { return authedUser.firstName + " " + authedUser.lastName }
    func getPhoneNumber() -> String? { return authedUser.phoneNumber }
    func getEmail() -> String { return authedUser.email }
    func getSexPreference() -> String { return authedUser.sexPreference }
    func getSexIdentity() -> String { return authedUser.sexIdentity }
    func getIsMatchable() -> Bool { return authedUser.isMatchable }
    func getPhoneNumberPretty() -> String? { return authedUser.phoneNumber.asNationalPhoneNumber }
    func getSurveyResponses() -> [SurveyResponse] { return authedUser.surveyResponses }
//    func getProfilePic() -> UIImage { return authedUser.profilePicWrapper.image }
    
    //MARK: - Login and create user
    
    // No need to return new user from createAccount() bc new user is globally updated within this function
    func createUser(firstName: String,
                    lastName: String,
                    phoneNumber: String,
                    email: String,
                    sexIdentity: String,
                    sexPreference: String) async throws {
//        let newProfilePicWrapper = ProfilePicWrapper(image: profilePic, withCompresssion: true)
//        let compressedProfilePic = newProfilePicWrapper.image
        try await UserAPI.registerUser(email: email,
                                       phoneNumber: phoneNumber,
                                       firstName: firstName,
                                       lastName: lastName,
                                       sexIdentity: sexIdentity,
                                       sexPreference: sexPreference)
//        setGlobalAuthToken(token: token)
//        let completeUser = try await UserAPI.fetchAuthedUserByToken(token: token)
//        frontendCompleteUser = FrontendCompleteUser(completeUser: completeUser,
//                                                    profilePicWrapper: newProfilePicWrapper,
//                                                    token: token)
//        authedUser = frontendCompleteUser!
        await self.saveUserToFilesystem()
//        Task { await waitAndRegisterDeviceToken(id: completeUser.id) }
        Task {
            setupFirebaseAnalyticsProperties() //must come later at the end of this process so that we dont access authedUser while it's null and kick the user to the home screen
        }
        isLoggedIntoApp = true
    }

    func logInWith(completeUser: CompleteUser) async throws {
        Task { await waitAndRegisterDeviceToken(id: completeUser.id) }
        
//        guard let profilePicUIImage = try await GenericAPI.UIImageFromURLString(url: completeUser.picture) else {
//            throw NSError()
//        }
        
        frontendCompleteUser = FrontendCompleteUser(completeUser: completeUser)
        setupFirebaseAnalyticsProperties()
        await self.saveUserToFilesystem()
        isLoggedIntoApp = true
    }
//
//    //MARK: - Update user
//
    func updateUser(firstName: String, lastName: String, sexIdentity: String, sexPreference: String) async throws {
        let updatedUser = CompleteUser(id: authedUser.id, firstName: firstName, lastName: lastName, email:authedUser.email, sexIdentity: authedUser.sexIdentity, sexPreference: authedUser.sexPreference, phoneNumber: authedUser.phoneNumber, isMatchable: authedUser.isMatchable, surveyResponses: authedUser.surveyResponses, token: "")
        try await UserAPI.updateUser(id:updatedUser.id, user:updatedUser)
        authedUser = FrontendCompleteUser(completeUser: updatedUser)
        Task { await self.saveUserToFilesystem() }
    }
    
    func updateMatchableStatus(active: Bool) async throws {
        let updatedUser = CompleteUser(id: authedUser.id, firstName: authedUser.firstName, lastName: authedUser.lastName, email:authedUser.email, sexIdentity: authedUser.sexIdentity, sexPreference: authedUser.sexPreference, phoneNumber: authedUser.phoneNumber, isMatchable: active, surveyResponses: authedUser.surveyResponses, token: "")
        try await UserAPI.updateMatchableStatus(matchableStatus: active, email: authedUser.email)
        authedUser = FrontendCompleteUser(completeUser: updatedUser)
        Task { await self.saveUserToFilesystem() }
    }
    
    func updateTestResponses(newResponses: [Int:Any]) async throws {
        let updatedUser = CompleteUser(id: authedUser.id, firstName: authedUser.firstName, lastName: authedUser.lastName, email:authedUser.email, sexIdentity: authedUser.sexIdentity, sexPreference: authedUser.sexPreference, phoneNumber: authedUser.phoneNumber, isMatchable: authedUser.isMatchable, surveyResponses: [], token: "")
        try await UserAPI.postSurveyAnswers(email: authedUser.email, surveyResponses: [])
        authedUser = FrontendCompleteUser(completeUser: updatedUser)
        Task { await self.saveUserToFilesystem() }
    }

    // No need to return new profilePic bc it is updated globally
//    func updateProfilePic(to newProfilePic: UIImage) async throws {
//        guard let frontendCompleteUser = frontendCompleteUser else { return }
//
//        let newProfilePicWrapper = ProfilePicWrapper(image: newProfilePic, withCompresssion: true)
//        let compressedNewProfilePic = newProfilePicWrapper.image
//        let updatedCompleteUser = try await UserAPI.patchProfilePic(image: compressedNewProfilePic,
//                                                                    id: frontendCompleteUser.id,
//                                                                    username: frontendCompleteUser.username)
//        self.authedUser.profilePicWrapper = newProfilePicWrapper
//        self.authedUser.picture = updatedCompleteUser.picture
//
//        Task {
//            await self.saveUserToFilesystem()
//            await UsersService.singleton.updateCachedUser(updatedUser: self.getUserAsFrontendReadOnlyUser())
//        }
//    }
    
//
//    //MARK: - Logout and delete user
//
    private func logOutFromDevice()  {
        guard isLoggedIntoAnAccount else { return } //prevents infinite loop on authedUser didSet
//        if getGlobalDeviceToken() != "" {
//            Task {
//                try await DeviceAPI.disableCurrentDeviceNotificationsForUser(user: authedUser.id)
//            }
//        }
        //reset any caches
//        setGlobalAuthToken(token: "")
        eraseUserFromFilesystem()
        frontendCompleteUser = nil
        isLoggedIntoApp = false
    }

    func kickUserToHomeScreenAndLogOut() {
        //they might already be logged out, so don't try and logout again. this will cause an infinite loop for checkingAuthedUser :(
        if isLoggedIntoAnAccount {
            logOutFromDevice()
        }
        DispatchQueue.main.async {
            transitionToAuth()
        }
    }

    func deleteMyAccount() async throws {
        do {
            try await UserAPI.deleteUser(email: authedUser.email)
            logOutFromDevice()
        } catch {
            print(error)
            throw(error)
        }
    }
//
//    //MARK: - Firebase
//
    func setupFirebaseAnalyticsProperties() {
        //if we decide to use firebase ad support framework in the future, gender, age, and interest will automatically be set
//        guard let age = frontendCompleteUser?.age else { return }
//        var ageBracket = ""
//        if age < 25 {
//            ageBracket = "18-24"
//        } else if age < 35 {
//            ageBracket = "25-35"
//        } else if age < 45 {
//            ageBracket = "35-45"
//        } else if age < 55 {
//            ageBracket = "45-55"
//        } else if age < 65 {
//            ageBracket = "55-65"
//        } else {
//            ageBracket = "65+"
//        }
//        Analytics.setUserProperty(authedUser.sex, forName: "sex")
//        Analytics.setUserProperty(ageBracket, forName: "age")
    }
//
//    //MARK: - Filesystem

    func saveUserToFilesystem() async {
        do {
            guard let frontendCompleteUser = frontendCompleteUser else { return }
            let encoder = JSONEncoder()
            let data: Data = try encoder.encode(frontendCompleteUser)
            let jsonString = String(data: data, encoding: .utf8)!
            try jsonString.write(to: UserService.LOCAL_FILE_LOCATION, atomically: true, encoding: .utf8)
        } catch {
            print("COULD NOT SAVE: \(error)")
        }
    }

    func loadUserFromFilesystem() {
        do {
            let data = try Data(contentsOf: UserService.LOCAL_FILE_LOCATION)
            frontendCompleteUser = try JSONDecoder().decode(FrontendCompleteUser.self, from: data)
            guard let frontendCompleteUser = frontendCompleteUser else { return }
//            setGlobalAuthToken(token: frontendCompleteUser.token) //this shouldn't be necessary, but to be safe
            Task { await waitAndRegisterDeviceToken(id: frontendCompleteUser.id) }
        } catch {
            print("COULD NOT LOAD: \(error)")
        }
    }

    func eraseUserFromFilesystem() {
        do {
//            setGlobalAuthToken(token: "")
            try FileManager.default.removeItem(at: UserService.LOCAL_FILE_LOCATION)
        } catch {
            print("\(error)")
        }
    }

    // MARK: - Device Notifications

    func waitAndRegisterDeviceToken(id:Int) async {
        do {
            while true {
//                if getGlobalDeviceToken() != "" && getGlobalAuthToken() != "" {
//                    try await DeviceAPI.registerCurrentDeviceWithUser(user: id)
//                }
                try await Task.sleep(nanoseconds: NSEC_PER_SEC * UInt64(SLEEP_INTERVAL))
            }
        } catch {
            print("ERROR WAITING TO REGISTER DEVICE TOKEN")
        }
    }
}
