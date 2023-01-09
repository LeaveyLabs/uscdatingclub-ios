//
//  AccountVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/08.
//

import UIKit

class EditAccountVC: UIViewController {

    //MARK: - Properties
    //UI
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    
    //References to UITableViewCell
    var firstNameTextField: UITextField!
    var lastNameTextField: UITextField!
    var sexIdentityTextField: UITextField!
    var sexPreferenceTextField: UITextField!
    var sexOptions: [Sex] = [.blank, .f, .m, .b]


    //State
    var firstName: String = UserService.singleton.getFirstName() {
        didSet { validateInput() }
    }
    var lastName: String = UserService.singleton.getLastName() {
        didSet { validateInput() }
    }
    var sexPreference: String = UserService.singleton.getSexPreference() {
        didSet { validateInput() }
    }
    var sexIdentity: String = UserService.singleton.getSexIdentity() {
        didSet { validateInput() }
    }
    
    var isSaving: Bool = false {
        didSet {
            saveButton.loadingIndicator(isSaving)
            saveButton.isEnabled = !isSaving //this state change forces an update for UIButtonConfiguration
            view.isUserInteractionEnabled = !isSaving
        }
    }
    
    //MARK: - Initialization
    
    class func create() -> EditAccountVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.EditAccount) as! EditAccountVC
        return vc
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupButtons()
        setupTableView()
        titleLabel.text = "edit account"
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackground)))
    }
    
    //MARK: - Setup
    
    func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorStyle = .none

        //the below was giving me issues for some reason
        tableView.register(UINib(nibName: Constants.SBID.Cell.SimpleButtonCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SimpleButtonCell)
        tableView.register(UINib(nibName: Constants.SBID.Cell.SimpleEntryCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SimpleEntryCell)
    }
    
    func setupButtons() {
        backButton.addAction(UIAction(handler: { [self] _ in
            dismiss(animated: true)
        }), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.isEnabled = false
        saveButton.setTitleColor(.customWhite, for: .normal)
        saveButton.setTitleColor(.customWhite.withAlphaComponent(0.5), for: .disabled)
        saveButton.setTitle("save", for: .normal)
        saveButton.setTitle("", for: .disabled)
    }
    
    //MARK: - Interaction
    
    @objc func didTapBackground() {
        view.endEditing(true)
    }
    
    @objc func saveButtonTapped() {
        tryToUpdateProfile()
    }
    
    func logoutButtonPressed() {
        UserService.singleton.kickUserToHomeScreenAndLogOut()
    }
    
    func deleteAccountButtonPressed() {
        AlertManager.showDeleteAccountAlert(on: self)
    }
    
    func tryToUpdateProfile() {
        view.endEditing(true)
        isSaving = true
        Task {
            do {
//                try await withThrowingTaskGroup(of: Void.self) { group in
//                    if firstName != UserService.singleton.getFirstName() {
//                        group.addTask {
//                            try await UserService.singleton.updateFirstName(to: self.firstName)
//                        }
//                    }
//                    if lastName != UserService.singleton.getLastName() {
//                        group.addTask {
//                            try await UserService.singleton.updateLastName(to: self.lastName)
//                        }
//                    }
//                    if sexIdentity != UserService.singleton.getSexIdentity() {
//                        group.addTask {
//                            try await UserService.singleton.updateLastName(to: self.lastName)
//                        }
//                    }
//                    if sexIdentity != UserService.singleton.getSexPreference() {
//                        group.addTask {
//                            try await UserService.singleton.updateLastName(to: self.lastName)
//                        }
//                    }
//                    try await group.waitForAll()
//                }
                handleSuccessfulUpdate()
            } catch {
                AlertManager.displayError(error)
            }
            isSaving = false
        }
    }
    
    //MARK: - Helpers
    
    func validateInput() {
        let isValidName = Validate.validateName(firstName) && Validate.validateName(lastName)
        let isValidSex = Validate.validateSex(sexIdentity) && Validate.validateSex(sexPreference)
        let isNewName = (firstName != UserService.singleton.getFirstName() || lastName != UserService.singleton.getLastName())
        let isNewSex = sexIdentity != UserService.singleton.getSexIdentity() || sexPreference != UserService.singleton.getSexPreference()
        let isValid = isValidName && isValidSex && (isNewName || isNewSex)
        
        saveButton.isEnabled = isValid
        if saveButton.titleLabel!.text == "" {
            saveButton.setTitle("save", for: .normal)
            saveButton.tintColor = .customWhite
        }
    }
    
    func handleSuccessfulUpdate() {
        isSaving = false
        saveButton.tintColor = .green
        saveButton.setTitle("", for: .normal)
        saveButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
    }

}

extension EditAccountVC: UITableViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
}

extension EditAccountVC: UITableViewDataSource {
        
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section <= 1 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let simpleEntryCell = tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SimpleEntryCell, for: indexPath) as! SimpleEntryCell
            simpleEntryCell.configure(title: indexPath.row == 0 ? "first name" : "last name", content: indexPath.row == 0 ? firstName : lastName, delegate: self)
            simpleEntryCell.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            if indexPath.row == 0 {
                firstNameTextField = simpleEntryCell.textField
            } else {
                lastNameTextField = simpleEntryCell.textField
            }
            return simpleEntryCell
        case 1:
            let simpleEntryCell = tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SimpleEntryCell, for: indexPath) as! SimpleEntryCell
            simpleEntryCell.configureDropdown(title: indexPath.row == 0 ? "sexual identity" : "sexual preference", content: Sex(rawValue: indexPath.row == 0 ? sexIdentity : sexPreference)?.displayName ?? "", textFieldDelegate: self, pickerDelegate: self, pickerDataSource: self)
            if indexPath.row == 0 {
                sexIdentityTextField = simpleEntryCell.textField
            } else {
                sexPreferenceTextField = simpleEntryCell.textField
            }
            return simpleEntryCell
        case 2:
            let simpleButtonCell = tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SimpleButtonCell, for: indexPath) as! SimpleButtonCell
            simpleButtonCell.configure(title: "logout", systemImage: "arrow.uturn.backward", footerText: "logged in as " + (UserService.singleton.getPhoneNumberPretty() ?? UserService.singleton.getPhoneNumber()!)) {
                self.logoutButtonPressed()
            }
            return simpleButtonCell
        case 3:
            let simpleButtonCell = tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SimpleButtonCell, for: indexPath) as! SimpleButtonCell
            simpleButtonCell.configure(title: "delete account", systemImage: "trash") {
                self.deleteAccountButtonPressed()
            }
            simpleButtonCell.simpleButton.internalButton.tintColor = .red
            simpleButtonCell.simpleButton.internalButton.setTitleColor(.red, for: .normal)
            return simpleButtonCell
        default:
            fatalError()
        }
    }
}

extension EditAccountVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let newText = textField.text else { return }
        if textField == firstNameTextField {
            firstName = newText
        } else if textField == lastNameTextField {
            lastName = newText
        }
        validateInput()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.shouldChangeCharactersGivenMaxLengthOf(20, range, string)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    
}

extension EditAccountVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        let sexDisplayName = sexOptions[pickerView.selectedRow(inComponent: component)].displayName
        if sexIdentityTextField.isFirstResponder {
            sexIdentityTextField.text = sexDisplayName
            sexIdentity = sexDisplayName.isEmpty ? "" : String(sexDisplayName.first!)
        } else {
            sexPreferenceTextField.text = sexOptions[pickerView.selectedRow(inComponent: component)].displayName
            sexPreference = sexDisplayName.isEmpty ? "" : String(sexDisplayName.first!)
        }
        
        validateInput()
    }
    
}
