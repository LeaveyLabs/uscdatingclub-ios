//
//  SelectionTestCell.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/07.
//

import UIKit

protocol SelectionTestCellDelegate {
    func didSelect(questionId: Int, testAnswer: String)
}

class SelectionTestCell: UITableViewCell {

    //MARK: - Properties

    //UI
//    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    var testAnswer: String!
    var testQuestion: SelectionTestQuestion!
    var cellDelegate: SelectionTestCellDelegate!
    
    //MARK: - Initializer
    
    //Resposne is an int between 1 and 5
    func configure(testQuestion: SelectionTestQuestion,
                   testAnswer: String,
                   delegate: SelectionTestCellDelegate,
                   isCurrentlySelected: Bool,
                   isLastCell: Bool = false) {
        self.testQuestion = testQuestion
        self.testAnswer = testAnswer
        cellDelegate = delegate
        selectionStyle = .none
        backgroundColor = .clear
        
        titleButton.setTitle(testAnswer, for: .normal)
        titleButton.setTitleColor(isCurrentlySelected ? .testGreen : .customWhite, for: .normal)
        titleButton.tintColor = isCurrentlySelected ? .testGreen : .customWhite
        titleButton.setImage(UIImage(systemName: isCurrentlySelected ? "circle.fill" : "circle"), for: .normal)
//        bottomLineView.isHidden =
        if isLastCell {
        
        }
        bottomConstraint.constant = isLastCell ? 40 : 5
        
    }
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func circleButtonDidTapped(_ sender: UIButton) {
        cellDelegate.didSelect(questionId: testQuestion.id, testAnswer: testAnswer)
    }
    
}
