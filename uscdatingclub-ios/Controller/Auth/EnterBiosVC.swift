//
//  EnterBiosViewController.swift
//  mist-ios
//
//  Created by Adam Monterey on 7/8/22.
//

import UIKit

class EnterBiosVC: KUIViewController, UITextFieldDelegate {
    
    //MARK: - Properties
    
//    private lazy var datePicker: UIDatePicker = {
//        let datePicker = UIDatePicker(frame: .zero)
//        datePicker.datePickerMode = .date
//        datePicker.locale = Locale(identifier: "en_US")
//        if #available(iOS 14, *) {
//            datePicker.preferredDatePickerStyle = .wheels
//        }
//
//        var dateComponents = DateComponents()
//        dateComponents.year = 2000
//        dateComponents.month = 1
//        dateComponents.day = 1
//        let startingDate = Calendar.current.date(from: dateComponents)!
//        let minimumAge = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
//
//        datePicker.date = startingDate
//        datePicker.maximumDate = minimumAge
//        return datePicker
//    }()
    
    enum Sex: String, CaseIterable {
        case blank, female, male, both
        
        var displayName: String {
            switch self {
            case .blank:
                return ""
            case .female:
                return "female"
            case .male:
                return "male"
            case .both:
                return "both"
//            case .other:
//                return "other"
//            case .ratherNotSay:
//                return "rather not say"
            }
        }
        
        var databaseName: String? {
            switch self {
            case .blank:
                return "" //should never be accessed.. throw?
            case .female:
                return "f"
            case .male:
                return "m"
            case .both:
                return "b"
            }
        }
    }
    
//    var dobData = ""
    var sexOptions = [Sex]()
    private lazy var sexPicker: UIPickerView = {
        let sexPicker = UIPickerView(frame: .zero)
        sexPicker.delegate = self
        sexPicker.dataSource = self
        return sexPicker
    }()

    @IBOutlet weak var sexIdentityTextField: UITextField!
    @IBOutlet weak var sexPreferenceTextField: UITextField!
    
//    @IBOutlet weak var dobTextField: UITextField!
    
    @IBOutlet weak var continueButton: SimpleButton!
    
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
    
    //MARK: - Initializaiton
    
    class func create() -> EnterBiosVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Auth, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.EnterBios) as! EnterBiosVC
        return vc
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        validateInput()
        shouldNotAnimateKUIAccessoryInputView = true
        setupTextFields()
        setupContinueButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        disableInteractivePopGesture()
        validateInput()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sexIdentityTextField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        enableInteractivePopGesture()
    }

    //MARK: - Setup

    func setupTextFields() {
        sexIdentityTextField.delegate = self
        sexIdentityTextField.inputView = sexPicker
        sexOptions = [.blank, .female, .male]
        
        sexPreferenceTextField.delegate = self
        sexPreferenceTextField.inputView = sexPicker
        sexOptions = [.blank, .female, .male, .both]
    }
    
    func setupContinueButton() {
        continueButton.internalButton.isEnabled = false
        continueButton.internalButton.setBackgroundImage(UIImage.imageFromColor(color: .customWhite), for: .normal)
        continueButton.internalButton.setBackgroundImage(UIImage.imageFromColor(color: .customWhite.withAlphaComponent(0.2)), for: .disabled)
        continueButton.internalButton.setTitleColor(.customBlack, for: .normal)
        continueButton.internalButton.setTitleColor(.customBlack, for: .disabled)
        continueButton.configure(title: "continue", systemImage: "")
        continueButton.internalButton.addTarget(self, action: #selector(didPressedContinueButton), for: .touchUpInside)
    }

    //MARK: - User Interaction
    
//    @objc func handleDatePicker(sender: UIDatePicker) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "en_US")
//        dateFormatter.dateFormat = "MMMM d, yyyy"
//        dobTextField.text = dateFormatter.string(from: sender.date)
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        dobData = dateFormatter.string(from: sender.date)
//        validateInput()
//     }

//    @IBAction func backButtonDidPressed(_ sender: UIBarButtonItem) {
//        navigationController?.popViewController(animated: true)
//    }

    @objc func didPressedContinueButton() {
        tryToContinue()
    }

    @IBAction func whyWeAskDidTapped(_ sender: UIButton) {
        AlertManager.showInfoCentered("why we ask about sex", "in order to follow legal guidelines for platforms with user-generated content, apple requires us to ensure all account holders are above their country's minimum age requirement", on: self)
    }
    
    //MARK: - TextField Delegate

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        if sender == sexIdentityTextField, sender.text?.count == 10 {
            sexPreferenceTextField.becomeFirstResponder()
        }
        validateInput()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

    //MARK: - Helpers

    func tryToContinue() {
        guard
            let sexIdentityText = sexIdentityTextField.text,
            sexIdentityText != "",
            let sexIdentity = Sex(rawValue: sexIdentityText)?.databaseName,
            let sexPreferenceText = sexIdentityTextField.text,
            sexPreferenceText != "",
            let sexPreference = Sex(rawValue: sexPreferenceText)?.databaseName
        else {
            AlertManager.displayError("no sex option selected", "please try again")
            return
        }
        
        isSubmitting = true
        Task {
            do {
                try await UserService.singleton.createUser(
                    firstName: AuthContext.firstName,
                    lastName: AuthContext.lastName,
//                    profilePic: AuthContext.profilePic!,
                    phoneNumber: AuthContext.phoneNumber,
                    email: AuthContext.email,
                    sexIdentity: sexIdentity,
                    sexPreference: sexPreference)
                AuthContext.reset()
                navigationController?.pushViewController(CreateProfileVC.create(), animated: true, completion: { [weak self] in
                    self?.isSubmitting = false
                })
            } catch {
                handleFailure(error)
            }
        }
    }
    
    //TODO: make sure these error messages are descriptive
    func handleFailure(_ error: Error) {
        isSubmitting = false
        AlertManager.displayError(error)
    }

    func validateInput() {
        isValidInput = sexIdentityTextField.text!.count > 0 && sexPreferenceTextField.text!.count > 0
    }
}

extension EnterBiosVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        sexIdentityTextField.isFirstResponder ? 3 : 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sexOptions[row].displayName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if sexIdentityTextField.isFirstResponder {
            sexIdentityTextField.text = sexOptions[pickerView.selectedRow(inComponent: component)].displayName
        } else {
            sexPreferenceTextField.text = sexOptions[pickerView.selectedRow(inComponent: component)].displayName
        }
        validateInput()
    }
    
}
