//
//  TestTextVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/03.
//

import UIKit

class TestTextVC: UIViewController {
    
    enum TestTextType: CaseIterable {
        case welcome, submitting, finished
    }

    //MARK: - Properties
    
    //UI
    @IBOutlet var primaryButton: SimpleButton!
    @IBOutlet var primaryLabel: UILabel!
    @IBOutlet var secondaryLabel: UILabel!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var cancelButton: UIButton!
    
    var testTextType: TestTextType = .welcome
    var isFirstTest: Bool {
        TestContext.isFirstTest
    }
    
    //MARK: - Initialization
    
    class func create(type: TestTextType) -> TestTextVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.TestText) as! TestTextVC
        vc.testTextType = type
        return vc
    }

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        primaryButton.internalButton.addTarget(self, action: #selector(didTapPrimaryButton), for: .touchUpInside)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        switch testTextType {
        case .welcome:
            break //MAKE SURE TO reset test context before presenting this VC
        case .submitting:
            Task {
                do {
                    await Thread.sleep(forTimeInterval: 2)
//                    try await UserService.singleton.updateTestResults()
                    TestContext.reset()
                    DispatchQueue.main.async { [self] in
                        testTextType = .finished
                        setupUI()
                    }
                } catch {
                    AlertManager.displayError(error)
                }
            }
        case .finished:
            break //submit test context to database
        }
    }
    
    //MARK: - Setup
    
    func setupUI() {
        switch testTextType {
        case .welcome:
            cancelButton.isHidden = isFirstTest
            activityIndicatorView.stopAnimating()
            primaryLabel.text = "the compatibility test"
            secondaryLabel.text = "(no cheating allowed)"
            primaryButton.configure(title: "begin", systemImage: "")
        case .submitting:
            cancelButton.isHidden = true
            activityIndicatorView.startAnimating()
            primaryLabel.text = "submitting responses"
            secondaryLabel.alpha = 0
            primaryButton.configure(title: "aye", systemImage: "")
            primaryButton.internalButton.isEnabled = false
            primaryButton.alpha = 0
        case .finished:
            if isFirstTest {
                secondaryLabel.text = "welcome to the usc dating club."
                UIView.animate(withDuration: 2) { [self] in
                    activityIndicatorView.stopAnimating()
                    primaryLabel.text = "responses submitted"
                } completion: { completed in
                    UIView.animate(withDuration: 2) { [self] in
                        secondaryLabel.alpha = 1
                    } completion: { completed in
                        self.primaryButton.internalButton.isEnabled = true
                        UIView.animate(withDuration: 2) { [self] in
                            primaryButton.alpha = 1
                        }
                    }
                }
            } else {
                activityIndicatorView.stopAnimating()
                primaryLabel.text = "responses submitted"
                self.primaryButton.internalButton.isEnabled = true
                UIView.animate(withDuration: 1) { [self] in
                    primaryButton.alpha = 1
                }
            }
        }
    }
    
    //MARK: - Interaction
    
    @objc func didTapPrimaryButton() {
        switch testTextType {
        case .welcome:
            navigationController?.pushViewController(TestQuestionsVC.create(page: 0), animated: true)
        case .submitting:
            break
        case .finished:
            dismiss(animated: true)
        }
    }
    
    @IBAction func cancelButtonDidTapped() {
        dismiss(animated: true)
    }

}
