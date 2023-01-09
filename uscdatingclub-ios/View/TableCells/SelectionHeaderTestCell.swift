//
//  SelectionHeaderTestCell.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/07.
//

import UIKit

protocol SelectionHeaderTestCellDelegate {
    func toggleButtonDidTapped(questionId: Int)
}

class SelectionHeaderTestCell: UITableViewCell {

    //MARK: - Properties

    //UI
    @IBOutlet weak var topLineView: UIView!
//    @IBOutlet weak var bottomLineView: UIView!
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    var testQuestion: SelectionTestQuestion!
    var cellDelegate: SelectionHeaderTestCellDelegate!
    var isOpen: Bool!
    
    //MARK: - Initializer
    
    //Resposne is an int between 1 and 5
    func configure(testQuestion: SelectionTestQuestion,
                   delegate: SelectionHeaderTestCellDelegate,
                   shouldBeOpened: Bool,
                   isAnswered: Bool,
                   isLastCell: Bool = false,
                   isFirstCell: Bool = false) {
        selectionStyle = .none
        backgroundColor = .clear
        self.isOpen = shouldBeOpened
        cellDelegate = delegate
        self.testQuestion = testQuestion
        
        if isLastCell {
//            bottomLineView.isHidden = true //having annoying constraint issues w this...
        }
        if isFirstCell {
            topLineView.isHidden = true
        }
        
        titleButton.setTitle(testQuestion.title, for: .normal)
        titleButton.setTitleColor(shouldBeOpened ? .customWhite : isAnswered ? .testGreen : .testPurple, for: .normal)
        titleButton.setImage(UIImage(systemName: shouldBeOpened ? "chevron.up" : "chevron.down"), for: .normal)
        titleButton.tintColor = shouldBeOpened ? .customWhite : isAnswered ? .testGreen : .testPurple
        contentView.alpha = shouldBeOpened ? 1 : 0.7
        
        bottomConstraint.constant = isOpen ? 10 : 40
    }
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func toggleButtonDidTapped(_ sender: UIButton) {
        cellDelegate.toggleButtonDidTapped(questionId: testQuestion.id)
    }
    
}
