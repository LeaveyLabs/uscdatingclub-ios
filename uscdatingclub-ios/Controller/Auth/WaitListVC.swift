//
//  WaitListVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/14.
//

import UIKit

class WaitListVC: UIViewController {

    //MARK: - Properties
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    //MARK: - Initialization
    
    class func create() -> WaitListVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Auth, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.WaitList) as! WaitListVC
        return vc
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = AppFont.bold.size(30)
        subtitleLabel.font = AppFont2.medium.size(17)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        Task {
            UserDefaults.standard.setValue(true, forKey: Constants.UserDefaultsKeys.isOnWaitList)
        }
    }
}
