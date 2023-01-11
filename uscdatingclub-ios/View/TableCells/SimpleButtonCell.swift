//
//  SimpleButtonCell.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/08.
//

import UIKit

class SimpleButtonCell: UITableViewCell {

    @IBOutlet weak var simpleButton: SimpleButton!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var buttonHeightAnchor: NSLayoutConstraint!
    
    func configure(title: String, systemImage: String, footerText: String? = nil, onButtonPress: @escaping () -> Void) {
        if title.rangeOfCharacter(from: .newlines) != nil {
            buttonHeightAnchor.constant = 72
        }
        
        if let footerText {
            footerLabel.text = footerText
        } else {
            footerLabel.isHidden = true
        }
        simpleButton.configure(title: title, systemImage: systemImage)
        selectionStyle = .none
        
        simpleButton.internalButton.removeTarget(nil, action: nil, for: .allEvents)
        simpleButton.internalButton.addAction(UIAction(handler: { _ in
            onButtonPress()
        }), for: .touchUpInside)
    }
    
}
