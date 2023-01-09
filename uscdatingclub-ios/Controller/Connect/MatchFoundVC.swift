//
//  MatchFoundVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/09.
//

import UIKit

struct MatchInfo {
    let matchName: String
    let compatibility: String
    let matchTime: Date
}

class MatchFoundVC: UIViewController {
        
    //MARK: - Properties
    
    //UI
    @IBOutlet var passButton: SimpleButton!
    @IBOutlet var meetUpButton: SimpleButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nameSublabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var timeSublabel: UILabel!
    
    //Info
    var matchInfo: MatchInfo!
    var connectManager: ConnectManager!

    //MARK: - Initialization
    
    class func create(matchInfo: MatchInfo) -> MatchFoundVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.MatchFound) as! MatchFoundVC
        vc.matchInfo = matchInfo
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        nameLabel.text = matchInfo.matchName
        nameSublabel.text = "you and " + matchInfo.matchName + " are\n\(matchInfo.compatibility)% compatible"
        timeSublabel.text = "left to respond"
        timeLabel.text = connectManager.timeLeft(fromDate: matchInfo.matchTime)
        connectManager = ConnectManager(startTime: matchInfo.matchTime, delegate: self)
    }
    
    //MARK: - Setup
    
    func setupButtons() {
        meetUpButton.configure(title: "meet up", systemImage: "figure.wave")
        passButton.configure(title: "pass", systemImage: "xmark")
        meetUpButton.internalButton.addTarget(self, action: #selector(meetupButtonDidPressed), for: .touchUpInside)
        passButton.internalButton.addTarget(self, action: #selector(passButtonDidPressed), for: .touchUpInside)
    }
    
    //MARK: - Interaction
    
    @objc func meetupButtonDidPressed() {
        //post to database
        meetUpButton.isHidden = true
        passButton.configure(title: "waiting for " + matchInfo.matchName, systemImage: "")
        timeSublabel.text = "left for Mei to respond"
        passButton.isUserInteractionEnabled = false
        passButton.alpha = 0.5
    }

    @objc func passButtonDidPressed() {
        AlertManager.showAlert(title: "are you sure you want to pass?",
                               subtitle: "you won't be able to connect with \(matchInfo.matchName) again",
                               primaryActionTitle: "yes",
                               primaryActionHandler: {
            //post to database
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        },
                               secondaryActionTitle: "nevermind",
                               secondaryActionHandler: {
            //do nothing
        }, on: self)
        dismiss(animated: true)
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

extension MatchFoundVC: ConnectManagerDelegate {
    
    func newTimeElapsed(newTime: String) {
        DispatchQueue.main.async {
            self.timeLabel.text = newTime
        }
    }
    
    func timeRanOut() {
        AlertManager.showAlert(title: "your time to connect with " + matchInfo.matchName + " has run out",
                               subtitle: "",
                               primaryActionTitle: "return hom",
                               primaryActionHandler: {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }, on: self)
    }
    
}
