//
//  Message.swift
//  scdatingclub-ios
//
//  Created by Kevin Sun on 1/24/23.
//

import UIKit

struct Message {
    let id: Int
    let senderId: Int
    let receiverId: Int
    let body: String
    let timestamp: Double
    
    static let normalDisplayAttributes: [NSAttributedString.Key : Any] = [
        .font: AppFont2.regular.size(15),
        .foregroundColor: UIColor.customBlack,
    ]
}
