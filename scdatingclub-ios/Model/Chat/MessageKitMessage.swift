//
//  MessageKitMessage.swift
//  mist-ios
//
//  Created by Adam Novak on 2022/05/16.
//

import UIKit
import MessageKit

struct MessageKitMessage: MessageType {
    // MessageType Protocol members
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var sender: SenderType
    
    // Custom members
    var message: Message
    
    init(text: NSAttributedString, sender: SenderType, receiver: SenderType, messageId: String, date: Date) {
        self.kind = .attributedText(text)
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
                
        self.message = Message(id: Int(messageId)!,
                               senderId: Int(sender.senderId)!,
                               receiverId: Int(receiver.senderId)!,
                               body: text.string,
                               timestamp: date.timeIntervalSince1970)
    }
    
    init(message: Message, conversation: Conversation) {
        let attributedMessage = NSAttributedString(string: message.body, attributes: [.font: Message.normalDisplayAttributes[.font] as! UIFont])
        
        self.kind = .attributedText(attributedMessage)
        self.sender = message.senderId == UserService.singleton.getId() ? UserService.singleton.getUserAsReadOnlyUser() : conversation.sangdaebang
        self.messageId = String(message.id)
        self.sentDate = Date(timeIntervalSince1970: message.timestamp)
        
        self.message = message
    }
}
