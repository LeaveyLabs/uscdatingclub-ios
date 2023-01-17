//
//  SelectionTableViewCell.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/17.
//

import UIKit

class SelectionTableViewCell: UITableViewCell {

    //MARK: - Properies
    
    var question: Question!
    var delegate: SelectionTestCellDelegate!
    var timerForShowScrollIndicator: Timer?
    @IBOutlet var bottomLineView: UIView!
    
    //UI
    @IBOutlet var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        startTimerForShowScrollIndicator()
        setupTableView()
    }
    
    //Resposne is an int between 1 and 5
    func configure(testQuestion: Question,
                   delegate: SelectionTestCellDelegate,
                   isLastCell: Bool = false,
                   isFirstCell: Bool = false) {
        guard let choices = testQuestion.textAnswerChoices, choices.count > 0 else {
            return
        }
        selectionStyle = .none
        backgroundColor = .clear
        self.delegate = delegate
        self.question = testQuestion
        bottomLineView.isHidden = isLastCell
        
        tableView.reloadData()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: Constants.SBID.Cell.SelectionCell, bundle: nil), forCellReuseIdentifier: Constants.SBID.Cell.SelectionCell)
        tableView.flashScrollIndicators()
        tableView.indicatorStyle = .white
    }
    
    //MARK: - Scroll indicator insets always visible
    
    /// Show always scroll indicator in table view
    @objc func showScrollIndicatorsInContacts() {
        UIView.animate(withDuration: 0.001) {
            self.tableView.flashScrollIndicators()
        }
    }

    /// Start timer for always show scroll indicator in table view
    func startTimerForShowScrollIndicator() {
        self.timerForShowScrollIndicator = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.showScrollIndicatorsInContacts), userInfo: nil, repeats: true)
    }

    /// Stop timer for always show scroll indicator in table view
    func stopTimerForShowScrollIndicator() {
        self.timerForShowScrollIndicator?.invalidate()
        self.timerForShowScrollIndicator = nil
    }

}

extension SelectionTableViewCell: UITableViewDelegate {
    
}

extension SelectionTableViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        question.textAnswerChoices!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SBID.Cell.SelectionCell, for: indexPath) as! SelectionTestCell
        let option = question.textAnswerChoices![indexPath.row]
        let isCurrentlySelected = TestService.shared.currentResponsesFor(question).contains(SurveyResponse(questionId: question.id, answer: option))
        cell.configure(testQuestion: question,
                       testAnswer: option,
                       delegate: delegate,
                       isCurrentlySelected: isCurrentlySelected,
                       isLastCell: indexPath.row == question.textAnswerChoices!.count)
        return cell
    }
    
}
