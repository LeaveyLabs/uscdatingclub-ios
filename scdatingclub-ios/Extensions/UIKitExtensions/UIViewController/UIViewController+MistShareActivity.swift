//
//  UIViewController+MistShareActivity.swift
//  mist-ios
//
//  Created by Adam Monterey on 7/7/22.
//

import UIKit

protocol ShareActivityDelegate {
    func presentShareActivityVC()
}

extension UIViewController {
    
    func presentShareAppActivity() {
        let objectsToShare: [Any] = [Constants.appStoreLink]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        let currentTintColor = self.window?.tintColor
        activityVC.window?.tintColor = .systemBlue
        activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems:[Any]?, error: Error?) in
            activityVC.window?.tintColor = currentTintColor
        }

        present(activityVC, animated: true)
        
    }
}
