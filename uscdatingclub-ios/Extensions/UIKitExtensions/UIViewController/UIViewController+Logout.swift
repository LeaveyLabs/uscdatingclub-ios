//
//  UIViewController+Logout.swift
//  mist-ios
//
//  Created by Adam Monterey on 8/20/22.
//

import UIKit

extension UIViewController {
    
    func logoutAndGoToAuth() {
        //optionally: present an alert before they log out
        UserService.singleton.logOutFromDevice()
        transitionToStoryboard(storyboardID: Constants.SBID.SB.Auth,
                               viewControllerID: Constants.SBID.VC.AuthNav,
                               duration: 0) { _ in }
    }
    
}
