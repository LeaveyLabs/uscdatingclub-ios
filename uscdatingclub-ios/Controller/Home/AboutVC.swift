//
//  AboutVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2022/12/28.
//

import UIKit

class AboutVC: UIViewController, PageVCChild {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var radarButton: UIButton!
    var pageVCDelegate: PageVCDelegate!
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet var tableView: UITableView!


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
        versionLabel.font = AppFont.bold.size(12)
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

        tableView.register(UINib(nibName: Constants.SBID.Cell.SimpleButtonCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SimpleButtonCell)
    }
    
    func setupButtons() {
        radarButton.addAction(.init(handler: { [self] _ in
            pageVCDelegate.didPressForwardButton()
        }), for: .touchUpInside)
    }
    
    //MARK: - Interaction
    
    @objc func howItWorksButtonPressed() {
        let howItWorksVC = HowItWorksVC.create()
        present(howItWorksVC, animated: true)
    }
    
    @objc func faqButtonPressed() {
        openURL(Constants.faqLink)
    }
    
    @objc func shareButtonPressed() {
        presentShareAppActivity()
    }
    
    @objc func rateButtonPressed() {
        AppStoreReviewManager.offerViewPromptUponUserRequest()
    }
    
    @objc func feedbackButtonPressed() {
        openURL(Constants.feedbackLink)
    }
    
    @objc func contactButtonPressed() {
        openMailtoURL(Constants.contactLink)
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
        return 6
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
            cell.configure(title: "share", systemImage: "square.and.arrow.up") {
                self.shareButtonPressed()
            }
        case 3:
            cell.configure(title: "rate", systemImage: "star") {
                self.rateButtonPressed()
            }
        case 4:
            cell.configure(title: "give feedback", systemImage: "message") {
                self.feedbackButtonPressed()
            }
        case 5:
            cell.configure(title: "contact us", systemImage: "hand.wave") {
                self.contactButtonPressed()
            }
        default:
            fatalError()
        }
        return cell
    }
    
}
