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

enum AlertManager {
    
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
            errorMessageView.configureTheme(.error)
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
    
    static func showSettingsAlertController(title: String, message: String, on controller: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: NSLocalizedString("settings", comment: ""), style: .default) { (UIAlertAction) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        controller.present(alertController, animated: true)
    }
}