//
//  FeatureView.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2022/12/30.
//

import UIKit

class FeatureView: UIView {
        
    //MARK: - Properties
    
    //UI
    @IBOutlet var featureTitleLabel: UILabel!
    @IBOutlet var featureDescriptionLabel: UILabel!
    @IBOutlet var featureImageView: UIImageView!
    
    //MARK: - Constructors
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    private func customInit() {
        guard let contentView = loadViewFromNib(nibName: String(describing: Self.self)) else { return }
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        
        featureTitleLabel.font = AppFont.bold.size(25)
    }
}

//MARK: - Public Interface

extension FeatureView {
    
    // Note: the constraints for the PostView should already be set-up when this is called.
    // Otherwise you'll get loads of constraint errors in the console
    func configure(_ feature: Feature) {
        featureTitleLabel.text = feature.title
        featureDescriptionLabel.text = feature.description
        featureImageView.image = UIImage(systemName: feature.sysemImageName)
    }
    
}
