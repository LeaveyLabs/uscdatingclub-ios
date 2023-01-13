//
//  PermissionsCell.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/12.
//

import UIKit

class PermissionsCell: UITableViewCell {
    
    @IBOutlet weak var simpleButton: SimpleButton!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var buttonHeightAnchor: NSLayoutConstraint!
    @IBOutlet var checkmarkImageView: UIImageView!
    
    enum PermissionsType: CaseIterable {
        case location, refresh, notifications
        
        var grantedTitle: String {
            switch self {
            case .location:
                return "location enabled"
            case .refresh:
                return "background app refresh enabled"
            case .notifications:
                return "notifications enabled"
            }
        }
        
        var notGrantedTitle: String {
            switch self {
            case .location:
                return "share location"
            case .refresh:
                return "turn on background app refresh"
            case .notifications:
                return "turn on notifications"
            }
        }
        
        var systemImage: String {
            switch self {
            case .location:
                return "location"
            case .refresh:
                return "arrow.clockwise.circle"
            case .notifications:
                return "bell"
            }
        }
        
    }
    func configure(type: PermissionsType, isPermissionsGranted: Bool, onPress: @escaping () -> Void) {
        buttonHeightAnchor.constant = type == .location ? 60 : type == .notifications ? 60 : 60
        
        if type == .location && !isPermissionsGranted {
            footerLabel.text = "precise, always"
            footerLabel.font = AppFont2.light.size(14)
        } else {
            footerLabel.isHidden = true
        }
        simpleButton.configure(title: isPermissionsGranted ? type.grantedTitle : type.notGrantedTitle, systemImage: type.systemImage)
        selectionStyle = .none
        
        simpleButton.internalButton.removeTarget(nil, action: nil, for: .allEvents)
        simpleButton.internalButton.addAction(UIAction(handler: { _ in
            onPress()
        }), for: .touchUpInside)
        
        contentView.backgroundColor = .clear
        contentView.alpha = isPermissionsGranted ? 1 : 0.5
        checkmarkImageView.alpha = isPermissionsGranted ? 1 : 0
        simpleButton.isUserInteractionEnabled = isPermissionsGranted ? false : true
    }
    
}
