//
//  SimpleTitleCell.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/01/11.
//

import UIKit

class SimpleTitleCell: UITableViewCell {

    @IBOutlet var theLabel: UILabel!
    
    func configure(title: String) {
        theLabel.text = title
        theLabel.font = AppFont.bold.size(40)
        contentView.backgroundColor = .clear
        theLabel.textColor = .customWhite
        selectionStyle = .none
    }
    
}
