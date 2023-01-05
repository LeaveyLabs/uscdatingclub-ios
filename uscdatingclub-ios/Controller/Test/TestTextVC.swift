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
    
    var testTextType: TestTextType = .welcome
    
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
            TestContext.reset()
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
            activityIndicatorView.stopAnimating()
            primaryLabel.text = "the compatibility test"
            secondaryLabel.text = "(no cheating allowed)"
            primaryButton.configure(title: "begin", systemImage: "")
        case .submitting:
            activityIndicatorView.startAnimating()
            primaryLabel.text = "submitting responses"
            secondaryLabel.alpha = 0
            primaryButton.configure(title: "aye", systemImage: "")
            primaryButton.internalButton.isEnabled = false
            primaryButton.alpha = 0
        case .finished:
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

}
