//
//  MatchFoundTableVC.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/01/10.
//

import UIKit
import Mixpanel

class MatchFoundTableVC: UIViewController {
        
    //MARK: - Properties
    
    //UI
    @IBOutlet var tableView: UITableView!
    
    var isVisible: Bool = false
    var timeLeftLabel: UILabel!
    
    //Info
    var isWaiting = false
    var matchInfo: MatchInfo!
    var connectManager: ConnectManager!

    //MARK: - Initialization
    
    class func create(matchInfo: MatchInfo) -> MatchFoundTableVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Connect, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.MatchFoundTable) as! MatchFoundTableVC
        vc.matchInfo = matchInfo
        vc.connectManager = ConnectManager(matchInfo: matchInfo, delegate: vc)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectManager.startRespondSession() //must come first
        setupTableView() //must come after setting up connectManager
        handlePreviousButtonPress()
        NotificationCenter.default.addObserver(forName: .matchAccepted, object: nil, queue: .main) { notification in
            DispatchQueue.main.async {
                self.goToCoordinateVC()
            }
        }
        handleFirstOpen()
        Mixpanel.mainInstance().track(
            event: Constants.MP.MatchOpen.EventName,
            properties: [Constants.MP.MatchOpen.match_id:matchInfo.matchId,
                         Constants.MP.MatchOpen.time_remaining:matchInfo.timeLeftToRespondString])
        Mixpanel.mainInstance().track(event: Constants.MP.MatchOpen.EventName)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isVisible = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
    }
    
    //MARK: - Setup
    
    func setupTableView() {
        tableView.delaysContentTouches = false //responsive button highlight
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = true
        tableView.indicatorStyle = .white
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 15))
        view.tintAdjustmentMode = .normal

        //the below was giving me issues for some reason
        tableView.register(UINib(nibName: Constants.SBID.Cell.ConnectHeaderCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.ConnectHeaderCell)
        tableView.register(UINib(nibName: Constants.SBID.Cell.ConnectTitleCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.ConnectTitleCell)
        tableView.register(UINib(nibName: Constants.SBID.Cell.ConnectSpectrumCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.ConnectSpectrumCell)
        tableView.register(UINib(nibName: Constants.SBID.Cell.ConnectInterestsCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.ConnectInterestsCell)
        tableView.register(UINib(nibName: Constants.SBID.Cell.SimpleButtonCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SimpleButtonCell)
    }
    
    func handlePreviousButtonPress() {
        guard Env.environment == .prod else { return }
        if let recentPressDate = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.MostRecentMeetUpButtonPressDate) as? Date,
           recentPressDate.isMoreRecentThan(Calendar.current.date(byAdding: .minute, value: -1 * Constants.minutesToRespond, to: Date())!) {
            isWaiting = true
        }
    }
    
    func handleFirstOpen() {
        if !DeviceService.shared.hasReceivedFeedbackNotification() {
            NotificationsManager.shared.scheduleRequestFeedbackNotification(minutesFromNow: Constants.minutesUntilFeedbackNotification)
            DeviceService.shared.didScheduleFeedbackNotification()
        }
    }
    
    //MARK: - Interaction
    
    @objc func meetupButtonDidPressed() {
        isWaiting = true
        tableView.reloadData()
        Task {
            do {
                try await MatchAPI.acceptMatch(userId: UserService.singleton.getId(),
                                               partnerId: matchInfo.partnerId)
                Mixpanel.mainInstance().people.increment(
                    property: Constants.MP.Profile.MatchAccept, by: 1)
                Mixpanel.mainInstance().track(
                    event: Constants.MP.MatchAccept.EventName,
                    properties: [Constants.MP.MatchOpen.match_id:matchInfo.matchId,
                                 Constants.MP.MatchOpen.time_remaining:matchInfo.timeLeftToRespondString])
                UserDefaults.standard.set(Date(), forKey: Constants.UserDefaultsKeys.MostRecentMeetUpButtonPressDate)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { //[weak self] in
                    AppStoreReviewManager.requestReviewIfAppropriate()
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleFailMeetupPress(error)
                }
            }
        }
    }
    
    func handleFailMeetupPress(_ error: Error) {
        isWaiting = false
        tableView.reloadData()
        AlertManager.displayError(error)
    }
    
    @MainActor
    func goToCoordinateVC() {
        transitionToViewController(CoordinateChatVC.create(matchInfo: matchInfo), duration: 1)
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
    
    //MARK: - Helpers
    
    func finish() {
        connectManager.endConnection()
        transitionToStoryboard(storyboardID: Constants.SBID.SB.Main, duration: 0.5)
    }

}

//MARK: - UITableViewDelegate

extension MatchFoundTableVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return view.bounds.height / 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
}

//MARK: = UITableViewDataSource

extension MatchFoundTableVC: UITableViewDataSource {
    
    var hasTextSimilarities: Bool {
        matchInfo.textSimilarities.count > 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return hasTextSimilarities ? 5 : 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return hasTextSimilarities ? 1 : matchInfo.numericalSimilarities.count
        case 3:
            return hasTextSimilarities ? matchInfo.numericalSimilarities.count : 1
        case 4:
            return 1
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.ConnectHeaderCell, for: indexPath) as! ConnectHeaderCell
            cell.configure(timeLeft: matchInfo.timeLeftToRespondString,
                           distanceAway: matchInfo.distance,
                           isWaiting: isWaiting,
                           matchName: matchInfo.partnerName)
            self.timeLeftLabel = cell.timeLeftLabel
            return cell
        case 1:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.ConnectTitleCell, for: indexPath) as! ConnectTitleCell
            cell.configure(name: matchInfo.partnerName, compatibility: matchInfo.compatibility)
            return cell
        case 2:
            if hasTextSimilarities {
                return createConnectInterestsCell(at: indexPath)
            } else {
                return createConnectSpectrumCell(at: indexPath)
            }
        case 3:
            if hasTextSimilarities {
                return createConnectSpectrumCell(at: indexPath)
            } else {
                return createButtonCell(at: indexPath)
            }
        case 4:
            return createButtonCell(at: indexPath)
        default:
            fatalError()
        }
        
    }
    
    //MARK: - Cell Creation
    
    func createConnectSpectrumCell(at indexPath: IndexPath) -> ConnectSpectrumCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.ConnectSpectrumCell, for: indexPath) as! ConnectSpectrumCell
        let numericalSimilarity = matchInfo.numericalSimilarities[indexPath.row]
        cell.configure(title: numericalSimilarity.trait,
                       matchName: matchInfo.partnerName,
                       avgPercent: numericalSimilarity.avgPercent,
                       youPercent: numericalSimilarity.youPercent,
                       matchPercent: numericalSimilarity.partnerPercent,
                       shouldDisplayFooter: indexPath.row == matchInfo.numericalSimilarities.count-1,
                       shouldDisplayHeader: indexPath.row == 0)
        return cell
    }
    
    func createButtonCell(at indexPath: IndexPath) -> SimpleButtonCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SimpleButtonCell, for: indexPath) as! SimpleButtonCell
        switch indexPath.row {
        case 0:
            if isWaiting {
                cell.configure(title: "waiting for \(matchInfo.partnerName)", systemImage: "", buttonHeight: 60, onButtonPress: {} )
                cell.simpleButton.alpha = 0.5
            } else {
                cell.configure(title: "meet up", systemImage: "figure.wave", buttonHeight: 60) {
                    self.meetupButtonDidPressed()
                }
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
    }
    
    func createConnectInterestsCell(at indexPath: IndexPath) -> ConnectInterestsCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.ConnectInterestsCell, for: indexPath) as! ConnectInterestsCell
        cell.configure(matchInfo.textSimilarities)
        return cell
    }
    
}

//MARK: - ConnectManagerDelegate

extension MatchFoundTableVC: ConnectManagerDelegate {
    
    func newSecondElapsed() {
        DispatchQueue.main.async { [self] in
//            switch matchInfo.elapsedTime.minutes {
//            case 0:
//                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//            case 1:
//                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//            case 2:
//                UIImpactFeedbackGenerator(style: matchInfo.elapsedTime.seconds >= 50 ? .rigid : .heavy).impactOccurred()
//            default:
//                break
//            }
            self.tableView.reloadData()
        }
    }
    
    func timeRanOut() {
        AlertManager.showAlert(title: "your time to connect with " + matchInfo.partnerName + " has run out",
                               subtitle: "",
                               primaryActionTitle: "return home",
                               primaryActionHandler: {
            DispatchQueue.main.async {
                self.finish()
            }
        }, on: self)
    }
    
    func newRelativePositioning(_ relativePositioning: RelativePositioning) {
        //do nothing
    }
    
}
