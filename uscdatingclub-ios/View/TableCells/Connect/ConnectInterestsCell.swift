//
//  ConnectQualityCell.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/24.
//

import UIKit

class ConnectInterestsCell: UITableViewCell {

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var headerLabel: UILabel!
    
    @IBOutlet var qualityLabel1: UILabel!
    @IBOutlet var qualityLabel2: UILabel!
    @IBOutlet var qualityLabel3: UILabel!
    
    @IBOutlet var emojiLabel1: UILabel!
    @IBOutlet var emojiLabel2: UILabel!
    @IBOutlet var emojiLabel3: UILabel!
    
    var interestUis: [(UILabel, UILabel)] {
        return [(qualityLabel1, emojiLabel1), (qualityLabel2, emojiLabel2), (qualityLabel3, emojiLabel3), ]
    }

    func configure(_ textSimilarities: [TextSimilarity]) {
        headerLabel.font = AppFont.medium.size(12)
        
        for interestUi in interestUis {
            interestUi.0.isHidden = false
            interestUi.1.isHidden = false
            interestUi.0.font = AppFont.medium.size(40)
            interestUi.1.font = AppFont.medium.size(16)
        }
        
        for x in 0..<textSimilarities.count {
            let similarity = textSimilarities[x]
            let interestUi = interestUis[x]
            interestUi.0.text = similarity.trait
            interestUi.1.text = similarity.sharedResponse
        }
        
        for x in textSimilarities.count..<3 {
            interestUis[x].0.isHidden = true
            interestUis[x].1.isHidden = true
        }
    }
    
}
