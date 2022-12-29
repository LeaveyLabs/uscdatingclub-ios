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

    //MARK: - Initialization
    
    class func create(delegate: PageVCDelegate) -> AccountVC {
        let accountVC = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.Account) as! AccountVC
        accountVC.pageVCDelegate = delegate
        return accountVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
    }
    
    //MARK: - Setup
    
    func setupButtons() {
        radarButton.addAction(.init(handler: { [self] _ in
            pageVCDelegate.didPressBackwardButton()
        }), for: .touchUpInside)
    }

}
