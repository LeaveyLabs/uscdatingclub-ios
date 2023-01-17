//
//  AccountVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2022/12/28.
//

import UIKit

class AccountVC: UIViewController, PageVCChild {
    
    //MARK: - Properties
    //UI
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var radarButton: UIButton!
    var pageVCDelegate: PageVCDelegate!
    


    //MARK: - Initialization
    
    class func create(delegate: PageVCDelegate) -> AccountVC {
        let accountVC = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.Account) as! AccountVC
        accountVC.pageVCDelegate = delegate
        return accountVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupLabels()
        setupTableView()
    }
    
    //MARK: - Setup
    
    func setupLabels() {
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
        tableView.delaysContentTouches = false //for responsive button highlight

        tableView.register(UINib(nibName: Constants.SBID.Cell.SimpleTitleCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SimpleTitleCell)
        tableView.register(UINib(nibName: Constants.SBID.Cell.SimpleButtonCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SimpleButtonCell)
    }
    
    func setupButtons() {
        radarButton.addAction(.init(handler: { [self] _ in
            pageVCDelegate.didPressBackwardButton()
        }), for: .touchUpInside)
    }
    
    //MARK: - Interaction
    
    @objc func retakeTestButtonDidPressed() {
        presentTest()
    }

    @objc func editAccountButtonDidPressed() {
        let nav = UINavigationController(rootViewController: EditAccountVC.create())
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    //MARK: - Helpers
    
    func presentTest() {
        let nav = UINavigationController(rootViewController: TestTextVC.create(type: .welcome))
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
}

extension AccountVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}

extension AccountVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SimpleTitleCell, for: indexPath) as! SimpleTitleCell
            cell.configure(title: UserService.singleton.getFirstLastName())
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SimpleButtonCell, for: indexPath) as! SimpleButtonCell
            switch indexPath.row {
            case 0:
                cell.configure(title: "edit account", systemImage: "gearshape") {
                    self.editAccountButtonDidPressed()
                }
            case 1:
                cell.configure(title: "retake the\ncompatibility test", systemImage: "testtube.2", footerText: nil) {
                    self.retakeTestButtonDidPressed()
                }
            default:
                fatalError()
            }
            return cell
        default:
            fatalError()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : (UserService.singleton.getSurveyResponses().isEmpty ? 1 : 2) //don't display "retake test" button if they haven't taken the test
    }
    
}
