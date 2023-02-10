//
//  ViewCompatibilityVC.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/02/09.
//

import UIKit

class ViewCompatibilityVC: UIViewController {
        
    //MARK: - Properties
    
    //UI
    @IBOutlet var tableView: UITableView!
        
    //Info
    var matchInfo: MatchInfo!

    //MARK: - Initialization
    
    class func create(matchInfo: MatchInfo) -> ViewCompatibilityVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Connect, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.ViewCompatibility) as! ViewCompatibilityVC
        vc.matchInfo = matchInfo
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView() //must come after setting up connectManager
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

        //the below was giving me issues for some reason
        tableView.register(UINib(nibName: Constants.SBID.Cell.ConnectTitleCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.ConnectTitleCell)
        tableView.register(UINib(nibName: Constants.SBID.Cell.ConnectSpectrumCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.ConnectSpectrumCell)
        tableView.register(UINib(nibName: Constants.SBID.Cell.ConnectInterestsCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.ConnectInterestsCell)
    }
}

//MARK: - UITableViewDelegate

extension ViewCompatibilityVC: UITableViewDelegate {
    
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

extension ViewCompatibilityVC: UITableViewDataSource {
    
    var hasTextSimilarities: Bool {
        matchInfo.textSimilarities.count > 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return hasTextSimilarities ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return hasTextSimilarities ? 1 : matchInfo.numericalSimilarities.count
        case 2:
            return matchInfo.numericalSimilarities.count
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.ConnectTitleCell, for: indexPath) as! ConnectTitleCell
            cell.configure(name: matchInfo.partnerName, compatibility: matchInfo.compatibility)
            return cell
        case 1:
            if hasTextSimilarities {
                return createConnectInterestsCell(at: indexPath)
            } else {
                return createConnectSpectrumCell(at: indexPath)
            }
        case 2:
            return createConnectSpectrumCell(at: indexPath)
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
    
    func createConnectInterestsCell(at indexPath: IndexPath) -> ConnectInterestsCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.ConnectInterestsCell, for: indexPath) as! ConnectInterestsCell
        cell.configure(matchInfo.textSimilarities)
        return cell
    }
    
}
