//
//  TestQuestionsVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/03.
//

import UIKit

class TestQuestionsVC: UIViewController {

    //MARK: - Properties
    //UI
    @IBOutlet var tableView: UITableView!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Initialization
    
    class func create() -> TestQuestionsVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.TestQuestions) as! TestQuestionsVC
        return vc
    }
    
}
