//
//  CompatibilityTestSpectrumCell.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/02.
//

import UIKit

protocol CompatibilityTestSpectrumCellDelegate {
    func buttonDidTapped(selection: Int)
}

class CompatibilityTestSpectrumCell: UITableViewCell {

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
    
    var cellDelegate: CompatibilityTestSpectrumCellDelegate!

    
    //MARK: - Initializer
    
    func configure(title: String, leftText: String, rightText: String, delegate: CompatibilityTestSpectrumCellDelegate) {
        titleLabel.text = title
        leftLabel.text = leftText
        rightLabel.text = rightText
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
        cellDelegate.buttonDidTapped(selection: sender.tag)
    }
    
}
