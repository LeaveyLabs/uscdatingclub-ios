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
    
    var didAnswerAllQuestionsOnPage: Bool {
        for question in questions {
            if TestContext.testResponses[question.id] == nil {
                return false
            }
        }
        return true
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
        rerenderNextButton()
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
    
    func rerenderNextButton() {
        nextButton.alpha = didAnswerAllQuestionsOnPage ? 1 : 0.5
//        nextButton.isUserInteractionEnabled = didAnswerAllQuestionsOnPage
    }
    
    //MARK: - Interaciton
    
    @objc func didTapNextButton() {
        guard didAnswerAllQuestionsOnPage else {
            AlertManager.displayError("respond to all questions to move on", "")
            return
        }
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
        rerenderNextButton()
    }
    
    //if there are no more selected testResponses after this one,
    //ensure the contentOffset
    func scrollDownIfNecessary(prevQuestionId: Int) {
        guard
            let prevQuestionIndex = questions.firstIndex(where: { $0.id == prevQuestionId }),
            prevQuestionIndex+1 < questions.count
        else { //they are answering the last question. move to bottom
            tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: tableView.verticalOffsetForBottom), animated: true)
            return
        }
        
        guard
            TestContext.testResponses[prevQuestionId+1] == nil
        else { return }  //they went back to answer an earlier question. do nothing
        
        let questionIndex = prevQuestionIndex + 1
        let questionBottomYWithinFeed = tableView.rectForRow(at: IndexPath(row: questionIndex, section: 0))
        let questionBottomY = tableView.convert(questionBottomYWithinFeed, to: view).maxY

        let totalHeight = view.bounds.height + view.safeAreaInsets.top + view.safeAreaInsets.bottom
        let desiredOffset = questionBottomY - totalHeight/2
        print(totalHeight/2, questionBottomY, desiredOffset)

        if desiredOffset < 50 { return } //don't go in wrong direction, and don't scroll if a small amount
        
        let willWeBeAtBottom = desiredOffset + tableView.contentOffset.y > tableView.verticalOffsetForBottom
        if willWeBeAtBottom {
            tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: tableView.verticalOffsetForBottom), animated: true)
        } else {
            tableView.setContentOffset(tableView.contentOffset.applying(.init(translationX: 0, y: desiredOffset)), animated: true)

        }
    }
    
}
