//
//  AboutVC.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2022/12/28.
//

import UIKit
import Mixpanel
import FirebaseAnalytics

class AboutVC: UIViewController, PageVCChild {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var radarButton: UIButton!
    var pageVCDelegate: PageVCDelegate!
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    let messageComposer = MessageComposer() //need to hold a storng reference so the delegate will be called

    //MARK: - Initialization
    
    class func create(delegate: PageVCDelegate) -> AboutVC {
        let aboutVC = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.About) as! AboutVC
        aboutVC.pageVCDelegate = delegate
        return aboutVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupTableView()
        setupLabels()
    }
    
    //MARK: - Setup
    
    func setupLabels() {
        versionLabel.text = "\(Version.currentVersion)"
        versionLabel.font = AppFont.medium.size(12)
        versionLabel.alpha = 0.7
        appNameLabel.font = AppFont.bold.size(18)
        titleLabel.font = AppFont.bold.size(20)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = true
        tableView.indicatorStyle = .white
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
        tableView.delaysContentTouches = false //for responsive button highlight

        tableView.register(UINib(nibName: Constants.SBID.Cell.SimpleButtonCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SimpleButtonCell)
    }
    
    func setupButtons() {
        radarButton.addAction(.init(handler: { [self] _ in
            pageVCDelegate.didPressForwardButton()
        }), for: .touchUpInside)
    }
    
    //MARK: - Interaction
    
    @objc func howItWorksButtonPressed() {
        let howItWorksVC = AuthStartPageVC.create()
        present(howItWorksVC, animated: true)
    }
    
    @objc func faqButtonPressed() {
        openURL(Constants.faqLink)
    }
    
    @objc func shareButtonPressed() {
        Mixpanel.mainInstance().track(event: Constants.MP.OpenShareAppButtonTapped.EventName)
        presentShareAppActivity()
    }
    
    @objc func rateButtonPressed() {
        AppStoreReviewManager.offerViewPromptUponUserRequest()
    }
    
    @objc func feedbackButtonPressed() {
        openURL(Constants.feedbackLink)
    }
        
    @objc func contactButtonPressed() {
        Analytics.logEvent("feedbackButtonPressed", parameters: nil)
        Mixpanel.mainInstance().track(event: Constants.MP.OpenTextUsButtonTapped.EventName)

        let who = Int.random(in: 0...1)
        let adamsNumber = "6159754270"
        let kevinsNumber = "3108741292"
        let recipient = who == 0 ? adamsNumber : kevinsNumber
        
        if (messageComposer.canSendText()) {
            let messageComposeVC = messageComposer.configuredMessageComposeViewController(recipients: [recipient], body: "Hey \(who == 0 ? "Adam" : "Kevin"), ")
            present(messageComposeVC, animated: true)
        } else {
            AlertManager.showAlert(title: "Cannot Send Text Message", subtitle: "Your device is not able to send text messages.", primaryActionTitle: "OK", primaryActionHandler: {}, on: self)
        }
        
        //MAIL:
//        guard
//            let textURL = URL(string: "sms:\(recipient)&body=\(text)"),
//            UIApplication.shared.canOpenURL(textURL)
//        else {
//            openMailtoURL(Constants.contactLink)
//            return
//        }
//        UIApplication.shared.open(textURL)
    }
    
    @IBAction func termsButtonDidPressed() {
        openURL(Constants.termsLink)
    }
    
    @IBAction func privacyButtonDidPressed() {
        openURL(Constants.privacyPageLink)
    }

}

//MARK: - UITableViewDelegate

extension AboutVC: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 5
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//        view.backgroundColor = .clear
//        return view
//    }
    
}

//MARK: - UITableViewDataSource

extension AboutVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SimpleButtonCell, for: indexPath) as! SimpleButtonCell
        switch indexPath.row {
        case 0:
            cell.configure(title: "how it works", systemImage: "info.circle") {
                self.howItWorksButtonPressed()
            }
        case 1:
            cell.configure(title: "faq", systemImage: "questionmark.bubble") {
                self.faqButtonPressed()
            }
        case 2:
            cell.configure(title: "invite your friends", systemImage: "square.and.arrow.up") {
                self.shareButtonPressed()
            }
        case 3:
            cell.configure(title: "text us", systemImage: "message") {
                self.contactButtonPressed()
            }
        case 4:
            cell.configure(title: "rate", systemImage: "star") {
                self.rateButtonPressed()
            }
        case 5:
            cell.configure(title: "give feedback", systemImage: "hand.wave") {
                self.feedbackButtonPressed()
            }
        default:
            fatalError()
        }
        return cell
    }
    
}
