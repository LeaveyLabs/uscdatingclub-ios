//
//  UIViewController+ClassName.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/02/11.
//

import UIKit

extension UIViewController {
    var className: String {
        NSStringFromClass(self.classForCoder).components(separatedBy: ".").last!
    }
}
