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
    @IBOutlet var sexIdentityLabel: InsetLabel!
    @IBOutlet var sexPreferenceLabel: InsetLabel!
    @IBOutlet var whyWeAskButton: UIButton!
    @IBOutlet weak var continueButton: SimpleButton!
    @IBOutlet var titleLabel: UILabel!

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
        self.sexPicker.reloadAllComponents()

        validateInput()
        shouldNotAnimateKUIAccessoryInputView = true
        setupTextFields()
        setupLabels()
        setupContinueButton()
        titleLabel.font = AppFont.bold.size(30)
        whyWeAskButton.titleLabel?.font = AppFont2.medium.size(12)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateInput()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sexIdentityTextField.becomeFirstResponder()
        sexIdentityTextField.tintColor = .customBlack //ensure cursor is visible
    }

    //MARK: - Setup
    
    func setupLabels() {
        sexIdentityLabel.font = AppFont2.medium.size(17)
        sexIdentityLabel.insets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 10)
        sexPreferenceLabel.font = AppFont2.medium.size(17)
        sexPreferenceLabel.insets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 10)
    }

    func setupTextFields() {
        sexIdentityTextField.delegate = self
        sexIdentityTextField.inputView = sexPicker        
        sexPreferenceTextField.delegate = self
        sexPreferenceTextField.inputView = sexPicker
        sexOptions = [.blank, .f, .m, .b]
        sexIdentityTextField.font = AppFont.medium.size(17)
        sexPreferenceTextField.font = AppFont.medium.size(17)
        //Left insets
        sexIdentityTextField.setLeftPaddingPoints(8)
        sexPreferenceTextField.setLeftPaddingPoints(8)
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
        AlertManager.showInfoCentered("why we ask about sex", "usc dating club is a dating app, so your sexual identity & preferences determine who you'll be matched with.", on: self)
    }
    
    //MARK: - TextField Delegate

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
//        print("DID CHANGE")
//        if sender == sexIdentityTextField, let textCount = sender.text?.count, textCount > 0 {
//            sexPreferenceTextField.becomeFirstResponder()
//        }
//        validateInput()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        sexPicker.reloadAllComponents()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

    //MARK: - Helpers

    func tryToContinue() {
        guard
            let sexIdentityText = sexIdentityTextField.text,
            sexIdentityText != "",
            let sexIdentity = sexIdentityText.first,
            let sexPreferenceText = sexPreferenceTextField.text,
            sexPreferenceText != "",
            let sexPreference = sexPreferenceText.first
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
                    sexIdentity: String(sexIdentity),
                    sexPreference: String(sexPreference))
                AuthContext.reset()
                DispatchQueue.main.async { [self] in
                    navigationController?.pushViewController(HowItWorksVC.create(), animated: true, completion: { [weak self] in
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
    
    @MainActor
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
        return sexIdentityTextField.isFirstResponder ? 3 : 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sexOptions[row].displayName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if sexIdentityTextField.isFirstResponder {
            sexIdentityTextField.text = sexOptions[pickerView.selectedRow(inComponent: component)].displayName
            if let textCount = sexIdentityTextField.text?.count,
                textCount > 0,
               let prefTextCount = sexPreferenceTextField.text?.count,
               prefTextCount == 0 {
                sexPreferenceTextField.becomeFirstResponder()
            }
        } else {
            sexPreferenceTextField.text = sexOptions[pickerView.selectedRow(inComponent: component)].displayName
        }
        validateInput()
    }
    
}
