//
//  ForgeMatchVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/17.
//

import UIKit

class ForgeMatchVC: UIViewController {
    
    @IBOutlet var forgeButton: SimpleButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    var users: [ReadOnlyUser] = []
    var selectedIds: Set<Int> = []

    //MARK: - Initialization
    
    class func create() -> ForgeMatchVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.ForgeMatch) as! ForgeMatchVC
        return vc
    }
    
    //MARK: - Lifestyle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
        
    }
    
    //MARK: - TableView
    
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

        tableView.register(UINib(nibName: Constants.SBID.Cell.SelectionCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SelectionCell)
    }
    
    func setupUI() {
        titleLabel.text = "play cupid"
        titleLabel.font = AppFont.bold.size(15)
        forgeButton.configure(title: "shoot", systemImage: "")
    }
    
    //MARK: - Interaction
    
    func sendButtonPressed() {
        Task {
            do {
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    AlertManager.displayError(error)
                }
            }
            
        }
    }

}

extension ForgeMatchVC: UITableViewDelegate {
    
}

extension ForgeMatchVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SelectionCell, for: indexPath) as! SelectionTestCell
        let user = users[indexPath.row]
        let isCurrentlySelected = selectedIds.contains(user.id)
        cell.configure(user: user, delegate: self, isCurrentlySelected: isCurrentlySelected)
        return cell
    }
    
}

extension ForgeMatchVC: SelectionUserCellDelegate {
    
    func didSelect(userId: Int, alreadySelected: Bool) {
        if selectedIds.contains(userId) {
            selectedIds.remove(userId)
        } else {
            selectedIds.insert(userId)
        }
    }
    
}
