//
//  UIImageView+AnimateChange.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/02/09.
//

import UIKit

extension UIImageView{
    func setImage(_ image: UIImage?, animated: Bool = true) {
        let duration = animated ? 0.3 : 0.0
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.image = image
        }, completion: nil)
    }
}
 
