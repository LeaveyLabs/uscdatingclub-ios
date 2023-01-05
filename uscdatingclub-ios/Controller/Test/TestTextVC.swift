//
//  TestTextVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/03.
//

import UIKit

class TestTextVC: UIViewController {
    
    enum TestTextType: CaseIterable {
        case welcome, finished
    }

    //MARK: - Properties
    
    //UI
    @IBOutlet var primaryButton: SimpleButton!
    @IBOutlet var primaryLabel: UILabel!
    @IBOutlet var secondaryLabel: UILabel!
    
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
        case .finished:
            break //submit test context to database
        }
    }
    
    //MARK: - Setup
    
    func setupUI() {
        switch testTextType {
        case .welcome:
            primaryLabel.text = "the compatibility test"
            secondaryLabel.text = "describe yourself in each question. answer it to the best of your ability"
            primaryButton.configure(title: "begin", systemImage: "")
        case .finished:
            primaryLabel.text = "well done!"
            secondaryLabel.text = "you finished woooo"
            primaryButton.configure(title: "finish", systemImage: "")
        }
    }
    
    //MARK: - Interaction
    
    @objc func didTapPrimaryButton() {
        switch testTextType {
        case .welcome:
            navigationController?.pushViewController(TestQuestionsVC.create(), animated: true)
        case .finished:
            dismiss(animated: true)
        }
    }

}
