//
//  UIView+AreAnimationsInProgress.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/02/12.
//

import UIKit

extension UIView {
    
    static var areAnimationsInProgress: Bool {
        return UIView.inheritedAnimationDuration > 0
    }
}
