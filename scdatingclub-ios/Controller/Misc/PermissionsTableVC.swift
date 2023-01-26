//
//  PermissionsTableVC.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/01/12.
//

import UIKit

class PermissionsTableVC: UIViewController {

    //MARK: - Properties
    //UI
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var learnMoreButton: UIButton!
    
    //Info
    var isLocationEnabled: Bool = false
    var isNotificationsEnabled: Bool = false
    var isBackgroundRefreshEnabled: Bool = false

    //State
    var goodToGo: Bool {
        return false
    }
    
    //MARK: - Initialization
    
    class func create() -> PermissionsTableVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Misc, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.PermissionsTable) as! PermissionsTableVC
        return vc
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = AppFont.bold.size(30)
        setupTableView()

        NotificationCenter.default.addObserver(self, selector: #selector(delayedRerender), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(delayedRerender), name: .locationStatusDidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(delayedRerender), name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Setup
    
    func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorStyle = .none

        //the below was giving me issues for some reason
        tableView.register(UINib(nibName: Constants.SBID.Cell.PermissionsCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.PermissionsCell)
    }
    
    func setupButtons() {
        learnMoreButton.addTarget(self, action: #selector(learnMoreButtonPressed), for: .touchUpInside)
        learnMoreButton.setTitleColor(.customWhite.withAlphaComponent(0.7), for: .normal)
    }
    
    //MARK: - Helpers
    
    @objc func delayedRerender() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            rerender()
        }
    }
    
    func rerender() {
        Task {
            await recalculateArePermissionsGranted()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [self] in
                    if goodToGo {
                        LocationManager.shared.startLocationServices()
                        finish()
                    }
                }
            }
        }
    }
    
    func finish() {
        if let _ = parent as? UINavigationController {
            transitionToStoryboard(storyboardID: Constants.SBID.SB.Main, duration: 0.5)
        } else {
            dismiss(animated: true)
        }
    }
    
    func recalculateArePermissionsGranted() async {
        isLocationEnabled = LocationManager.shared.isLocationServicesProperlyAuthorized()
        isNotificationsEnabled = await NotificationsManager.shared.isNotificationsEnabled()
        isBackgroundRefreshEnabled = UIApplication.shared.backgroundRefreshStatus == .available || ProcessInfo.processInfo.isLowPowerModeEnabled
    }
    
    //MARK: - Interaction
    
    @objc func learnMoreButtonPressed() {
        openURL(Constants.faqLink)
    }
    
    @objc func locationButtonDidTapped() {
        do {
            try LocationManager.shared.requestPermissionServices()
        } catch {
            AlertManager.showSettingsAlertController(title: "open settings to share location", message: "precise, always", settingsType: .location, on: self)
        }
    }
    
    @objc func notificationsButtonDidTapped() {
        NotificationsManager.shared.askForNewNotificationPermissionsIfNecessary { granted in
            DispatchQueue.main.async { [self] in
                if !granted {
                    AlertManager.showSettingsAlertController(title: "open settings to turn on notifications", message: "", settingsType: .notifications, on: self)
                } else {
                    rerender()
                }
            }
        }
    }
    
    @objc func backgroundRefreshButtonDidTapped() {
        if UIApplication.shared.backgroundRefreshStatus != .available && !ProcessInfo.processInfo.isLowPowerModeEnabled {
            AlertManager.showSettingsAlertController(title: "turn on background app refresh in settings", message: "", settingsType: .backgroundRefresh, on: SceneDelegate.visibleViewController!)
        }
    }

}

extension PermissionsTableVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return view.bounds.height / 5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
}

extension PermissionsTableVC: UITableViewDataSource {
        
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.PermissionsCell, for: indexPath) as! PermissionsCell
        switch indexPath.section {
        case 0:
            cell.configure(type: .location, isPermissionsGranted: isLocationEnabled, onPress: locationButtonDidTapped)
        case 1:
            cell.configure(type: .refresh, isPermissionsGranted: isBackgroundRefreshEnabled, onPress: backgroundRefreshButtonDidTapped)
        case 2:
            cell.configure(type: .notifications, isPermissionsGranted: isNotificationsEnabled, onPress: notificationsButtonDidTapped)
        default:
            fatalError()
        }
        return cell
    }
}
