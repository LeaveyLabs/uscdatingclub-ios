//
//  CreateProfileViewController.swift
//  mist-ios
//
//  Created by Adam Monterey on 8/25/22.
//

import UIKit

class CreateProfileVC: KUIViewController, UITextFieldDelegate {
    
    //MARK: - Lifecycle
    
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var miniCameraButton: UIButton!
    @IBOutlet weak var profilePicTextLabel: UILabel!
    @IBOutlet weak var continueButton: SimpleButton!
//    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var firstNameIndicatorView: UIView!
    @IBOutlet weak var lastNameIndicatorView: UIView!
//    @IBOutlet weak var usernameIndicatorView: UIView!
    @IBOutlet weak var profilePicIndicatorView: UIView!

    @IBOutlet weak var headerTitleView: UIView!
    @IBOutlet weak var headerSpacingView: UIView!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    
    var imagePicker: ImagePicker!
    
    var isValidInput: Bool! {
        didSet {
            continueButton.internalButton.isEnabled = isValidInput
            continueButton.alpha = isValidInput ? 1 : 0.5
            profilePictureButton.imageView?.becomeProfilePicImageView(with: profilePic)
            profilePicTextLabel.isHidden = profilePic != defaultPic
            miniCameraButton.isHidden = profilePic == defaultPic
        }
    }
    var isSubmitting: Bool = false {
        didSet {
            continueButton.internalButton.setTitle(isSubmitting ? "" : "continue", for: .normal)
            continueButton.internalButton.loadingIndicator(isSubmitting)
        }
    }
    
    var profilePic: UIImage? {
        didSet {
            validateInput()
        }
    }
    let defaultPic = UIImage(systemName: "circle.fill")!.withRenderingMode(.alwaysTemplate)
    
    //MARK: - Initialization
    
    class func create() -> CreateProfileVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Auth, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.CreateProfile) as! CreateProfileVC
        return vc
    }

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shouldNotAnimateKUIAccessoryInputView = true
        profilePic = defaultPic
        setupButtons()
        setupTextFields()
        setupHeaderAndImageBasedOnScreenSize()
        firstNameTextField.becomeFirstResponder()
        setupIndicatorViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        print(view.bounds.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupImagePicker()
        validateInput()
        disableInteractivePopGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        enableInteractivePopGesture()
    }
    
    //MARK: - Setup
    
    func setupIndicatorViews() {
        profilePicIndicatorView.roundCornersViaCornerRadius(radius: 4)
        firstNameIndicatorView.roundCornersViaCornerRadius(radius: 4)
        lastNameIndicatorView.roundCornersViaCornerRadius(radius: 4)
//        usernameIndicatorView.roundCornersViaCornerRadius(radius: 4)
    }
    
    func setupButtons() {
        continueButton.internalButton.isEnabled = false
        continueButton.internalButton.setBackgroundImage(UIImage.imageFromColor(color: .customWhite), for: .normal)
        continueButton.internalButton.setBackgroundImage(UIImage.imageFromColor(color: .customWhite.withAlphaComponent(0.2)), for: .disabled)
        continueButton.internalButton.setTitleColor(.black, for: .normal)
        continueButton.internalButton.setTitleColor(.black, for: .disabled)
        continueButton.configure(title: "continue", systemImage: "")
        continueButton.internalButton.addTarget(self, action: #selector(didPressedContinueButton), for: .touchUpInside)
        // Setup miniCameraButton
        miniCameraButton.isHidden = true
        miniCameraButton.becomeRound()
        profilePictureButton.imageView?.becomeProfilePicImageView(with: defaultPic)
        profilePictureButton.contentHorizontalAlignment = .fill //so that the systemimage expands
        profilePictureButton.contentVerticalAlignment = .fill
    }
    
    func setupTextFields() {
//        usernameTextField.delegate = self
//        usernameTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
//        usernameTextField.layer.cornerRadius = 5
//        usernameTextField.setLeftAndRightPadding(10)
        
        firstNameTextField.delegate = self
        firstNameTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        firstNameTextField.layer.cornerRadius = 5
        firstNameTextField.setLeftAndRightPadding(10)
        
        lastNameTextField.delegate = self
        lastNameTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        lastNameTextField.layer.cornerRadius = 5
        lastNameTextField.setLeftAndRightPadding(10)
    }
    
    func setupImagePicker() {
        imagePicker = ImagePicker(presentationController: self, delegate: self, pickerSources: [.camera, .photoLibrary])
    }
    
    func setupHeaderAndImageBasedOnScreenSize() {
        let screenHeight = view.bounds.height
        if screenHeight < 600 {
            headerTitleView.isHidden = true
            headerSpacingView.isHidden = true
        } else if screenHeight > 900 {
            imageViewWidthConstraint.constant += 90
        } else if screenHeight > 850 {
            imageViewWidthConstraint.constant += 60
        } else if screenHeight > 700 {
            imageViewWidthConstraint.constant += 30
        } else if screenHeight > 600 {
            imageViewWidthConstraint.constant += 8
        }
    }
    
    //MARK: - TextField Delegate
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        validateInput()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        }
        if textField == lastNameTextField {
            tryToContinue()
        }
//        if textField == usernameTextField {
//            tryToContinue()
//        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let didAutofillTextfield = range == NSRange(location: 0, length: 0) && string.count > 1
        if textField == firstNameTextField {
            if didAutofillTextfield {
                DispatchQueue.main.async {
                    self.lastNameTextField.becomeFirstResponder()
                }
            }
            return textField.shouldChangeCharactersGivenMaxLengthOf(20, range, string)
        }
        if textField == lastNameTextField {
//            if didAutofillTextfield {
//                DispatchQueue.main.async {
//                    self.usernameTextField.becomeFirstResponder()
//                }
//            }
            return textField.shouldChangeCharactersGivenMaxLengthOf(20, range, string)
        }
//        if textField == usernameTextField {
//            return textField.shouldChangeCharactersGivenMaxLengthOf(30, range, string)
//        }
        return true
    }
    
    //MARK: - User Interaction
    
    @IBAction func backButtonDidPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didPressedContinueButton(_ sender: UIButton) {
        tryToContinue()
    }
    
    @IBAction func didPressedChoosePhotoButton(_ sender: UIButton) {
        imagePicker.present(from: sender)
    }
    
    //MARK: - Helpers

    func tryToContinue() {
        guard
            isValidInput,
            let uploadedProfilePic = profilePictureButton.imageView?.image,
            let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text
        else { return }
        isSubmitting = true
        AuthContext.firstName = firstName
        AuthContext.lastName = lastName
        AuthContext.profilePic = uploadedProfilePic
        navigationController?.pushViewController(EnterBiosVC.create(), animated: true, completion: { [weak self] in
            self?.isSubmitting = false
        })
    }
    
    //TODO: make sure these error messages are descriptive
    func handleFailure(_ error: Error) {
        isSubmitting = false
        AlertManager.displayError(error)
    }
    
    func validateInput() {
        let validPic = profilePic != defaultPic && profilePic != nil
//        let validUsername = Validate.validateUsername(usernameTextField.text ?? "")
        let validName = firstNameTextField.text!.count > 0 && lastNameTextField.text!.count > 0
        isValidInput = validPic && validName
        
        firstNameIndicatorView.isHidden = firstNameTextField.text!.count > 0
        lastNameIndicatorView.isHidden = lastNameTextField.text!.count > 0
//        usernameIndicatorView.isHidden = usernameTextField.text!.count > 0
        profilePicIndicatorView.isHidden = validPic
    }

}

extension CreateProfileVC: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        guard let newImage = image else { return }
        profilePic = newImage.withRenderingMode(.alwaysOriginal)
    }
    
}
