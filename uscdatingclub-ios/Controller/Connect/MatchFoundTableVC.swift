//
//  MatchFoundTableVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/10.
//

import UIKit

class MatchFoundTableVC: UIViewController {
        
    //MARK: - Properties
    
    //UI
    @IBOutlet var tableView: UITableView!
    
    var timeLeftLabel: UILabel!
    
    //Info
    var matchInfo: MatchInfo!
    var connectManager: ConnectManager!

    //MARK: - Initialization
    
    class func create(matchInfo: MatchInfo) -> MatchFoundTableVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.MatchFoundTable) as! MatchFoundTableVC
        vc.matchInfo = matchInfo
        vc.connectManager = ConnectManager(matchInfo: matchInfo, delegate: vc)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectManager.startTimer() //must come first
        setupTableView() //must come after setting up connectManager
    }
    
    //MARK: - Setup
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = true
        tableView.indicatorStyle = .white
        tableView.separatorStyle = .none

        //the below was giving me issues for some reason
        tableView.register(UINib(nibName: Constants.SBID.Cell.ConnectHeaderCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.ConnectHeaderCell)
        tableView.register(UINib(nibName: Constants.SBID.Cell.ConnectTitleCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.ConnectTitleCell)
        tableView.register(UINib(nibName: Constants.SBID.Cell.ConnectSpectrumCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.ConnectSpectrumCell)
        tableView.register(UINib(nibName: Constants.SBID.Cell.SimpleButtonCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SimpleButtonCell)
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

//    @objc func passButtonDidPressed() {
//        AlertManager.showAlert(title: "are you sure you want to pass on \(matchInfo.userName)?",
//                               subtitle: "you won't be able to connect again",
//                               primaryActionTitle: "i'm sure",
//                               primaryActionHandler: {
//            //post to database
//            DispatchQueue.main.async {
//                self.dismiss(animated: true)
//            }
//        },
//                               secondaryActionTitle: "nevermind",
//                               secondaryActionHandler: {
//            //do nothing
//        }, on: self)
//    }

}

//MARK: - UITableViewDelegate

extension MatchFoundTableVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return view.bounds.height / 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
}

//MARK: = UITableViewDataSource

extension MatchFoundTableVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 3
        case 3:
            return 1
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.ConnectHeaderCell, for: indexPath) as! ConnectHeaderCell
            cell.configure(timeLeft: matchInfo.timeLeftString,
                           distanceAway: prettyDistance(meters: matchInfo.distance, shortened: true))
            self.timeLeftLabel = cell.timeLeftLabel
            return cell
        case 1:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.ConnectTitleCell, for: indexPath) as! ConnectTitleCell
            cell.configure(name: matchInfo.userName, compatibility: matchInfo.compatibility)
            return cell
        case 2:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.ConnectSpectrumCell, for: indexPath) as! ConnectSpectrumCell
            let percent = matchInfo.percents[indexPath.row]
            cell.configure(title: percent.trait,
                           matchName: matchInfo.userName,
                           avgPercent: percent.avgPercent,
                           youPercent: percent.youPercent,
                           matchPercent: percent.matchPercent,
                           shouldDisplayLabels: indexPath.row == 2)
            return cell
        case 3:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SimpleButtonCell, for: indexPath) as! SimpleButtonCell
            switch indexPath.row {
            case 0:
                cell.configure(title: "meet up", systemImage: "figure.wave", buttonHeight: 60) {
                    self.meetupButtonDidPressed()
                }
//            case 1:
//                cell.configure(title: "pass", systemImage: "xmark") {
//                    self.passButtonDidPressed()
//                }
//                cell.simpleButton.alpha = 0.7
            default:
                fatalError()
            }
            return cell
        default:
            fatalError()
        }
        
    }
    
}

//MARK: - ConnectManagerDelegate

extension MatchFoundTableVC: ConnectManagerDelegate {
    
    func newTimeElapsed() {
        DispatchQueue.main.async { [self] in
            switch matchInfo.elapsedTime.minutes {
            case 0:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case 1:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            case 2:
                UIImpactFeedbackGenerator(style: matchInfo.elapsedTime.seconds >= 50 ? .rigid : .heavy).impactOccurred()
            default:
                break
            }
            self.tableView.reloadData()
//            print("NEW TIME ELAPSED")
//            self.timeLeftLabel.alpha = 0.5
//            self.timeLeftLabel.textColor = .customWhite
//            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
//                print("START ANIMATE")
//                self.timeLeftLabel.alpha = 1
//                self.timeLeftLabel.textColor = .blue
//            } completion: { completed in
//                print("FINISH ANIMATE")
//            }
        }
    }
    
    func timeRanOut() {
        AlertManager.showAlert(title: "your time to connect with " + matchInfo.userName + " has run out",
                               subtitle: "",
                               primaryActionTitle: "return home",
                               primaryActionHandler: {
            DispatchQueue.main.async {
                transitionToStoryboard(storyboardID: Constants.SBID.SB.Main, duration: 0.5)
            }
        }, on: self)
    }
    
    func newRelativePositioning(heading: CGFloat, distance: Double) {
        //do nothing
    }
    
}
