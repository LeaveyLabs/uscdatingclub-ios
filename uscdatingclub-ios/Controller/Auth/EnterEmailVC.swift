//
//  EnterEmailViewController.swift
//  mist-ios
//
//  Created by Kevin Sun on 3/29/22.
//

import UIKit

class EnterEmailVC: KUIViewController, UITextFieldDelegate {

    //MARK: - Properties
    
    @IBOutlet weak var enterEmailTextField: UITextField!
    @IBOutlet weak var continueButton: SimpleButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

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
        }
    }
    
    //MARK: - Initialization
    
    class func create() -> EnterEmailVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Auth, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.EnterEmail) as! EnterEmailVC
        return vc
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isValidInput = false
        validateInput()
        shouldNotAnimateKUIAccessoryInputView = true
        setupPopGesture()
        setupEnterEmailTextField()
        setupContinueButton() //uncomment this button for standard button behavior, where !isEnabled greys it out
        setupBackButton()
        titleLabel.font = AppFont.bold.size(30)
        subtitleLabel.font = AppFont2.medium.size(17)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enterEmailTextField.becomeFirstResponder()
    }
    
    //MARK: - Setup
    
    func setupEnterEmailTextField() {
        enterEmailTextField.delegate = self
        enterEmailTextField.setLeftAndRightPadding(10)
        enterEmailTextField.font = AppFont.medium.size(17)
    }
    
    func setupContinueButton() {
        continueButton.internalButton.isEnabled = false
        continueButton.internalButton.setBackgroundImage(UIImage.imageFromColor(color: .white), for: .normal)
        continueButton.internalButton.setBackgroundImage(UIImage.imageFromColor(color: .white.withAlphaComponent(0.2)), for: .disabled)
        continueButton.internalButton.setTitleColor(.black, for: .normal)
        continueButton.internalButton.setTitleColor(.black, for: .disabled)
        continueButton.configure(title: "continue", systemImage: "")
        continueButton.internalButton.addTarget(self, action: #selector(tryToContinue), for: .touchUpInside)
    }
    
    func setupBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(goBack))
    }
    
    //MARK: - User Interaction
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //people's thumbs get in the way
//        if isValidInput {
//            tryToContinue()
//        }
        return false
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        validateInput()
        let maxLength = 30
        if sender.text!.count > maxLength {
            sender.deleteBackward()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        detectAutoFill(textField: textField, range: range, string: string)
        return true
    }
    
    //MARK: - Helpers
    
    @objc func tryToContinue() {
        if let email = enterEmailTextField.text?.lowercased() {
            isSubmitting = true
            Task {
                do {
                    try await EmailAPI.requestCode(email: email, uuid: AuthContext.uuid)
                    AuthContext.email = email
                    DispatchQueue.main.async {
                        let vc = ConfirmCodeVC.create(confirmMethod: .email)
                        self.navigationController?.pushViewController(vc, animated: true, completion: { [weak self] in
                            self?.isSubmitting = false
                        })
                    }
                } catch {
                    DispatchQueue.main.async {
                        if error.localizedDescription.contains("list") {
                            self.handleNonUSCSignup(email)
                        } else {
                            self.handleFailure(error)
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    func handleFailure(_ error: Error) {
        isSubmitting = false
        enterEmailTextField.text = ""
        validateInput()
        AlertManager.displayError(error)
    }
    
    @MainActor
    func handleNonUSCSignup(_ email: String) {
        Task {
            do {
                UserDefaults.standard.setValue(true, forKey: Constants.UserDefaultsKeys.isOnWaitList)
                try await EmailAPI.placeOnWaitingList(email: email)
                DispatchQueue.main.async {
                    let vc = WaitListVC.create()
                    self.navigationController?.pushViewController(vc, animated: true, completion: { [weak self] in
                        self?.isSubmitting = false
                    })
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleFailure(error)
                }
            }
        }
    }
    
    func validateInput() {
        isValidInput = (enterEmailTextField.text?.contains("@"))!
    }
    
    //MARK: DetectAutoFill

    private var fieldPossibleAutofillReplacementAt: Date?
    private var fieldPossibleAutofillReplacementRange: NSRange?
    func detectAutoFill(textField: UITextField, range: NSRange, string: String) {
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
    
}

// UIGestureRecognizerDelegate (already inherited in an extension)

extension EnterEmailVC {
    
    // Note: Must be called in viewDidLoad
    //(1 of 2) Enable swipe left to go back with a bar button item
    func setupPopGesture() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
    }
        
    //(2 of 2) Enable swipe left to go back with a bar button item
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
