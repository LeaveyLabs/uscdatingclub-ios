//
//  SelectionTestCell.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/07.
//

import UIKit

protocol SelectionTestCellDelegate {
    func didSelect(questionId: Int, testAnswer: String)
    func didSelectMultipleSelection(questionId: Int, testAnswer: String, alreadySelected: Bool)
}

protocol SelectionUserCellDelegate {
    func didSelect(userId: Int, alreadySelected: Bool)
}

class SelectionTestCell: UITableViewCell {

    //MARK: - Properties

    //UI
//    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    var testAnswer: String!
    var testQuestion: Question!
    var cellDelegate: SelectionTestCellDelegate?
    
    var user: ReadOnlyUser?
    var userDelegate: SelectionUserCellDelegate?

    var isCurrentlySelected: Bool!
    
    //MARK: - Initializer
    
    //Resposne is an int between 1 and 5
    func configure(testQuestion: Question,
                   testAnswer: String,
                   delegate: SelectionTestCellDelegate,
                   isCurrentlySelected: Bool,
                   isLastCell: Bool = false) {
        self.testQuestion = testQuestion
        self.testAnswer = testAnswer
        self.isCurrentlySelected = isCurrentlySelected
        cellDelegate = delegate
        selectionStyle = .none
        backgroundColor = .clear
        
        titleButton.setTitle(testAnswer, for: .normal)
        titleButton.setTitleColor(isCurrentlySelected ? .testGreen : .customWhite, for: .normal)
        titleButton.tintColor = isCurrentlySelected ? .testGreen : .customWhite
        
        if testQuestion.isMultipleAnswer {
            titleButton.setImage(UIImage(systemName: isCurrentlySelected ? "square.fill" : "square"), for: .normal)
        } else {
            titleButton.setImage(UIImage(systemName: isCurrentlySelected ? "circle.fill" : "circle"), for: .normal)
        }
        bottomConstraint.constant = isLastCell ? 40 : 5
    }
    
    func configure(user: ReadOnlyUser,
                   delegate: SelectionUserCellDelegate,
                   isCurrentlySelected: Bool) {
        self.user = user
        self.isCurrentlySelected = isCurrentlySelected
        userDelegate = delegate
        selectionStyle = .none
        backgroundColor = .clear
        titleButton.setTitle(user.firstName + " " + user.lastName, for: .normal)
        titleButton.setTitleColor(isCurrentlySelected ? .testGreen : .customWhite, for: .normal)
        titleButton.tintColor = isCurrentlySelected ? .testGreen : .customWhite
        titleButton.setImage(UIImage(systemName: isCurrentlySelected ? "square.fill" : "square"), for: .normal)
    }
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func circleButtonDidTapped(_ sender: UIButton) {
        if user != nil {
            handleUserTap()
        } else {
            handleTestTap()
        }
    }
    
    func handleTestTap() {
        if testQuestion.isMultipleAnswer {
            cellDelegate!.didSelectMultipleSelection(questionId: testQuestion.id, testAnswer: testAnswer, alreadySelected: isCurrentlySelected)
        } else {
            cellDelegate!.didSelect(questionId: testQuestion.id, testAnswer: testAnswer)
        }
    }
    
    func handleUserTap() {
        userDelegate?.didSelect(userId: user!.id, alreadySelected: isCurrentlySelected)
    }
    
}
