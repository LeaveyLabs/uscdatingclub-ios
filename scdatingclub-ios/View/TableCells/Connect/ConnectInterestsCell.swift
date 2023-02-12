//
//  ConnectQualityCell.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/01/24.
//

import UIKit

class ConnectInterestsCell: UITableViewCell {

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var headerLabel: UILabel!
    
    @IBOutlet var innerStackView1: UIStackView!
    @IBOutlet var innerStackView2: UIStackView!
    @IBOutlet var innerStackView3: UIStackView!

    @IBOutlet var qualityLabel1: UILabel!
    @IBOutlet var qualityLabel2: UILabel!
    @IBOutlet var qualityLabel3: UILabel!
    
    @IBOutlet var emojiLabel1: UILabel!
    @IBOutlet var emojiLabel2: UILabel!
    @IBOutlet var emojiLabel3: UILabel!
    
    var innerStackViews: [UIStackView] {
        return [innerStackView1, innerStackView2, innerStackView3]
    }
    
    var interestUis: [(UILabel, UILabel)] {
        return [(qualityLabel1, emojiLabel1), (qualityLabel2, emojiLabel2), (qualityLabel3, emojiLabel3), ]
    }

    func configure(_ textSimilarities: [TextSimilarity]) {
        selectionStyle = .none
        headerLabel.font = AppFont2.medium.size(12)
        
        for interestUi in interestUis {
            interestUi.0.isHidden = false
            interestUi.1.isHidden = false
            interestUi.0.font = AppFont.medium.size(16)
            interestUi.1.font = AppFont.medium.size(60)
        }
        innerStackViews.forEach { stackview in stackview.isHidden = false }
        
        for x in 0..<textSimilarities.count {
            let similarity = textSimilarities[x]
            let interestUi = interestUis[x]
            interestUi.0.text = similarity.sharedResponse
            interestUi.1.text = similarity.emoji
        }
        
        for x in textSimilarities.count..<3 {
            interestUis[x].0.isHidden = true
            interestUis[x].1.isHidden = true
            innerStackViews[x].isHidden = true
        }
    }
    
}
