//
//  ConnectHeaderCell.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/10.
//

import UIKit

class ConnectHeaderCell: UITableViewCell {

    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var distanceAwayLabel: UILabel!
    @IBOutlet weak var timeLeftAccessoryLabel: UILabel!
    @IBOutlet weak var distanceAwayAccessoryLabel: UILabel!

    func configure(timeLeft: String, distanceAway: String, isWaiting: Bool, matchName: String) {
        timeLeftAccessoryLabel.text = isWaiting ? "for \(matchName) to klasdjf;lkjasdl;fkja;lsdkfj; respond" : "to respond"
        timeLeftLabel.text = timeLeft
        distanceAwayLabel.text = distanceAway
        distanceAwayLabel.font = AppFont.bold.size(28)
        timeLeftLabel.font = AppFont.bold.size(28)
        timeLeftAccessoryLabel.font = AppFont.light.size(12)
        distanceAwayAccessoryLabel.font = AppFont.light.size(12)
    }
    
}
