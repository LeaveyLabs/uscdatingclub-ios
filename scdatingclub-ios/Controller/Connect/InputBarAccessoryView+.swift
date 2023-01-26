//
//  InputBarAccessoryView+.swift
//  mist-ios
//
//  Created by Adam Monterey on 8/18/22.
//

import UIKit
import InputBarAccessoryView

var isCommentingAnonymous: Bool = false

extension InputBarAccessoryView {
    
    func configureForChatting() {
        //iMessage
        layer.shadowOpacity = 0
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        separatorLine.height = 0
        
        inputTextView.placeholderLabel.font = Message.normalDisplayAttributes[.font] as? UIFont
        inputTextView.font = Message.normalDisplayAttributes[.font] as? UIFont
        
        //Center
        inputTextView.layer.borderWidth = 0.8
        inputTextView.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.23).cgColor
//        UIColor.systemGray4.cgColor
        inputTextView.tintColor = .tintColor
        inputTextView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        inputTextView.layer.cornerRadius = 16.0
        inputTextView.layer.masksToBounds = true
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        inputTextView.autocapitalizationType = .none
        shouldAnimateTextDidChangeLayout = true
        maxTextViewHeight = 144 //max of 6 lines with the given font
        if let middleContentView = middleContentView, middleContentView != inputTextView {
            middleContentView.removeFromSuperview()
            middleContentView.layer.shadowOpacity = 0
            setMiddleContentView(inputTextView, animated: false)
        }
        
        //Left
        setLeftStackViewWidthConstant(to: 2, animated: false)

        //Right
        setRightStackViewWidthConstant(to: 38, animated: false)
        sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        setStackViewItems([sendButton, InputBarButtonItem.fixedSpace(2)], forStack: .right, animated: false)
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 4, right: 2)
        sendButton.setImage(UIImage(named: "enabled-send-button"), for: .normal)
        sendButton.title = nil
        sendButton.becomeRound()
    }
}
