//
//  ConnectSpectrumCell.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/10.
//

import UIKit

class ConnectSpectrumCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundLineView: UIView!
    
    @IBOutlet var avgCircleView: UIImageView!
    @IBOutlet var youCircleView: UIImageView!
    @IBOutlet var matchCircleView: UIImageView!
    
    @IBOutlet var avgCircleViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var youCircleViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var matchCircleViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var matchLabelYConstraint: NSLayoutConstraint!
    @IBOutlet var youLabelYConstraint: NSLayoutConstraint!

    @IBOutlet var labelsContainerView: UIView!
    @IBOutlet var matchLabel: UILabel!
    @IBOutlet var youLabel: UILabel!
    @IBOutlet var avgLabel: UILabel!

    func configure(title: String, matchName: String, avgPercent: CGFloat, youPercent: CGFloat, matchPercent: CGFloat, shouldDisplayLabels: Bool) {
        titleLabel.text = title
        titleLabel.font = AppFont.medium.size(18)
        youLabel.font = AppFont.medium.size(14)
        avgLabel.font = AppFont.medium.size(14)
        matchLabel.font = AppFont.medium.size(14)
                
        backgroundLineView.backgroundColor = .customWhite.withAlphaComponent(0.5)
        avgLabel.textColor = .customWhite.withAlphaComponent(0.7)

        if shouldDisplayLabels {
            matchLabel.text = matchName
            labelsContainerView.isHidden = false
            youLabelYConstraint.constant = youPercent > matchPercent ? 0 : -45
            matchLabelYConstraint.constant = youPercent > matchPercent ? -45 : 0
        } else {
            labelsContainerView.isHidden = true
        }
        
        avgCircleViewLeadingConstraint.constant = (avgPercent/100) * (contentView.bounds.width - 50)
        youCircleViewLeadingConstraint.constant = (youPercent/100) * (contentView.bounds.width - 50)
        matchCircleViewLeadingConstraint.constant = (matchPercent/100) * (contentView.bounds.width - 50)
    }
    
}
