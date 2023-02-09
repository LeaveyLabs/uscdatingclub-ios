//
//  UIViewController+OpenURL.swift
//  mist-ios
//
//  Created by Adam Monterey on 7/7/22.
//

import Foundation
import SafariServices

extension UIViewController: SFSafariViewControllerDelegate {
    
    func openURL(_ url: URL) {
        let webViewController = SFSafariViewController(url: url)
        webViewController.delegate = self
        webViewController.preferredControlTintColor = .systemBlue
        present(webViewController, animated: true)
    }
    
    func openMailtoURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    public func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        UIApplication.shared.statusBarStyle = .darkContent
    }
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        UIApplication.shared.statusBarStyle = .default
    }
    
}
