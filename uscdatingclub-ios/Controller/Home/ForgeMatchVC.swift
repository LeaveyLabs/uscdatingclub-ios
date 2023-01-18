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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
    }
    
    func setupTableView() {
        
    }
    
    func setupUI() {
        titleLabel.text = "play cupid"
        titleLabel.font = AppFont.bold.size(15)
        forgeButton.configure(title: "shoot", systemImage: "")
    }

}
