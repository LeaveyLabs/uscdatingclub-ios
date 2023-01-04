//
//  WantToChatView.swift
//  mist-ios
//
//  Created by Adam Monterey on 7/3/22.
//

import UIKit

class SimpleButton: UIView {
        
    //MARK: - Properties
    
    //UI
    @IBOutlet weak var internalButton: UIButton!
    
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
        setupButtons()
    }
    
    func setupButtons() {
        internalButton.titleLabel?.numberOfLines = 0
        internalButton.titleLabel?.textAlignment = .center
    }
        
    //MARK: - User Interaction
    
    @IBAction func internalButtonTouchUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.transform = .identity
        }
    }
    
    @IBAction func internalButtonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.transform = CGAffineTransformMakeScale(0.95, 0.95)
        }
    }
    
    @IBAction func internalButtonTouchUpOutside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.transform = .identity
        }
    }
}

//MARK: - Public Interface

extension SimpleButton {
    
    // Note: the constraints for the PostView should already be set-up when this is called.
    // Otherwise you'll get loads of constraint errors in the console
    func configure(title: String, subtitle: String? = nil, systemImage: String) {
        internalButton.setTitle(title, for: .normal)
        
        if let subtitle {
            let fullText = title + "\n" + subtitle
            let attributedText = NSMutableAttributedString(string: fullText)
            if let titleRange = fullText.range(of: title) {
                attributedText.setAttributes([.font: UIFont(name: AppFontName.bold, size: 20)!], range: NSRange(titleRange, in: fullText))
            }
            
            if let subtitleRange = fullText.range(of: subtitle) {
                attributedText.setAttributes([.font: UIFont(name: AppFontName.regular, size: 16)!], range: NSRange(subtitleRange, in: fullText))
            }

            internalButton.setAttributedTitle(attributedText, for: .normal)
        }
        
        internalButton.setImage(UIImage(systemName: systemImage), for: .normal)
    }
    
}
