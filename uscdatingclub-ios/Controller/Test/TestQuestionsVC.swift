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
    
    var lastNonAnsweredQuestionIndex: Int {
        questions.firstIndex(where: { TestContext.testResponses[$0.id] == nil }) ?? questions.count
    }
    var manuallyOpenedSelectionQuestionIndex: Int? = nil
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        tableView.register(UINib(nibName: Constants.SBID.Cell.SelectionCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SelectionCell)
        tableView.register(UINib(nibName: Constants.SBID.Cell.SelectionHeaderCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SelectionHeaderCell)
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let selectionQuestion = questions[section] as? SelectionTestQuestion {
            if lastNonAnsweredQuestionIndex == section {
                return 1 + selectionQuestion.options.count
            } else if let manuallyOpenedSelectionQuestionIndex, manuallyOpenedSelectionQuestionIndex == section {
                return 1 + selectionQuestion.options.count
            } else {
                //if it's answered, return 1+ the number answered?
                
                return 1
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let question = questions[indexPath.section]
        if let spectrumQuestion = question as? SpectrumTestQuestion {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SpectrumTestCell, for: indexPath) as! SpectrumTestCell
            cell.configure(testQuestion: spectrumQuestion,
                           response: TestContext.testResponses[spectrumQuestion.id] as? Int,
                           delegate: self,
                           shouldBeHighlighted: lastNonAnsweredQuestionIndex == indexPath.section,
                           isLastCell: indexPath.section == questions.count - 1,
                           isFirstCell: indexPath.section == 0)
            return cell
        } else if let selectionQuestion = question as? SelectionTestQuestion {
            if indexPath.row == 0 {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SelectionHeaderCell, for: indexPath) as! SelectionHeaderTestCell
                cell.configure(testQuestion: selectionQuestion,
                               delegate: self,
                               shouldBeOpened: lastNonAnsweredQuestionIndex == indexPath.section || manuallyOpenedSelectionQuestionIndex == indexPath.section,
                               isAnswered: TestContext.testResponses[question.id] != nil,
                               isLastCell: indexPath.section == questions.count - 1,
                               isFirstCell: indexPath.section == 0)
                return cell
            } else {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SelectionCell, for: indexPath) as! SelectionTestCell
                let option = selectionQuestion.options[indexPath.row-1]
                cell.configure(testQuestion: selectionQuestion,
                               testAnswer: option,
                               delegate: self,
                               isCurrentlySelected: TestContext.testResponses[question.id] as? String == option,
                               isLastCell: indexPath.row == selectionQuestion.options.count)
                return cell
            }
        } else {
            fatalError()
        }
    }
    
}

extension TestQuestionsVC: SelectionHeaderTestCellDelegate {
    
    func toggleButtonDidTapped(questionId: Int) {
        if manuallyOpenedSelectionQuestionIndex != nil {
            manuallyOpenedSelectionQuestionIndex = nil
        } else {
            manuallyOpenedSelectionQuestionIndex = questions.firstIndex(where: { $0.id == questionId})
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.scrollDownIfNecessary(questionId: questionId)
            }
        }
        tableView.reloadData()
    }
    
}

extension TestQuestionsVC: SelectionTestCellDelegate {
    
    func didSelect(questionId: Int, testAnswer: String) {
        TestContext.testResponses[questionId] = testAnswer
        rerenderNextButton()
        
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { //wait for tableView to reload
            self.scrollDownIfNecessary(prevQuestionId: questionId)
        }
    }
    
}

extension TestQuestionsVC: SpectrumTestCellDelegate {
    
    func buttonDidTapped(questionId: Int, selection: Int) {
        TestContext.testResponses[questionId] = selection
        scrollDownIfNecessary(prevQuestionId: questionId)
        rerenderNextButton()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //code duplicated in two functions below... oh well, fix later
    //needed two entry points, one for when going to next question, one for expanding the toggled seleciton question
    func scrollDownIfNecessary(questionId: Int, redo: Bool = false) {
        guard let questionIndex = questions.firstIndex(where:  { $0.id == questionId }),
              questionIndex < questions.count
        else {
            return
        }
        let questionBottomYWithinFeed = tableView.rectForRow(at: IndexPath(row: 0, section: questionIndex))
        let questionBottomY = tableView.convert(questionBottomYWithinFeed, to: view).maxY

        let totalHeight = view.bounds.height + view.safeAreaInsets.top + view.safeAreaInsets.bottom
        let desiredOffset = questionBottomY - totalHeight/2

        if desiredOffset < 50 { return } //don't go in wrong direction, and don't scroll if a small amount
        
        let willWeBeAtBottom = desiredOffset + tableView.contentOffset.y > tableView.verticalOffsetForBottom
        if willWeBeAtBottom {
            tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: tableView.verticalOffsetForBottom), animated: true)
        } else {
            tableView.setContentOffset(tableView.contentOffset.applying(.init(translationX: 0, y: desiredOffset)), animated: true)
        }
    }
    
    func scrollDownIfNecessary(prevQuestionId: Int, redo: Bool = false) {
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
        
        //when a selection question is appearing or disappearing, need a slight delay so that expanded UI's constraints can update
        let beforeQ = questions[questionIndex] as? SelectionTestQuestion
        let q = questions[questionIndex] as? SelectionTestQuestion
        if (beforeQ != nil || q != nil) && !redo {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.scrollDownIfNecessary(prevQuestionId: prevQuestionId, redo: true)
            }
            return
        }
                
        let questionBottomYWithinFeed = tableView.rectForRow(at: IndexPath(row: 0, section: questionIndex))
        let questionBottomY = tableView.convert(questionBottomYWithinFeed, to: view).maxY

        let totalHeight = view.bounds.height + view.safeAreaInsets.top + view.safeAreaInsets.bottom
        let desiredOffset = questionBottomY - totalHeight/2

        if desiredOffset < 50 { return } //don't go in wrong direction, and don't scroll if a small amount
        
        let willWeBeAtBottom = desiredOffset + tableView.contentOffset.y > tableView.verticalOffsetForBottom
        if willWeBeAtBottom {
            tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: tableView.verticalOffsetForBottom), animated: true)
        } else {
            tableView.setContentOffset(tableView.contentOffset.applying(.init(translationX: 0, y: desiredOffset)), animated: true)
        }
    }
    
}
