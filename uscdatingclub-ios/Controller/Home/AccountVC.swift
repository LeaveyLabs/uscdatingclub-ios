//
//  AccountVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2022/12/28.
//

import UIKit

class AccountVC: UIViewController, PageVCChild {
    
    @IBOutlet var radarButton: UIButton!
    var pageVCDelegate: PageVCDelegate!
    
    @IBOutlet var retakeTestButton: SimpleButton!
    @IBOutlet var editAccountButton: SimpleButton!
    @IBOutlet var nameLabel: UILabel!


    //MARK: - Initialization
    
    class func create(delegate: PageVCDelegate) -> AccountVC {
        let accountVC = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.Account) as! AccountVC
        accountVC.pageVCDelegate = delegate
        return accountVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        nameLabel.text = UserService.singleton.getFirstLastName()
    }
    
    //MARK: - Setup
    
    func setupButtons() {
        retakeTestButton.configure(title: "retake the\ncompatibility test", systemImage: "testtube.2")
        editAccountButton.configure(title: "edit account", systemImage: "gearshape")
        radarButton.addAction(.init(handler: { [self] _ in
            pageVCDelegate.didPressBackwardButton()
        }), for: .touchUpInside)
        retakeTestButton.internalButton.addTarget(self, action: #selector(retakeTestButtonDidPressed), for: .touchUpInside)
        editAccountButton.internalButton.addTarget(self, action: #selector(editAccountButtonDidPressed), for: .touchUpInside)
    }
    
    //MARK: - Interaction
    
    @objc func retakeTestButtonDidPressed() {
        presentTest()
    }

    @objc func editAccountButtonDidPressed() {
        let nav = UINavigationController(rootViewController: EditAccountVC.create())
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    //MARK: - Helpers
    
    func presentTest() {
        TestContext.reset()
        TestContext.isFirstTest = false
        let nav = UINavigationController(rootViewController: TestTextVC.create(type: .welcome))
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
}
