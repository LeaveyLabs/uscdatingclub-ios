//
//  CompatibilityTestSpectrumCell.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/02.
//

import UIKit

protocol SpectrumTestCellDelegate {
    func buttonDidTapped(questionId: Int, selection: Int)
}

class SpectrumTestCell: UITableViewCell {

    //MARK: - Properties

    //UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    @IBOutlet weak var circle1Button: UIButton!
    @IBOutlet weak var circle2Button: UIButton!
    @IBOutlet weak var circle3Button: UIButton!
    @IBOutlet weak var circle4Button: UIButton!
    @IBOutlet weak var circle5Button: UIButton!
    
    var circleButtons: [UIButton] {
        [circle1Button, circle2Button, circle3Button, circle4Button, circle5Button]
    }
    
    var testQuestion: TestQuestion!
    var cellDelegate: SpectrumTestCellDelegate!

    
    //MARK: - Initializer
    
    //Resposne is an int between 1 and 5
    func configure(testQuestion: TestQuestion, response: Int?,  delegate: SpectrumTestCellDelegate) {
        titleLabel.text = testQuestion.title
        leftLabel.text = testQuestion.lowPhrase
        rightLabel.text = testQuestion.highPhrase
        selectionStyle = .none
        backgroundColor = .clear
        
        cellDelegate = delegate
        
        for i in 1...circleButtons.count {
            circleButtons[i-1].tag = i
            circleButtons[i-1].becomeRound()
            circleButtons[i-1].layer.borderColor = UIColor.customWhite.cgColor
            circleButtons[i-1].layer.borderWidth = 2
            setButton(circleButtons[i-1], selected: false)
        }
        
        self.testQuestion = testQuestion
        
        if let response {
            setButton(circleButtons[response-1], selected: true)
        }
    }
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func circleButtonDidTapped(_ sender: UIButton) {
        for button in circleButtons {
            setButton(button, selected: false)
        }
        setButton(circleButtons[sender.tag-1], selected: true)
        cellDelegate.buttonDidTapped(questionId: testQuestion.id, selection: sender.tag)
    }
    
    //MARK: - Helper
    
    func setButton(_ button: UIButton, selected: Bool) {
        button.backgroundColor = selected ? .customWhite : .primaryColor
    }
    
}
