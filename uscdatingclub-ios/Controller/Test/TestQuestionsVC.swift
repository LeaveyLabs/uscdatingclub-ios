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
    
    var questions: [TestQuestion] {
        return Array(TestQuestions.values)
    }
    
    //MARK: - Initialization
    
    class func create() -> TestQuestionsVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.TestQuestions) as! TestQuestionsVC
        return vc
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        //the below was giving me issues for some reason
        tableView.register(UINib(nibName: Constants.SBID.Cell.SpectrumTestCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SpectrumTestCell)
    }
    
}

//MARK: - UITableViewDelegate

extension TestQuestionsVC: UITableViewDelegate {
    
}

//MARK: - UITableViewDataSource

extension TestQuestionsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SpectrumTestCell, for: indexPath) as! SpectrumTestCell
        let index = indexPath.row
        cell.configure(testQuestion: questions[index], delegate: self)
        return cell
    }
    
}

extension TestQuestionsVC: SpectrumTestCellDelegate {
    
    func buttonDidTapped(questionId: Int, selection: Int) {
        TestContext.testResponses[selection] = questionId
    }
    
}
