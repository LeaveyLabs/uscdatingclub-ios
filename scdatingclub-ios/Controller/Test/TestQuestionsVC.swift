//
//  TestQuestionsVC.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/01/03.
//

import UIKit

class TestQuestionsVC: UIViewController {
    
    //MARK: - Properties
    //UI
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    
    var manuallyOpenedSelectionQuestionIndex: Int? = nil
    var testPage: TestPage!
    
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
    
    //MARK: - Setup
    
    func setupHeaderFooter() {
        titleLabel.text = testPage.header
        titleLabel.font = AppFont.bold.size(20)
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
        tableView.register(UINib(nibName: Constants.SBID.Cell.SelectionTableViewCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SelectionTableViewCell)
        tableView.register(UINib(nibName: Constants.SBID.Cell.SelectionHeaderCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SelectionHeaderCell)
        tableView.register(UINib(nibName: Constants.SBID.Cell.SimpleButtonCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SimpleButtonCell)
    }
    
    //MARK: - Interaciton
    
    @objc func didTapNextButton() {
        guard TestService.shared.didAnswerAllQuestions(on: testPage) else { return }
        if let nextPage = TestService.shared.getNextPage(currentPage: testPage) {
            navigationController?.pushViewController(TestQuestionsVC.create(page: nextPage), animated: true)
        } else {
            navigationController?.pushViewController(TestTextVC.create(type: .submitting), animated: true)
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
        return testPage.questions.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < testPage.questions.count else { return 1 }
        let question = testPage.questions[section]
        if !question.isNumerical {
            if TestService.shared.firstNonAnsweredQuestion(on: testPage) == section {
                return 2 //header and tableViewCell
            } else if let manuallyOpenedSelectionQuestionIndex, manuallyOpenedSelectionQuestionIndex == section {
                return 2 //header and tableViewCell
            } else {
                return 1
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == testPage.questions.count {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SimpleButtonCell, for: indexPath) as! SimpleButtonCell
            cell.configure(title: TestService.shared.isLastPage(testPage) ? "finish" : "next", systemImage: "") {
                self.didTapNextButton()
            }
            cell.simpleButton.alpha = TestService.shared.didAnswerAllQuestions(on: testPage) ? 1 : 0.5
            return cell
        }
        let question = testPage.questions[indexPath.section]
        if question.isNumerical {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SpectrumTestCell, for: indexPath) as! SpectrumTestCell
            let currentResponse = TestService.shared.currentResponseFor(question)
            cell.configure(testQuestion: question,
                           response: currentResponse != nil ? Int(currentResponse!.answer) : nil,
                           delegate: self,
                           shouldBeHighlighted: TestService.shared.firstNonAnsweredQuestion(on: testPage) == indexPath.section,
                           isLastCell: indexPath.section == testPage.questions.count - 1,
                           isFirstCell: indexPath.section == 0)
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SelectionHeaderCell, for: indexPath) as! SelectionHeaderTestCell
                cell.configure(testQuestion: question,
                               delegate: self,
                               shouldBeOpened: TestService.shared.firstNonAnsweredQuestion(on: testPage) == indexPath.section || manuallyOpenedSelectionQuestionIndex == indexPath.section,
                               isAnswered: TestService.shared.hasAnswered(question),
                               isLastCell: indexPath.section == testPage.questions.count - 1,
                               isFirstCell: indexPath.section == 0)
                return cell
            } else {
                //TABLEVIEWCELL
                let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SelectionTableViewCell, for: indexPath) as! SelectionTableViewCell
                cell.configure(testQuestion: question, delegate: self)
                return cell
            }
        }
    }
    
}

//MARK: - SelectionHeaderTestCellDelegate

extension TestQuestionsVC: SelectionHeaderTestCellDelegate {
    
    func toggleButtonDidTapped(questionId: Int) {        
        if manuallyOpenedSelectionQuestionIndex == testPage.questions.firstIndex(where: { $0.id == questionId}) {
            manuallyOpenedSelectionQuestionIndex = nil
        } else {
            manuallyOpenedSelectionQuestionIndex = testPage.questions.firstIndex(where: { $0.id == questionId})
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.scrollDownIfNecessary(questionId: questionId)
            }
        }
        tableView.reloadData()
    }
    
}

//MARK: - SelectionTestCellDelegate

extension TestQuestionsVC: SelectionTestCellDelegate {
    
    func didSelect(questionId: Int, testAnswer: String) {
        manuallyOpenedSelectionQuestionIndex = testPage.questions.firstIndex(where: { $0.id == questionId }) //keep the question open so they know what they selected
        
        let newResponse = SurveyResponse(questionId: questionId, answer: testAnswer)
        TestService.shared.setResponse(newResponse)
        
        tableView.reloadData()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { //wait for tableView to reload
//            self.scrollDownIfNecessary(prevQuestionId: questionId)
//        }
    }
    
    func didSelectMultipleSelection(questionId: Int, testAnswer: String, alreadySelected: Bool) {
        manuallyOpenedSelectionQuestionIndex = testPage.questions.firstIndex(where: { $0.id == questionId }) //keep the question open so they can select multiple
        
        let newResponse = SurveyResponse(questionId: questionId, answer: testAnswer)
        TestService.shared.toggleResponse(newResponse)
        
        tableView.reloadData()
    }
    
}

//MARK: - SpectrumTestCellDelegate

extension TestQuestionsVC: SpectrumTestCellDelegate {
    
    func buttonDidTapped(questionId: Int, selection: Int) {
        manuallyOpenedSelectionQuestionIndex = nil
        
        let newResponse = SurveyResponse(questionId: questionId, answer: String(selection))
        TestService.shared.setResponse(newResponse)

        scrollDownIfNecessary(prevQuestionId: questionId)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //code duplicated in two functions below... oh well, fix later
    //needed two entry points, one for when going to next question, one for expanding the toggled seleciton question
    func scrollDownIfNecessary(questionId: Int, redo: Bool = false) {
        guard let questionIndex = testPage.questions.firstIndex(where:  { $0.id == questionId }),
              questionIndex < testPage.questions.count
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
            let prevQuestionIndex = testPage.questions.firstIndex(where: { $0.id == prevQuestionId }),
            prevQuestionIndex+1 < testPage.questions.count
        else { //they are answering the last question. move to bottom
            tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: tableView.verticalOffsetForBottom), animated: true)
            return
        }
        
        let questionIndex = prevQuestionIndex + 1
        let questionId = testPage.questions[questionIndex].id
        guard !TestService.shared.hasAnswered(questionId: questionId) else { return } //they went back to answer an earlier question. do nothing
        

        //when a selection question is appearing or disappearing, need a slight delay so that expanded UI's constraints can update
        let beforeQ = testPage.questions[questionIndex]
        let selectionQ = testPage.questions[questionIndex]
        if (beforeQ.isMultipleAnswer || selectionQ.isMultipleAnswer) && !redo {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.scrollDownIfNecessary(prevQuestionId: prevQuestionId, redo: true)
            }
            return
        }
                
        let questionBottomYWithinFeed = tableView.rectForRow(at: IndexPath(row: 0, section: questionIndex))
        let questionBottomY = tableView.convert(questionBottomYWithinFeed, to: view).maxY

        let totalHeight = view.bounds.height + view.safeAreaInsets.top + view.safeAreaInsets.bottom
        let desiredOffset: CGFloat
        if (selectionQ.isMultipleAnswer) {
            desiredOffset = questionBottomY - totalHeight/2.2
        } else {
            desiredOffset = questionBottomY - totalHeight/1.5
        }


        if desiredOffset < 50 { return } //don't go in wrong direction, and don't scroll if a small amount
        
        let willWeBeAtBottom = desiredOffset + tableView.contentOffset.y > tableView.verticalOffsetForBottom
        if willWeBeAtBottom {
            tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: tableView.verticalOffsetForBottom), animated: true)
        } else {
            tableView.setContentOffset(tableView.contentOffset.applying(.init(translationX: 0, y: desiredOffset)), animated: true)
        }
    }
    
}
