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
    
    func configure(testQuestion: TestQuestion, delegate: SpectrumTestCellDelegate) {
        titleLabel.text = testQuestion.title
        leftLabel.text = testQuestion.lowPhrase
        rightLabel.text = testQuestion.highPhrase
        selectionStyle = .none
        backgroundColor = .clear
        
        circle1Button.tag = 1
        circle2Button.tag = 2
        circle3Button.tag = 3
        circle4Button.tag = 4
        circle5Button.tag = 5
        
        cellDelegate = delegate
    }
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func circleButtonDidTapped(_ sender: UIButton) {
        for button in circleButtons {
            button.backgroundColor = .primaryColor
        }
        circleButtons[sender.tag-1].backgroundColor = .white
        cellDelegate.buttonDidTapped(questionId: testQuestion.id, selection: sender.tag)
    }
    
}
