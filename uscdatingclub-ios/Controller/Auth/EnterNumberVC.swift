
//
//  EnterEmailViewController.swift
//  mist-ios
//
//  Created by Kevin Sun on 3/29/22.
//

import UIKit
import PhoneNumberKit

class EnterNumberVC: KUIViewController, UITextFieldDelegate {

    //MARK: - Properties
    
    @IBOutlet weak var enterNumberTextField: PhoneNumberTextField!
    @IBOutlet weak var continueButton: SimpleButton!
    @IBOutlet weak var enterNumberTextFieldWrapperView: UIView!
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
    
    class func create() -> EnterNumberVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Auth, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.EnterNumber) as! EnterNumberVC
        return vc
    }
    
    //MARK: - Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        validateInput()
        shouldNotAnimateKUIAccessoryInputView = true
        setupPopGesture()
        setupEnterNumberTextField()
        setupContinueButton()
        setupBackButton()
        
        titleLabel.font = AppFont.bold.size(30)
        subtitleLabel.font = AppFont2.medium.size(17)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enterNumberTextField.becomeFirstResponder()
    }
    
    //MARK: - Setup
    
    func setupEnterNumberTextField() {
//        enterNumberTextFieldWrapperView.layer.cornerRadius = 5
//        enterNumberTextFieldWrapperView.layer.cornerCurve = .continuous
        enterNumberTextField.delegate = self
        enterNumberTextField.countryCodePlaceholderColor = .red
        enterNumberTextField.withFlag = true
        enterNumberTextField.withPrefix = true
        enterNumberTextField.font = AppFont.medium.size(17)
//        enterNumberTextField.withExamplePlaceholder = true
    }
    
    func setupContinueButton() {
        continueButton.internalButton.isEnabled = false
        continueButton.internalButton.setBackgroundImage(UIImage.imageFromColor(color: .customWhite), for: .normal)
        continueButton.internalButton.setBackgroundImage(UIImage.imageFromColor(color: .customWhite.withAlphaComponent(0.5)), for: .disabled)
        continueButton.internalButton.setTitleColor(.black, for: .normal)
        continueButton.internalButton.setTitleColor(.black, for: .disabled)
        continueButton.configure(title: "continue", systemImage: "")
        continueButton.internalButton.addTarget(self, action: #selector(didPressedContinueButton), for: .touchUpInside)
    }
    
    func setupBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem?.tintColor = .customWhite
    }
    
    //MARK: - User Interaction
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didPressedContinueButton(_ sender: Any) {
        tryToContinue()
    }
    
    @IBAction func gotAnAccessCodeButton(_ sender: Any) {
//        let vc = ConfirmCodeViewController.create(confirmMethod: .accessCode)
//        present(vc, animated: true)
    }
    
    //MARK: - TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let didAutofillTextfield = range == NSRange(location: 0, length: 0) && string.count > 1
        if didAutofillTextfield {
            DispatchQueue.main.async {
                self.tryToContinue()
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isValidInput {
            tryToContinue()
        }
        return false
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        let maxLength = 17 //the max length for US numbers
        if sender.text!.count > maxLength {
            sender.deleteBackward()
        }
        validateInput()
    }
    
    //MARK: - Helpers
    
    func tryToContinue() {
        guard let number = enterNumberTextField.text?.asE164PhoneNumber else { return }
        isSubmitting = true
        Task {
            do {
                try await PhoneNumberAPI.requestCode(phoneNumber: number, uuid: AuthContext.uuid)
                AuthContext.phoneNumber = number
                DispatchQueue.main.async {
                    let vc = ConfirmCodeVC.create(confirmMethod: .text)
                    self.navigationController?.pushViewController(vc, animated: true, completion: { [weak self] in
                        self?.isSubmitting = false
                    })
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.handleFailure(error)
                }
            }
        }
    }
    
    func handleFailure(_ error: Error) {
        isSubmitting = false
        enterNumberTextField.text = ""
        validateInput()
        AlertManager.displayError(error)
    }
    
    func validateInput() {
        isValidInput = enterNumberTextField.text?.asE164PhoneNumber != nil || enterNumberTextField.text!.filter("1234567890".contains) == AuthContext.APPLE_PHONE_NUMBER
    }
    
}

// UIGestureRecognizerDelegate (already inherited in an extension)

extension EnterNumberVC {
    
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
