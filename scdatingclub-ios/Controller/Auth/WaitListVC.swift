//
//  WaitListVC.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/01/14.
//

import UIKit
import Mixpanel
import FirebaseAnalytics

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
        subtitleLabel.font = AppFont2.regular.size(17)
        Mixpanel.mainInstance().track(
            event: Constants.MP.AuthProcess.EventName,
            properties: [Constants.MP.AuthProcess.Kind:Constants.MP.AuthProcess.Waitlist])
        Analytics.logEvent(Constants.MP.AuthProcess.EventName, parameters: [Constants.MP.AuthProcess.Kind:Constants.MP.AuthProcess.Waitlist])
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}
