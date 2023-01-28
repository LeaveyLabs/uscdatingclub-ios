//
//  Conversation.swift
//  mist-ios
//
//  Created by Adam Monterey on 6/25/22.
//

import Foundation
import MessageKit

//Note: Conversation is a class because of the assumption that can will only ever be one conversation loaded into the screen at any given point in time
class Conversation {
    
    //MARK: - Properties
    
    //Data
    var sangdaebang: ReadOnlyUser
    var messageThread: LocationSocket
    var chatObjects = [MessageType]()
    
    let RENDER_MORE_MESSAGES_INTERVAL = 50
    var renderedIndex: Int!
    
    //MARK: - Initialization
    
    init(sangdaebang: ReadOnlyUser, messageThread: LocationSocket) {
        self.sangdaebang = sangdaebang
        self.messageThread = messageThread
        self.chatObjects = messageThread.messages.map { MessageKitMessage(message: $0, conversation: self) }
        self.chatObjects.sort { $0.sentDate < $1.sentDate }
        renderedIndex = min(50, chatObjects.count)
    }
    
    //MARK: - Setup
    
    func openConversation() {
        renderedIndex = min(50, chatObjects.count)
    }
    
    //MARK: - Getters
        
    func getRenderedChatObjects() -> [MessageType] {
        let allChatObjects = Array(chatObjects.suffix(renderedIndex))
        return allChatObjects
    }
    
    func hasRenderedAllChatObjects() -> Bool {
        return renderedIndex == chatObjects.count
    }
    
    func userWantsToSeeMoreMessages() {
        renderedIndex = min(renderedIndex + RENDER_MORE_MESSAGES_INTERVAL, chatObjects.count)
    }
        
    //MARK: - Sending things
    
    func sendMessage(messageText: String) async throws {
        do {
            let newMessage = Message(id: Int.random(in: 0..<Int.max),
                                     senderId: UserService.singleton.getId(),
                                     receiverId: sangdaebang.id,
                                     body: messageText,
                                     timestamp: Date().timeIntervalSince1970)
            try messageThread.sendMessage(message: newMessage)
            let attributedMessage = NSAttributedString(
                string: messageText,
                attributes: [.font: AppFont2.regular.size(15)])
            let messageKitMessage = MessageKitMessage(
                text: attributedMessage,
                sender: UserService.singleton.getUserAsReadOnlyUser(),
                receiver: sangdaebang,
                messageId: String(newMessage.id),
                date: Date())
            chatObjects.append(messageKitMessage)
            renderedIndex += 1
        } catch {
            //TODO: delete match request on the server and remove the most recent chatObject
        }
    }
    
    //MARK: - Receiving things
    
    func handleReceivedMessage(_ message: Message) {
        let attributedMessage = NSAttributedString(
            string: message.body,
            attributes: [.font: AppFont2.regular.size(15)])
        let messageKitMessage = MessageKitMessage(
            text: attributedMessage,
            sender: sangdaebang,
            receiver: UserService.singleton.getUserAsReadOnlyUser(),
            messageId: String(message.id),
            date: Date(timeIntervalSince1970: message.timestamp))
        chatObjects.append(messageKitMessage)
        renderedIndex += 1
        
        DispatchQueue.main.async {
            let visibleVC = SceneDelegate.visibleViewController
            if let chatVC = visibleVC as? CoordinateChatVC,
               chatVC.matchInfo.partnerId == self.sangdaebang.id {
                chatVC.handleNewMessage()
            }
        }
    }
    
}

//MARK: - Comparable

extension Conversation: Comparable {
    
    //The first conversations should be the ones with the largest dates
    static func < (lhs: Conversation, rhs: Conversation) -> Bool {
        return lhs.chatObjects.last?.sentDate ?? Date() > rhs.chatObjects.last?.sentDate ?? Date()
    }
    
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        return lhs.chatObjects.last?.sentDate == rhs.chatObjects.last?.sentDate
    }

}


//If two messages are both attributedText, then their messageKind is equal
//extension MessageKind: Equatable {
//    public static func == (lhs: MessageKind, rhs: MessageKind) -> Bool {
//        switch (lhs, rhs) {
//        case (.attributedText(_), .attributedText(_)):
//            return true
//        case (.custom(_), .custom(_)):
//            return true
//        default:
//            return false
//        }
//    }
//}
