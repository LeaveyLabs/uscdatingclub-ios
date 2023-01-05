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
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var nextButton: SimpleButton!
    
    var testPage: TestPage!
    var questions: [TestQuestion] {
        return TestQuestions[testPage]!
    }
    
    //MARK: - Initialization
    
    class func create(page: TestPage) -> TestQuestionsVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.TestQuestions) as! TestQuestionsVC
        vc.testPage = page
        return vc
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupHeaderFooter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(TestContext.testResponses)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(TestContext.testResponses)
    }
    
    func setupHeaderFooter() {
        titleLabel.text = TestPageTitles[testPage]
        nextButton.configure(title: testPage == TestPages-1 ? "finish" : "next", systemImage: "")
        nextButton.internalButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none

        //the below was giving me issues for some reason
        tableView.register(UINib(nibName: Constants.SBID.Cell.SpectrumTestCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SpectrumTestCell)
    }
    
    //MARK: - Interaciton
    
    @objc func didTapNextButton() {
        if testPage == TestPages-1 {
            navigationController?.pushViewController(TestTextVC.create(type: .submitting), animated: true)
        } else {
            navigationController?.pushViewController(TestQuestionsVC.create(page: testPage+1), animated: true)
        }
    }
    
    @IBAction func didTapBack() {
        navigationController?.popViewController(animated: true)
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
        let question = questions[indexPath.row]        
        cell.configure(testQuestion: question, response: TestContext.testResponses[question.id], delegate: self)
        return cell
    }
    
}

extension TestQuestionsVC: SpectrumTestCellDelegate {
    
    func buttonDidTapped(questionId: Int, selection: Int) {
        TestContext.testResponses[questionId] = selection
        scrollDownIfNecessary(prevQuestionId: questionId)
    }
    
    
    //if there are no more selected testResponses after this one,
    //ensure the contentOffset
    func scrollDownIfNecessary(prevQuestionId: Int) {
        
//        guard
            let prevQuestionIndex = questions.firstIndex(where: { $0.id == prevQuestionId })!
            print(prevQuestionIndex+1 < questions.count)
            print(TestContext.testResponses[prevQuestionId+1] == nil) //TODO: this might not work properly
//        else { return }
        let questionIndex = prevQuestionIndex + 1
        
        let questionBottomYWithinFeed = tableView.rectForRow(at: IndexPath(row: questionIndex, section: 0))
        let questionBottomY = tableView.convert(questionBottomYWithinFeed, to: view).maxY

        let desiredOffset = tableView.bounds.height - questionBottomY
        print(tableView.bounds.height, questionBottomY)

        if desiredOffset < 0 { return }  //dont scroll up for the very first post
        
        tableView.setContentOffset(tableView.contentOffset.applying(.init(translationX: 0, y: desiredOffset)), animated: true)
    }
    
}
