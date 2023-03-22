//
//  CommentCell.swift
//  mist-ios
//
//  Created by Adam Novak on 2022/03/12.
//

import UIKit

protocol BasicSelectTableViewCellDelegate {
    func didTapIconButton(cellTitle: String)
}

class BasicSelectTableViewCell: UITableViewCell {
    
    //MARK: - Properties

    //UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet var emojiIconLabel: UILabel!
    @IBOutlet var imageIconView: UIImageView!
    
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var labelButton: UIButton!
    
    //Data
    var title: String
    var delegate: BasicSelectTableViewCellDelegate!
    
    //MARK: - Initializer
    
    func configure(title: String, description: String? = nil, emoji: String? = nil, sysImageName: String? = nil, delegate: BasicSelectTableViewCellDelegate) {
        selectionStyle = .none
        backgroundColor = .clear
        
        self.delegate = delegate
        self.title = title
        bgView.backgroundColor = UIColor.primaryColor
        bgView.roundCornersViaCornerRadius(radius: 15)
        titleLabel.text = title
        descriptionLabel.text = description
        
        descriptionLabel.isHidden = description == nil
        labelButton.isHidden = sysImageName == nil
        imageIconView.isHidden = sysImageName == nil
        
        emojiIconLabel.text = emoji
        imageIconView.image = UIImage(systemName: sysImageName ?? "")
    }
    
    @IBAction func didTapBg() {
        delegate.didTapIconButton(cellTitle: title)
    }
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
