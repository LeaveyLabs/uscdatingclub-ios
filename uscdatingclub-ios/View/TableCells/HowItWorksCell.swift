//
//  CommentCell.swift
//  mist-ios
//
//  Created by Adam Novak on 2022/03/12.
//

import UIKit

class HowItWorksCell: UITableViewCell {
    
    //MARK: - Properties

    //UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bigImageView: UIImageView!
    
    //MARK: - Initializer
    
    func configure(title: String, description: String, image: UIImage) {
        titleLabel.text = title
        descriptionLabel.text = description
        bigImageView.image = image
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
