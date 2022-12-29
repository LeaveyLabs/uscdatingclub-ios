//
//  AuthStartViewController.swift
//  mist-ios
//
//  Created by Adam Monterey on 7/7/22.
//

import UIKit
import Foundation

class AuthStartViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var mistWideLogoView: UIImageView!
    @IBOutlet weak var agreementTextView: UITextView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func loadView() {
        super.loadView()
        loadMistLogo()
        setupAgreementTextView()
        setupButtons()
    }
    
    func loadMistLogo() {
//        view.addSubview(mistWideLogoView)
//        mistWideLogoView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            mistWideLogoView.widthAnchor.constraint(equalToConstant: 300),
//            mistWideLogoView.heightAnchor.constraint(equalToConstant: 130),
//            mistWideLogoView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
//            mistWideLogoView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
//        ])
    }
    
    func setupButtons() {
        registerButton.roundCornersViaCornerRadius(radius: 10)
        registerButton.clipsToBounds = true
        registerButton.setBackgroundImage(UIImage.imageFromColor(color: .primaryColor), for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        
        loginButton.roundCornersViaCornerRadius(radius: 10)
        loginButton.clipsToBounds = true
        loginButton.setBackgroundImage(UIImage.imageFromColor(color: .primaryColor.withAlphaComponent(0.2)), for: .normal)
        loginButton.setTitleColor(.primaryColor, for: .normal)
    }
    
    func setupAgreementTextView() {
        if let agreementText = agreementTextView.text {
            let attributedText = NSMutableAttributedString(string: agreementText)
            
            let termsOfUseUrl = URL(string: "https://www.getmist.app/terms-of-use")!
            if let termsOfUseRange = agreementText.range(of: "terms of use") {
                attributedText.setAttributes([.link: termsOfUseUrl], range: NSRange(termsOfUseRange, in: agreementText))
            }
            
            let privacyPolicyUrl = URL(string: "https://www.getmist.app/privacy-policy")!
            if let privacyPolicyRange = agreementText.range(of: "privacy policy") {
                attributedText.setAttributes([.link: privacyPolicyUrl], range: NSRange(privacyPolicyRange, in: agreementText))
            }
            
            agreementTextView.attributedText = attributedText
            agreementTextView.font = UIFont(name: "Avenir", size: 12)
            agreementTextView.textColor = UIColor.lightGray
            agreementTextView.isEditable = false
            agreementTextView.delegate = self
            agreementTextView.isUserInteractionEnabled = true
            agreementTextView.textAlignment = NSTextAlignment.center
            agreementTextView.linkTextAttributes = [
                .foregroundColor: UIColor.darkGray,
            ]
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        agreementTextView.selectedTextRange = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mistWideLogoView.alpha = 0
        loginButton.alpha = 0
        registerButton.alpha = 0
        agreementTextView.alpha = 0
        UIView.animate(withDuration: 1.5, delay: 0.3, options: .curveLinear) { [self] in
            mistWideLogoView.alpha = 1
            loginButton.alpha = 1
            registerButton.alpha = 1
            agreementTextView.alpha = 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AuthContext.reset()
    }

}