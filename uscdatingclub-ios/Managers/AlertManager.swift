//
//  AlertManager.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2022/12/29.
//

import Foundation
import SwiftMessages
import MapKit

//MARK: Errors

class PermissionsError: NSError {
    
}

class AlertManager {
    
    static func displayError(_ errorDescription: String, _ recoveryDescription: String) {
        print(errorDescription)
        createAndShowError(title: errorDescription, body: recoveryDescription, emoji: "😔")
    }
    
    static func displayError(_ error: Error) {
        if let apiError = error as? APIError {
            print(apiError)
            createAndShowError(title: apiError.errorDescription!, body: apiError.recoverySuggestion!, emoji: "😔")
        } else if let mkError = error as? MKError {
            if mkError.errorCode == 4 {
                createAndShowError(title: "something went wrong", body: "try again later", emoji: "😔")
            } else {
                print(error.localizedDescription)
            }
        } else {
            print(error.localizedDescription)
            createAndShowError(title: "something went wrong", body: "try again later", emoji: "😔")
        }
    }
    
    private static func createAndShowError(title: String, body: String, emoji: String) {
        DispatchQueue.main.async { //ensures that these ui actions occur on the main thread
//            let errorMessageView: CustomCardView = try! SwiftMessages.viewFromNib()
            let errorMessageView = MessageView.viewFromNib(layout: .cardView)
            errorMessageView.configureTheme(Theme.info)
//            errorMessageView.applyMediumShadow()
            errorMessageView.configureContent(title: title,
                                         body: body,
                                         iconText: emoji)
            errorMessageView.button?.isHidden = true
//            errorMessageView.dismissButton.tintColor = .white
//            errorMessageView.dismissAction = {
//                SwiftMessages.hide()
//            }

            var messageConfig = SwiftMessages.Config()
            messageConfig.presentationContext = .window(windowLevel: .normal)
            messageConfig.presentationStyle = .top
            messageConfig.duration = .seconds(seconds: 3)

            SwiftMessages.hideAll()
            SwiftMessages.show(config: messageConfig, view: errorMessageView)
        }
    }
    
    static func showInfoCentered(_ title: String, _ message: String,  on controller: UIViewController) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (UIAlertAction) in
                
            }
            alertController.addAction(okAction)
            controller.present(alertController, animated: true)
        }
    }
    
    //TODO: instead of using DispatchQueue.main.async, we should @MainActor on the function. but adding that tag is not requiring the function be called on main actor...
    
    static func showAlert(title: String,
                          subtitle: String,
                          primaryActionTitle: String,
                          primaryActionHandler: @escaping () -> Void,
                          secondaryActionTitle: String? = nil,
                          secondaryActionHandler: (() -> Void)? = nil,
                          on controller: UIViewController) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
            let primaryAction = UIAlertAction(title: NSLocalizedString(primaryActionTitle, comment: ""), style: .default) { (UIAlertAction) in
                primaryActionHandler()
            }
            alertController.addAction(primaryAction)
            if let secondaryActionTitle, let secondaryActionHandler {
                let secondaryAction = UIAlertAction(title: NSLocalizedString(secondaryActionTitle, comment: ""), style: .cancel) { (UIAlertAction) in
                    secondaryActionHandler()
                }
                alertController.addAction(secondaryAction)
            }
            controller.present(alertController, animated: true)
        }
    }
    
    //MARK: - Specific Use Cases
    
    @MainActor
    static func showDeleteAccountAlert(on controller: UIViewController) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "are you sure you want to delete your account?", message: "this cannot be undone", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: NSLocalizedString("yes, delete my account", comment: ""), style: .default) { (UIAlertAction) in
                Task {
                    try await UserService.singleton.deleteMyAccount()
                    DispatchQueue.main.async {
                        transitionToAuth()
                    }
                }
            }
            let noAction = UIAlertAction(title: NSLocalizedString("nevermind", comment: ""), style: .cancel) { (UIAlertAction) in
                
            }
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            controller.present(alertController, animated: true)
        }
    }
    
    enum OpenSettingsType {
        case location, backgroundRefresh, notifications
    }
    
    @MainActor
    static func showSettingsAlertController(title: String,
                                            message: String,
                                            settingsType: OpenSettingsType,
                                            on controller: UIViewController) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
            let settingsAction = UIAlertAction(title: NSLocalizedString("open settings", comment: ""), style: .default) { (UIAlertAction) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            }
            switch settingsType {
            case .backgroundRefresh:
                alertController.addImage(image: UIImage(named: "permissions-bgrefresh")!.withRenderingMode(.alwaysOriginal))
            case .location:
                alertController.addImage(image: UIImage(named: "permissions-location")!.withRenderingMode(.alwaysOriginal))
            case .notifications:
                break
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            controller.present(alertController, animated: true)
        }
    }
    
    @MainActor
    static func showLocationDemoController(on controller: UIViewController) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "usc dating club requires \"always, precise\" location to work properly", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("sounds good", comment: ""), style: .default) { (UIAlertAction) in
                do {
                    try LocationManager.shared.requestPermissionServices()
                } catch {
                    
                }
            }
            alertController.addImage(image: UIImage(named: "permissions-location")!.withRenderingMode(.alwaysOriginal))
            
            alertController.addAction(okAction)
            controller.present(alertController, animated: true)
        }
    }
    
}
