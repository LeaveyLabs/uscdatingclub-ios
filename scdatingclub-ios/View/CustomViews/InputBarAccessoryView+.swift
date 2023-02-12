//
//  InputBarAccessoryView+.swift
//  mist-ios
//
//  Created by Adam Monterey on 8/18/22.
//

import UIKit
import InputBarAccessoryView

extension InputBarAccessoryView {
    
    func configureForChatting() {
        layer.shadowOpacity = 0
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        
        separatorLine.height = 0.5
        separatorLine.backgroundColor = .customWhite.withAlphaComponent(0.7)
        
        self.backgroundView.backgroundColor = .tintColor
        inputTextView.textColor = .customWhite
        inputTextView.tintColor = .customWhite.withAlphaComponent(0.7)
        inputTextView.placeholderTextColor = .customWhite.withAlphaComponent(0.7)
        
//        inputTextView.placeholderLabel.font = AppFont2.bold.size(15)
//        inputTextView.font = AppFont.regular.size(15) //???????? this line of code creates a thick white line above textView
//        Message.normalDisplayAttributes[.font] as? UIFont

        
//        //Center
//        inputTextView.layer.borderWidth = 0
//        inputTextView.layer.borderColor = UIColor.purple.withAlphaComponent(0.7).cgColor
//        inputTextView.backgroundColor = .customWhite
////        inputTextView.color
//        self.backgroundView.backgroundColor = .tintColor
//        inputTextView.layer.cornerRadius = 10
//        inputTextView.layer.masksToBounds = true
        inputTextView.indicatorStyle = .white
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        inputTextView.autocapitalizationType = .none
        shouldAnimateTextDidChangeLayout = true
        maxTextViewHeight = 144 //max of 6 lines with the given font
        
//        //Left
        setLeftStackViewWidthConstant(to: 0, animated: false)

//        //Right
        setRightStackViewWidthConstant(to: 38, animated: false)
        sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        setStackViewItems([sendButton, InputBarButtonItem.fixedSpace(2)], forStack: .right, animated: false)
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 4, right: 2)
        sendButton.setImage(UIImage(named: "enabled-send-button"), for: .normal)
        sendButton.title = nil
        sendButton.becomeRound()
    }
}
