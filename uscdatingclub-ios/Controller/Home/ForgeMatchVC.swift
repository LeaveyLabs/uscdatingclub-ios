//
//  ForgeMatchVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/17.
//

import UIKit

class ForgeMatchVC: UIViewController {
    
    @IBOutlet weak var searchBarTextField: UITextField!
    @IBOutlet var forgeButton: SimpleButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    var allUsers: [ReadOnlyUser] = []
    var filteredUsers: [ReadOnlyUser] = []
    var selectedIds: [Int] = [] {
        didSet {
            forgeButton.internalButton.isEnabled = selectedIds.count==2
        }
    }

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
        loadAllUsers()
        setupTextField()
    }
    
    func setupTextField() {
        searchBarTextField.delegate = self
        searchBarTextField.layer.cornerRadius = 10
        searchBarTextField.layer.cornerCurve = .continuous
    }
    
    func loadAllUsers() {
        Task {
            do {
                allUsers = try await UserAPI.fetchAllUsers()
                filteredUsers = allUsers
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                AlertManager.displayError(error)
            }
        }
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
        forgeButton.internalButton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    //MARK: - Interaction
    
    @objc func sendButtonPressed() {
        Task {
            do {
                try await MatchAPI.forceCreateMatch(user1Id: selectedIds.first!, user2Id: selectedIds.last!)
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

extension ForgeMatchVC: UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

//MARK: - UITextFieldDelegate

extension ForgeMatchVC: UITextFieldDelegate {
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        filterRecipients()
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
}

extension ForgeMatchVC {
    
    //MARK: - Helpers
    
    func filterRecipients() {
        let query = searchBarTextField.text!
        if query.isEmpty { filteredUsers = allUsers }
        else {
            filteredUsers = allUsers.filter( { ($0.firstName+$0.lastName).lowercased().contains(query.lowercased()) })
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension ForgeMatchVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SelectionCell, for: indexPath) as! SelectionTestCell
        let user = filteredUsers[indexPath.row]
        let isCurrentlySelected = selectedIds.contains(user.id)
        cell.configure(user: user, delegate: self, isCurrentlySelected: isCurrentlySelected)
        return cell
    }
    
}

extension ForgeMatchVC: SelectionUserCellDelegate {
    
    func didSelect(userId: Int, alreadySelected: Bool) {
        if selectedIds.contains(userId) {
            selectedIds.removeFirstAppearanceOf(object: userId)
        } else {
            if selectedIds.count < 2 {
                selectedIds.append(userId)
            }
        }
        tableView.reloadData()
    }
    
}
