
//
//  EnterEmailViewController.swift
//  mist-ios
//
//  Created by Kevin Sun on 3/29/22.
//

import UIKit
import PhoneNumberKit

class EnterNumberViewController: KUIViewController, UITextFieldDelegate {

    @IBOutlet weak var enterNumberTextField: PhoneNumberTextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var enterNumberTextFieldWrapperView: UIView!
    
    var isValidInput: Bool! {
        didSet {
            continueButton.isEnabled = isValidInput
        }
    }
    var isSubmitting: Bool = false {
        didSet {
            continueButton.setTitle(isSubmitting ? "" : "continue", for: .normal)
            continueButton.loadingIndicator(isSubmitting)
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        isValidInput = false
        validateInput()
        shouldNotAnimateKUIAccessoryInputView = true
        setupPopGesture()
        setupEnterNumberTextField()
        setupContinueButton() //uncomment this button for standard button behavior, where !isEnabled greys it out
        setupBackButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        enableInteractivePopGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enterNumberTextField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disableInteractivePopGesture()
    }
    
    //MARK: - Setup
    
    func setupEnterNumberTextField() {
        enterNumberTextFieldWrapperView.layer.cornerRadius = 5
        enterNumberTextFieldWrapperView.layer.cornerCurve = .continuous
        enterNumberTextField.delegate = self
        enterNumberTextField.countryCodePlaceholderColor = .red
        enterNumberTextField.withFlag = true
        enterNumberTextField.withPrefix = true
//        enterNumberTextField.withExamplePlaceholder = true
    }
    
    func setupContinueButton() {
        continueButton.roundCornersViaCornerRadius(radius: 10)
        continueButton.clipsToBounds = true
        continueButton.isEnabled = false
        continueButton.setBackgroundImage(UIImage.imageFromColor(color: .primaryColor), for: .normal)
        continueButton.setBackgroundImage(UIImage.imageFromColor(color: .primaryColor.withAlphaComponent(0.2)), for: .disabled)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.setTitleColor(.primaryColor, for: .disabled)
        continueButton.setTitle("continue", for: .normal)
    }
    
    func setupBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(goBack))
    }
    
    //MARK: - User Interaction
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressedContinueButton(_ sender: Any) {
        tryToContinue()
    }
    
    @IBAction func gotAnAccessCodeButton(_ sender: Any) {
//        let vc = ConfirmCodeViewController.create(confirmMethod: .accessCode)
//        present(vc, animated: true)
    }
    
    //MARK: - TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let _ = range == NSRange(location: 0, length: 0) && string.count > 1
//        if didAutofillTextfield {
//            DispatchQueue.main.async {
//                self.tryToContinue()
//            }
//        } //disabling this for now while we have access codes, so people can enter it if need be
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
//                try await PhoneNumberAPI.registerNewPhoneNumber(phoneNumber: number)
                AuthContext.phoneNumber = number
                let vc = ConfirmCodeViewController.create(confirmMethod: .text)
                self.navigationController?.pushViewController(vc, animated: true, completion: { [weak self] in
                    self?.isSubmitting = false
                })
            } catch {
                handleFailure(error)
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
        isValidInput = enterNumberTextField.text?.asE164PhoneNumber != nil
    }
    
}

// UIGestureRecognizerDelegate (already inherited in an extension)

extension EnterNumberViewController {
    
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
