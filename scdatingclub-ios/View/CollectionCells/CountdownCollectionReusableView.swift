//
//  CountdownCollectionReusableView.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/02/09.
//

import UIKit
import MessageKit

class CountdownCollectionReusableView: MessageReusableView {

    static let HEIGHT: CGFloat = 300
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var timeSublabel: UILabel!
    @IBOutlet var locationImageView: UIImageView!
    @IBOutlet var locationLabel: UILabel!
    
    open func configure(with matchInfo: MatchInfo, relativePositioning: RelativePositioning) {
        timeLabel.font = AppFont.bold.size(40)
        timeSublabel.font = AppFont.light.size(16)
        locationLabel.font = AppFont.bold.size(40)
        
        timeLabel.text = matchInfo.timeLeftToConnectString
        timeSublabel.text = "left to connect"
        locationLabel.text = prettyDistance(meters: relativePositioning.distance, shortened: true)
        locationImageView.transform = CGAffineTransform.identity.rotated(by: relativePositioning.heading)
    }
    
}
