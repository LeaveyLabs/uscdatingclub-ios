//
//  CoordinateVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/09.
//

import UIKit

class CoordinateVC: UIViewController {

    //UI
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var timeSublabel: UILabel!
    @IBOutlet var locationImageView: UIImageView!
    @IBOutlet var locationLabel: UILabel!
    
    //Info
    var matchInfo: MatchInfo!
    var connectManager: ConnectManager!
    
    //MARK: - Initialization
    
    class func create(matchInfo: MatchInfo) -> CoordinateVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.Coordinate) as! CoordinateVC
        vc.matchInfo = matchInfo
        vc.connectManager = ConnectManager(startTime: matchInfo.matchTime, delegate: vc)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectManager.startLocationCalculation() //must come first
        connectManager.startTimer()
        setupButtons()
        setupLabels() //must come after connect manager created
        startTimer()
    }
    
    func setupButtons() {
        closeButton.addAction(.init(handler: { [self] _ in
            closeButtonDidPressed()
        }), for: .touchUpInside)
        moreButton.addAction(.init(handler: { [self] _ in
            moreButtonDidPressed()
        }), for: .touchUpInside)
    }
    
    func setupLabels() {
        nameLabel.text = "Mei"
        timeLabel.text = connectManager.timeLeft(fromDate: matchInfo.matchTime)
        timeSublabel.text = "left to connect"
    }
    
    func startTimer() {
        let minsLeft = 3
        let secsLeft = 34
        timeLabel.text = String(minsLeft) + "m " + String(secsLeft) + "s"
    }
    
    //MARK: - Interaction
    
    func closeButtonDidPressed() {
        AlertManager.showAlert(title: "stop sharing your location with \(matchInfo.matchName)?",
                               subtitle: "you won't be able to restart it afterwards",
                               primaryActionTitle: "stop sharing location",
                               primaryActionHandler: {
            //end the match
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        },
                               secondaryActionTitle: "nevermind",
                               secondaryActionHandler: {
            //do nothing
        }, on: self)
    }
    
    func moreButtonDidPressed() {
        let moreVC = SheetVC.create(sheetButtons: [SheetButton(title: "report", systemImageName: "exclamationmark.triangle", handler: {
            self.presentReportAlert()
        })])
        present(moreVC, animated: true)
    }
    
    func presentReportAlert() {
        AlertManager.showAlert(title: "would you like to report \(matchInfo.matchName)?",
                               subtitle: "your location will stop sharing immediately",
                               primaryActionTitle: "report",
                               primaryActionHandler: {
            //block user
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        },
                               secondaryActionTitle: "nevermind",
                               secondaryActionHandler: {
            //do nothing
        }, on: SceneDelegate.visibleViewController!)
    }

}

extension CoordinateVC: ConnectManagerDelegate {
    
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
        DispatchQueue.main.async { [self] in
            locationLabel.text = prettyDistance(meters: distance)
            locationImageView.transform = CGAffineTransform.identity.rotated(by: heading)
        }
    }
    
}
