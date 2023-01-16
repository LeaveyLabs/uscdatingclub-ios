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
    
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    
    @IBOutlet weak var circle1Button: UIButton!
    @IBOutlet weak var circle2Button: UIButton!
    @IBOutlet weak var circle3Button: UIButton!
    @IBOutlet weak var circle4Button: UIButton!
    @IBOutlet weak var circle5Button: UIButton!
    @IBOutlet weak var circle6Button: UIButton!
    @IBOutlet weak var circle7Button: UIButton!

    var circleButtons: [UIButton] {
        [circle1Button, circle2Button, circle3Button, circle4Button, circle5Button, circle6Button, circle7Button]
    }
    
    var testQuestion: Question!
    var cellDelegate: SpectrumTestCellDelegate!

    
    //MARK: - Initializer
    
    //Resposne is an int between 1 and 5
    func configure(testQuestion: Question,
                   response: Int?,
                   delegate: SpectrumTestCellDelegate,
                   shouldBeHighlighted: Bool,
                   isLastCell: Bool = false,
                   isFirstCell: Bool = false) {
        titleLabel.font = AppFont2.medium.size(22)
        rightLabel.font = AppFont2.medium.size(15)
        leftLabel.font = AppFont2.medium.size(15)

        titleLabel.text = testQuestion.prompt
        leftLabel.text = "disagree"
        leftLabel.textColor = .testPurple
        rightLabel.textColor = .testGreen
        rightLabel.text = "agree"
        selectionStyle = .none
        backgroundColor = .clear
        
        if isLastCell {
            bottomLineView.isHidden = true
        }
        if isFirstCell {
            topLineView.isHidden = true
        }
        
        cellDelegate = delegate
        
        for i in 1...circleButtons.count {
            let button = circleButtons[i-1]
            button.tag = i
            button.becomeRound()
            setButton(button, selected: false)
            button.layer.borderWidth = 2
            if button.tag <= 3 {
                button.layer.borderColor = UIColor.testPurple.cgColor
            } else if button.tag == 4 {
                button.layer.borderColor = UIColor.customWhite.withAlphaComponent(0.7).cgColor
            } else {
                button.layer.borderColor = UIColor.testGreen.cgColor
            }
        }
        
        self.testQuestion = testQuestion
        
        if let response {
            setButton(circleButtons[response-1], selected: true)
        }
        
        contentView.alpha = shouldBeHighlighted ? 1 : 0.2
        self.alpha = shouldBeHighlighted ? 1 : 0.7
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
        if button.tag <= 3 {
            button.backgroundColor = selected ? .testPurple : .clear
        } else if button.tag == 4 {
            button.backgroundColor = selected ? .customWhite.withAlphaComponent(0.7) : .clear
        } else {
            button.backgroundColor = selected ? .testGreen : .clear
        }
    }
    
}
