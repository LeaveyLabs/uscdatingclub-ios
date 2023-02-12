//
//  SimpleButtonCell.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/01/08.
//

import UIKit

class SimpleButtonCell: UITableViewCell {

    @IBOutlet weak var simpleButton: SimpleButton!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var buttonHeightAnchor: NSLayoutConstraint!
    var hasBeenConfiguredOnce = false
    
    func configure(title: String, systemImage: String, footerText: String? = nil, buttonHeight: CGFloat? = nil, onButtonPress: @escaping () -> Void) {
        if title.rangeOfCharacter(from: .newlines) != nil {
            buttonHeightAnchor.constant = 80
        }
        if let buttonHeight {
            buttonHeightAnchor.constant = buttonHeight
        }
        
        if let footerText {
            footerLabel.text = footerText
            footerLabel.font = AppFont2.light.size(14)
        } else {
            footerLabel.isHidden = true
        }
        simpleButton.configure(title: title, systemImage: systemImage)
        selectionStyle = .none
        
        guard !hasBeenConfiguredOnce else { return }
        simpleButton.internalButton.addAction(UIAction(handler: { _ in
            onButtonPress()
        }), for: .touchUpInside)
        hasBeenConfiguredOnce = true
    }
    
}
