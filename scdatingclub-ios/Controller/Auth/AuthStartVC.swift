//
//  AuthStartViewController.swift
//  mist-ios
//
//  Created by Adam Monterey on 7/7/22.
//

import UIKit

class AuthStartVC: UIViewController, UITextViewDelegate {
    
    //MARK: - Properties
    
    //UI
    @IBOutlet weak var agreementTextView: UITextView!
//    @IBOutlet var continueButton: SimpleButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var headerLabel: UILabel!

    //MARK: - Initialization
    
    class func create() -> AuthStartVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Auth, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.AuthStart) as! AuthStartVC
        return vc
    }
    
    //MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        setupAgreementTextView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        titleLabel.font = AppFont.bold.size(30)
        subtitleLabel.font = AppFont.medium.size(18)
        headerLabel.font = AppFont2.regular.size(12)
        headerLabel.text = "sc dating club is an iOS app from Leavey Labs. It is not affiliated with any external organizations or institutions."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AuthContext.reset()
    }
    
    //MARK: - Setup
    
    func setupAgreementTextView() {
        if let agreementText = agreementTextView.text {
            let attributedText = NSMutableAttributedString(string: agreementText)
            
            if let termsOfUseRange = agreementText.range(of: "terms of use") {
                attributedText.setAttributes([.link: Constants.termsLink], range: NSRange(termsOfUseRange, in: agreementText))
            }
            
            if let privacyPolicyRange = agreementText.range(of: "privacy policy") {
                attributedText.setAttributes([.link: Constants.privacyPageLink], range: NSRange(privacyPolicyRange, in: agreementText))
            }
            
            agreementTextView.attributedText = attributedText
            agreementTextView.font = AppFont2.regular.size(12)
            agreementTextView.textColor = UIColor.white.withAlphaComponent(0.7)
            agreementTextView.isEditable = false
            agreementTextView.delegate = self
            agreementTextView.isUserInteractionEnabled = true
            agreementTextView.textAlignment = NSTextAlignment.center
            agreementTextView.linkTextAttributes = [
                .foregroundColor: UIColor.white,
            ]
        }
    }
    
    //MARK: - Interaction
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        agreementTextView.selectedTextRange = nil
    }

}
