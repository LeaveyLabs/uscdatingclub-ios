//
//  ConnectTitleCell.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/01/10.
//

import UIKit

class ConnectTitleCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func configure(name: String, compatibility: Int) {
        titleLabel.font = AppFont.bold.size(80)
        subtitleLabel.font = AppFont.light.size(20)
        subtitleLabel.textColor = .customWhite.withAlphaComponent(0.7)
        
        let boldedText = "\(compatibility)% compatible"
        let fullText = "you and \(name) are \(compatibility)% compatible"
        let attributedText = NSMutableAttributedString(string: fullText)
        if let boldedRange = fullText.range(of: boldedText) {
            attributedText.setAttributes([.font: AppFont.bold.size(20), .foregroundColor: UIColor.customWhite], range: NSRange(boldedRange, in: fullText))
        }
        subtitleLabel.attributedText = attributedText
        titleLabel.text = name
    }
    
}
