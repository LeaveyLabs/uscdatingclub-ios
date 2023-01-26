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
    var isFirstTest: Bool = UserService.singleton.isFirstTest()
    
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
            TestService.shared.resetResponseContext()
        case .submitting, .finished:
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            Task {
                do {
                    try await UserService.singleton.updateTestResponses(newResponses:TestService.shared.getResponsesContextAsArray())
                    try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
                    DispatchQueue.main.async { [self] in
                        testTextType = .finished
                        setupUI()
                    }
                } catch {
                    AlertManager.displayError(error)
                }
            }
        }
    }
    
    //MARK: - Setup
    
    func setupUI() {
        secondaryLabel.font = AppFont.regular.size(18)
        secondaryLabel.textColor = .customWhite.withAlphaComponent(0.7)
        primaryLabel.font = AppFont.bold.size(26)
        switch testTextType {
        case .welcome:
            cancelButton.isHidden = isFirstTest
            activityIndicatorView.stopAnimating()
            primaryLabel.text = "the compatibility test™"
            secondaryLabel.text = "we'll calculate your compatibility with other students"
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
                secondaryLabel.text = "welcome to\nsc dating club."
                UIView.animate(withDuration: 1) { [self] in
                    activityIndicatorView.stopAnimating()
                    primaryLabel.text = "responses submitted"
                } completion: { completed in
                    self.primaryButton.internalButton.isEnabled = true
//                    UIView.animate(withDuration: 1) { [self] in
//                        secondaryLabel.alpha = 1
//                    } completion: { completed in
                        UIView.animate(withDuration: 0.7) { [self] in
                            primaryButton.alpha = 1
                        }
//                    }
                }
            } else {
                activityIndicatorView.stopAnimating()
                primaryLabel.text = "responses submitted"
                secondaryLabel.text = "your future matches will be found based on your new responses"
                secondaryLabel.alpha = 1
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
            if !TestService.shared.needsLoading() {
                startTest()
            } else {
                primaryButton.internalButton.loadingIndicator(true)
                primaryButton.alpha = 0.7
                primaryButton.configure(title: "", systemImage: "")
                Task {
                    do {
                        try await TestService.shared.loadTestQuestions()
                        DispatchQueue.main.async {
                            self.startTest()
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.handleErrorLoadingQuestions(error)
                        }
                    }
                }
            }
        case .submitting:
            break
        case .finished:
            if isFirstTest {
                navigationController?.pushViewController(PermissionsVC.create(), animated: true)
            } else {
                dismiss(animated: true)
            }
        }
    }
    
    @MainActor
    func handleErrorLoadingQuestions(_ error: Error) {
        AlertManager.displayError("error loading questions", "please try again")
        primaryButton.internalButton.loadingIndicator(false)
        primaryButton.alpha = 1
        primaryButton.configure(title: "continue", systemImage: "")
    }
    
    @MainActor
    func startTest() {
        let nextTestPage = TestService.shared.getPage(number: 0)
        navigationController?.pushViewController(TestQuestionsVC.create(page: nextTestPage), animated: true)
    }
    
    @IBAction func cancelButtonDidTapped() {
        dismiss(animated: true)
    }

}
