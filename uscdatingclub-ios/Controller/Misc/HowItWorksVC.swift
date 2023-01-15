//
//  HowItWorksVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2022/12/29.
//

import UIKit

struct HowItWorksItem {
    let image: UIImage
    let title: String
    let description: String
}

class HowItWorksVC: UIViewController {
    
    @IBOutlet var gotItButton: SimpleButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!

    let coreFeatures: [HowItWorksItem] = [
        HowItWorksItem(image: UIImage(named: "test")!,
                       title: "take the compatibility test",
                       description: "we’ll calculate your compatibility with other usc students"),
        HowItWorksItem(image: UIImage(named: "pulse")!,
                       title: "keep your phone in your pocket",
                       description: "your phone will look for your next match"),
        HowItWorksItem(image: UIImage(named: "ring")!,
                       title: "get matched",
                       description: "you’ll both get a notification and have \(Constants.minutesToRespond) to respond")]
    
    //MARK: - Initialization
    
    class func create() -> HowItWorksVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Auth, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.HowItWorks) as! HowItWorksVC
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupTableView()
        titleLabel.font = AppFont.bold.size(30)
    }
    
    //MARK: - Setup
    
    func setupButtons() {
        gotItButton.internalButton.addTarget(self, action: #selector(gotItButtonDidTapped), for: .touchUpInside)
        gotItButton.configure(title: "got it", systemImage: "")
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        
        //the below was giving me issues for some reason
//        tableView.register(HowItWorksCell.self, forCellReuseIdentifier: Constants.SBID.Cell.HowItWorksCell)
        self.tableView.register(UINib(nibName: Constants.SBID.Cell.HowItWorksCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.HowItWorksCell)

    }
    
    //MARK: - Interaction
    
    @objc func gotItButtonDidTapped() {
        if let _ = parent as? UINavigationController {
//            let vc = PermissionsVC.create()
//            parent.pushViewController(vc, animated: true)
            dismiss(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

}

extension HowItWorksVC: UITableViewDelegate {
    
}

extension HowItWorksVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coreFeatures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.HowItWorksCell, for: indexPath) as! HowItWorksCell
        let featureIndex = indexPath.row
        cell.configure(title: coreFeatures[featureIndex].title,
                       description: coreFeatures[featureIndex].description,
                       image: coreFeatures[featureIndex].image)
        return cell
    }
    
}
