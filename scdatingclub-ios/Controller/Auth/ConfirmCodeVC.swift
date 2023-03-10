//
//  ConfirmCodeViewController.swift
//  mist-ios
//
//  Created by Adam Monterey on 8/25/22.
//

import UIKit
import Mixpanel
import FirebaseAnalytics

class ConfirmCodeVC: KUIViewController, UITextFieldDelegate {
    
    enum ConfirmMethod: CaseIterable {
        case text, email// resetPhoneNumberEmail, resetPhoneNumberText, accessCode, appleLogin
    }
    
    enum ResendState {
        case notsent, sending, sent
    }
    
    var recipient: String!
    var confirmMethod: ConfirmMethod!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var sentToLabel: UILabel!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var continueButton: SimpleButton!
    @IBOutlet var openEmailAppButton: SimpleButton!

    var isValidInput: Bool! {
        didSet {
            continueButton.internalButton.isEnabled = isValidInput
            continueButton.alpha = isValidInput ? 1 : 0.5
        }
    }
    var isSubmitting: Bool = false {
        didSet {
            continueButton.internalButton.setTitle(isSubmitting ? "" : "continue", for: .normal)
            continueButton.internalButton.loadingIndicator(isSubmitting)
            resendButton.isEnabled = !isSubmitting && resendState == .notsent
        }
    }
    
    let resendAttributes = [NSAttributedString.Key.font: UIFont(name: Constants.Font.Medium, size: 12)!]
    var resendState: ResendState = .notsent {
        didSet {
            switch resendState {
            case .notsent:
                resendButton.loadingIndicator(false)
                resendButton.isEnabled = true
                resendButton.setTitle("resend", for: .normal)
            case .sending:
                resendButton.isEnabled = false
                resendButton.loadingIndicator(true)
                resendButton.setTitle("", for: .normal)
            case .sent:
                resendButton.isUserInteractionEnabled = false
                resendButton.loadingIndicator(false)
                resendButton.setTitle("resent", for: .normal)
            }
        }
    }
    
    //MARK: - Initialization
    
    class func create(confirmMethod: ConfirmMethod) -> ConfirmCodeVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Auth, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.ConfirmCode) as! ConfirmCodeVC
        switch confirmMethod {
        case .text:
            vc.recipient = AuthContext.phoneNumber.asNationalPhoneNumber ?? AuthContext.phoneNumber
        case .email:
            vc.recipient = AuthContext.email
        }
        vc.confirmMethod = confirmMethod
        return vc
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        validateInput()
        shouldNotAnimateKUIAccessoryInputView = true
        setupConfirmEmailTextField()
        setupButtons()
        setupLabel()
        confirmTextField.becomeFirstResponder()
        validateInput()
    }
    
    //MARK: - Setup
    
    func setupConfirmEmailTextField() {
        confirmTextField.delegate = self
        confirmTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        let xconstraints: CGFloat = 50
        let textFieldWidth = view.frame.size.width - xconstraints
        let numberWidth: CGFloat = 14
        let spacing = (textFieldWidth / 7) - numberWidth
        confirmTextField.setLeftPaddingPoints(spacing)
        confirmTextField.defaultTextAttributes.updateValue(spacing, forKey: NSAttributedString.Key.kern)
        confirmTextField.font = AppFont.medium.size(20)
    }
    
    func setupButtons() {
        continueButton.internalButton.isEnabled = false
        continueButton.internalButton.setBackgroundImage(UIImage.imageFromColor(color: .customWhite), for: .normal)
        continueButton.internalButton.setBackgroundImage(UIImage.imageFromColor(color: .customWhite.withAlphaComponent(0.2)), for: .disabled)
        continueButton.internalButton.setTitleColor(.customBlack, for: .normal)
        continueButton.internalButton.setTitleColor(.customBlack, for: .disabled)
        continueButton.configure(title: "continue", systemImage: "")
        continueButton.internalButton.addTarget(self, action: #selector(tryToContinue), for: .touchUpInside)
        
        openEmailAppButton.isHidden = confirmMethod != .email
        openEmailAppButton.configure(title: "open email app", systemImage: "envelope")
        openEmailAppButton.backgroundColor = .clear
        openEmailAppButton.internalButton.tintColor = .customWhite
        openEmailAppButton.internalButton.setTitleColor(.customWhite, for: .normal)
        
        openEmailAppButton.internalButton.addTarget(self, action: #selector(openEmailButtonTapped), for: .touchUpInside)
    }
    
    func setupLabel() {
        sentToLabel.text! += recipient
        titleLabel.font = AppFont.bold.size(30)
        sentToLabel.font = AppFont2.medium.size(17)
        resendButton.titleLabel?.font = AppFont2.medium.size(12)
        resendButton.setTitleColor(.customWhite.withAlphaComponent(0.5), for: .normal)
    }
    
    //MARK: - User Interaction
    
    @objc func openEmailButtonTapped() {
        Analytics.logEvent(Constants.MP.OpenEmailButtonTapped.EventName, parameters: nil)
        Mixpanel.mainInstance().track(event: Constants.MP.OpenEmailButtonTapped.EventName)
        presentOpenMailAppAlert()
    }
    
    @IBAction func backButtonDidPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressedResendButton(_ sender: UIButton) {
        resendState = .sending
        Task {
            do {
                try await resend()
            } catch {
                handleError(error)
            }
            resendState = .sent
        }
    }
    
    //MARK: - TextField Delegate
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        validateInput()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isValidInput {
            tryToContinue()
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let didAutofillTextfield = range == NSRange(location: 0, length: 0) && string.count > 1
        if didAutofillTextfield {
            DispatchQueue.main.async {
                self.tryToContinue()
            }
        } else {
            detectAutoFillFromTexts(textField: textField, range: range, string: string)
        }
        return textField.shouldChangeCharactersGivenMaxLengthOf(6, range, string)
    }
    
    //MARK: DetectAutoFill

    private var fieldPossibleAutofillReplacementAt: Date?
    private var fieldPossibleAutofillReplacementRange: NSRange?
    func detectAutoFillFromTexts(textField: UITextField, range: NSRange, string: String) {
        // To detect AutoFill, look for two quick replacements. The first replaces a range with a single space
        // (or blank string starting with iOS 13.4).
        // The next replaces the same range with the autofilled content.
        if string == " " || string == "" {
            self.fieldPossibleAutofillReplacementRange = range
            self.fieldPossibleAutofillReplacementAt = Date()
        } else {
            if fieldPossibleAutofillReplacementRange == range, let replacedAt = self.fieldPossibleAutofillReplacementAt, Date().timeIntervalSince(replacedAt) < 0.1 {
                DispatchQueue.main.async { [self] in
                    tryToContinue()
                }
            }
            self.fieldPossibleAutofillReplacementRange = nil
            self.fieldPossibleAutofillReplacementAt = nil
        }
    }
    
    //MARK: - Helpers
    
    @objc func tryToContinue() {
        guard let code = confirmTextField.text else { return }
        isSubmitting = true
        Task {
            do {
                try await validate(validationCode: code)
                DispatchQueue.main.async {
                    self.continueToNextScreen()
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleError(error)
                }
            }
        }
    }
    
    func validateInput() {
        isValidInput = confirmTextField.text?.count == 6
    }
    
    @MainActor
    func handleError(_ error: Error) {
        isSubmitting = false
        confirmTextField.text = ""
        AlertManager.displayError(error)
    }
    
    //MARK: - ConfirmMethod Functions
    
    func resend() async throws {
        switch confirmMethod {
        case .text:
            try await PhoneNumberAPI.requestCode(phoneNumber: AuthContext.phoneNumber, uuid: AuthContext.uuid)
        case .email:
            try await EmailAPI.requestCode(email: AuthContext.email, uuid: AuthContext.uuid)
        case .none:
            break
        }
    }
    
    func validate(validationCode: String) async throws {
        switch confirmMethod {
        case .text:
            if let user = try await PhoneNumberAPI.verifyCode(phoneNumber: AuthContext.phoneNumber, code: validationCode, uuid: AuthContext.uuid) {
                try await UserService.singleton.logInWith(completeUser: user)
            }
        case .email:
            try await EmailAPI.verifyCode(email: AuthContext.email, code: validationCode, uuid: AuthContext.uuid)
        case .none:
            break
        }
    }
    
    @MainActor
    func continueToNextScreen() {
        switch confirmMethod {
        case .text:
            if UserService.singleton.isLoggedIntoAnAccount {
                Mixpanel.mainInstance().track(
                    event: Constants.MP.AuthProcess.EventName,
                    properties: [Constants.MP.AuthProcess.Kind:Constants.MP.AuthProcess.Login])
                Analytics.logEvent(Constants.MP.AuthProcess.EventName, parameters: [Constants.MP.AuthProcess.Kind:Constants.MP.AuthProcess.Login])
                transitionToStoryboard(storyboardID: Constants.SBID.SB.Main, duration: 0.5, completion: { completed in
                })
            } else {
                navigationController?.pushViewController(EnterEmailVC.create(), animated: true, completion: { [weak self] in
                    self?.isSubmitting = false
                })
            }
        case .email:
            self.navigationController?.pushViewController(CreateProfileVC.create(), animated: true, completion: { [weak self] in
                self?.isSubmitting = false
            })
        case .none:
            break
        }
    }
}
