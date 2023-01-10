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
    @IBOutlet var bottomButtonHeightConstraint: NSLayoutConstraint!
    
    //Info
    var matchInfo: MatchInfo!
    var connectManager: ConnectManager!

    //MARK: - Initialization
    
    class func create(matchInfo: MatchInfo) -> MatchFoundVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.MatchFound) as! MatchFoundVC
        vc.matchInfo = matchInfo
        vc.connectManager = ConnectManager(startTime: matchInfo.matchTime, delegate: vc)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectManager.startTimer() //must come first
        setupButtons()
        setupLabels() //must come after setting up connectManager
    }
    
    //MARK: - Setup
    
    func setupLabels() {
        timeLabel.text = connectManager.timeLeft(fromDate: matchInfo.matchTime)
        nameLabel.text = matchInfo.matchName
        timeSublabel.text = "left to respond"
        
        let boldedText = "\(matchInfo.compatibility)% compatible"
        let nameSublabelText = "you and " + matchInfo.matchName + " are\n\(matchInfo.compatibility)% compatible"
        let attributedText = NSMutableAttributedString(string: nameSublabelText)
        if let boldedRange = nameSublabelText.range(of: boldedText) {
            attributedText.setAttributes([.font: UIFont(name: "HelveticaNeue-Bold", size: 20)!], range: NSRange(boldedRange, in: nameSublabelText))
        }
        nameSublabel.attributedText = attributedText
    }
    
    func setupButtons() {
        meetUpButton.configure(title: "meet up", systemImage: "figure.wave")
        passButton.configure(title: "pass", systemImage: "xmark")
        meetUpButton.internalButton.addTarget(self, action: #selector(meetupButtonDidPressed), for: .touchUpInside)
        passButton.internalButton.addTarget(self, action: #selector(passButtonDidPressed), for: .touchUpInside)
    }
    
    //MARK: - Interaction
    
    @objc func meetupButtonDidPressed() {
        //post to database
//        meetUpButton.isHidden = true
//        passButton.configure(title: "waiting for " + matchInfo.matchName, systemImage: "")
//        timeSublabel.text = "left for \(matchInfo.matchName) to respond"
//        passButton.isUserInteractionEnabled = false
//        passButton.alpha = 0.5
//        bottomButtonHeightConstraint.constant = 60
        
        transitionToViewController(CoordinateVC.create(matchInfo: matchInfo), duration: 1)
    }

    @objc func passButtonDidPressed() {
        AlertManager.showAlert(title: "are you sure you want to pass on \(matchInfo.matchName)?",
                               subtitle: "you won't be able to connect again",
                               primaryActionTitle: "i'm sure",
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
                               primaryActionTitle: "return home",
                               primaryActionHandler: {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }, on: self)
    }
    
    func newRelativePositioning(heading: CGFloat, distance: Double) {
        //do nothing
    }
    
}
