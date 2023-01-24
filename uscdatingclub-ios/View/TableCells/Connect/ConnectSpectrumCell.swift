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
        
        var youPercent = youPercent
        var matchPercent = matchPercent

        if shouldDisplayLabels {
            
            matchLabel.text = matchName
            labelsContainerView.isHidden = false
            youLabelYConstraint.constant = youPercent > matchPercent ? 0 : -45
            matchLabelYConstraint.constant = youPercent > matchPercent ? -45 : 0
            
            //ADJUSTMENTS
            //Don't let matchLabel hang off right end
            let matchNameLength = CGFloat(matchName.count)
            matchPercent = min(100 - matchNameLength / 2, matchPercent)
            
            //Don't let matchLabel and youLabel crossover
            let distanceBetween = abs(matchPercent - youPercent)
            let correction = matchNameLength - distanceBetween
            if correction > 0 {
                if matchPercent + correction <= 100 {
                    matchPercent += correction
                } else if youPercent + correction <= 100 {
                    youPercent += correction
                } else {
                    if matchPercent > youPercent {
                        youPercent -= correction
                    } else {
                        matchPercent -= correction
                    }
                }
            }
            
        } else {
            labelsContainerView.isHidden = true
        }
        
        print("AVGPERCENT", avgPercent)
        avgCircleViewLeadingConstraint.constant = (avgPercent/100) * (contentView.bounds.width - 50)
        youCircleViewLeadingConstraint.constant = (youPercent/100) * (contentView.bounds.width - 50)
        matchCircleViewLeadingConstraint.constant = (matchPercent/100) * (contentView.bounds.width - 50)
    }
    
}
