//
//  ScreenDemoVC.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/01/16.
//

import UIKit

class ScreenDemoVC: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var screenImageView: UIImageView!
    var screenDemoType: ScreenDemoType!
    
    //MARK: - Initialization
    
    enum ScreenDemoType: CaseIterable {
        case notif, match, connect
    }
    
    class func create(type: ScreenDemoType) -> ScreenDemoVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Auth, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.ScreenDemo) as! ScreenDemoVC
        vc.screenDemoType = type
        return vc
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        setupLabels()
    }
    
    func setupImageView() {
        switch screenDemoType {
        case .match:
            screenImageView.image = UIImage(named: "matchscreen")
            subtitleLabel.text = "see your compatibility and get"
            titleLabel.text = "5 minutes to respond"
        case .notif:
            screenImageView.image = UIImage(named: "notificationscreen")
            subtitleLabel.text = ""
            titleLabel.text = "find out who it is 👀"
        case .connect:
            screenImageView.image = UIImage(named: "connectscreen")
            subtitleLabel.text = "spontaneously"
            titleLabel.text = "meet up and say hi"
        default:
            break
        }
    }
    
    func setupLabels() {
        subtitleLabel.font = AppFont.medium.size(17)
        titleLabel.font = AppFont.semibold.size(25)
    }
}
