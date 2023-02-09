/*
 MIT License
 
 Copyright (c) 2017-2019 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit
import MessageKit
import InputBarAccessoryView
import MessageUI

class FixedInsetTextMessageCell: TextMessageCell {
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        messageLabel.textInsets =  .init(top: 8, left: 16, bottom: 8, right: 15)
    }
    
}

class LegacyInputTextView: InputTextView {

    private var canBecomeFirstResponderStorage: Bool = true
    open override var canBecomeFirstResponder: Bool {
        get { canBecomeFirstResponderStorage }
        set(newValue) { canBecomeFirstResponderStorage = newValue }
    }
    
}

class CoordinateChatVC: MessagesViewController {
    
    //MARK: - Propreties
    
    //We are using the subview rather than the first responder approach
    override var canBecomeFirstResponder: Bool { return false }
    
    override var inputAccessoryView: UIView?{
        return nil //this should be "messageInputBar" according to the docs, but then i was dealing with other problems. Instead, i just set the additionalBottomInset as necessary when they toggle keyboard up and down
    }
    let inputBar = InputBarAccessoryView()
    let keyboardManager = KeyboardManager()
    
    var viewHasAppeared = false

    let INPUTBAR_PLACEHOLDER = "message"
    let MAX_MESSAGE_LENGTH = 999
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        return refreshControl
    }()
    
    //UI
    @IBOutlet var navView: UIView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
        
    //Data
    var relativePositioning: RelativePositioning = .init(heading: 0, distance: 0)
    var matchInfo: MatchInfo!
    var connectManager: ConnectManager!
    var conversation: Conversation!
    
    //MARK: - Initialization
    
    class func create(matchInfo: MatchInfo) -> CoordinateChatVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Connect, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.CoordinateChat) as! CoordinateChatVC
        vc.matchInfo = matchInfo
        vc.connectManager = ConnectManager(matchInfo: matchInfo, delegate: vc)
        return vc
    }
    
    //MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        
        //Note: codesmell. conversation and connect manager should be better integrated. 
        connectManager.startConnectSession()
        let partner = ReadOnlyUser(id: matchInfo.partnerId,
                                   firstName: matchInfo.partnerName,
                                   lastName: "")
        conversation = Conversation(sangdaebang: partner,
                                    messageThread: connectManager.locationSocket!)
    }
        
    override func viewDidLoad() {
        updateAdditionalBottomInsetForDismissedKeyboard()
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout()) //for registering custom MessageSizeCalculator for MessageKitMatch
        super.viewDidLoad()
        view.tintColor = .tintColor
        setupMessagesCollectionView()
        setupNavBar()
        setupKeyboard()
        setupMessageInputBarForChatting()
        
        setupButtons()
        setupLabels() //must come after connect manager created
        
        DispatchQueue.main.async { //scroll on the next cycle so that collectionView's data is loaded in beforehand
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messagesCollectionView.reloadDataAndKeepOffset()
        
        //TODO: add below
//        if !inputBar.inputTextView.canBecomeFirstResponder {
//            inputBar.inputTextView.canBecomeFirstResponder = true //bc we set to false in viewdiddisappear
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewHasAppeared = true
        
//        ConversationService.singleton.updateLastMessageReadTime(withUserId: conversation.sangdaebang.id)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        inputBar.inputTextView.resignFirstResponder()
        //TODO: add below
//        inputBar.inputTextView.canBecomeFirstResponder = false //so it doesnt become first responder again if the swipe back gesture is cancelled halfway through
//        UIView.animate(withDuration: 0.3, delay: 0) { [self] in
//            messagesCollectionView.contentInset = .init(top: 0, left: 0, bottom: additionalBottomInset, right: 0)
//        }

        //if is pushing a view controller
        if !self.isAboutToClose {
            navigationController?.setNavigationBarHidden(false, animated: animated)
            navigationController?.navigationBar.tintColor = .customBlack //otherwise it's blue... idk why
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewHasAppeared = false
    }
    
    //MARK: - Setup
    
    func setupKeyboard() {
        messagesCollectionView.contentInsetAdjustmentBehavior = .never //dont think this does anything
        messageInputBar = inputBar
        inputBar.delegate = self
        inputBar.inputTextView.delegate = self
        
        //Keyboard manager from InputBarAccessoryView
        view.addSubview(messageInputBar)
        keyboardManager.shouldApplyAdditionBottomSpaceToInteractiveDismissal = true
        keyboardManager.bind(inputAccessoryView: messageInputBar) //properly positions inputAccessoryView
        keyboardManager.bind(to: messagesCollectionView) //enables interactive dismissal
                
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow(sender:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide(sender:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillChangeFrame(sender:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        additionalBottomInset = 52
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        updateAdditionalBottomInsetForDismissedKeyboard()
    }
    
    var keyboardHeight: CGFloat = 0
    @objc func keyboardWillChangeFrame(sender: NSNotification) {
        let i = sender.userInfo!
        let newKeyboardHeight = (i[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let isKeyboardTypeToggling = keyboardHeight > 0 && newKeyboardHeight > 0
        if isKeyboardTypeToggling {
            DispatchQueue.main.async { [self] in
                additionalBottomInset += newKeyboardHeight - keyboardHeight
                messagesCollectionView.scrollToLastItem()
            }
        }
        keyboardHeight = newKeyboardHeight
    }
    
    func updateAdditionalBottomInsetForDismissedKeyboard() {
        //can't use view's safe area insets because they're 0 on viewdidload
        additionalBottomInset = 52 + (window?.safeAreaInsets.bottom ?? 0)
    }
    
    //i had to add this code because scrollstolastitemonkeyboardbeginsediting doesnt work
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    func setupButtons() {
        closeButton.addAction(.init(handler: { [self] _ in
            closeButtonDidPressed()
        }), for: .touchUpInside)
        moreButton.addAction(.init(handler: { [self] _ in
            moreButtonDidPressed()
        }), for: .touchUpInside)
    }
    
    func setupLabels() {
        nameLabel.text = matchInfo.partnerName
        nameLabel.font = AppFont.bold.size(22)
    }
        
    func setupMessagesCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.delegate = self
        
        //UI
        messagesCollectionView.backgroundColor = .clear
        view.backgroundColor = .tintColor
        
        //Nibs
        messagesCollectionView.register(FixedInsetTextMessageCell.self)
//        let countdownCell = UINib(nibName: String(describing: ConnectionCountdownCell.self), bundle: nil)
//        messagesCollectionView.register(countdownCell, forCellWithReuseIdentifier: String(describing: ConnectionCountdownCell.self))
        
//        messagesCollectionView.register(CountdownCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: CountdownCollectionReusableView.self))
//        messagesCollectionView.messagesCollectionViewFlowLayout.headerReferenceSize = CGSize(width: view.bounds.width, height: 500)

        //Misc
        messagesCollectionView.refreshControl = refreshControl
        if conversation.hasRenderedAllChatObjects() { refreshControl.removeFromSuperview() }
        
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        showMessageTimestampOnSwipeLeft = true // default false
//        additionalBottomInset = 55 + (window?.safeAreaInsets.bottom ?? 0)
    }
    
    func setupNavBar() {
        navigationController?.isNavigationBarHidden = true
        view.sendSubviewToBack(messagesCollectionView)
        
        //Remove top constraint which was set in super's super, MessagesViewController. Then, add a new one.
        view.constraints.first { $0.firstAnchor == messagesCollectionView.topAnchor }!.isActive = false
        messagesCollectionView.topAnchor.constraint(equalTo: navView.bottomAnchor, constant: 5).isActive = true
    }
    
    func setupMessageInputBarForChatting() {
        inputBar.inputTextView.placeholder = INPUTBAR_PLACEHOLDER
        inputBar.configureForChatting()
        inputBar.delegate = self
        inputBar.inputTextView.delegate = self //does this cause issues? i'm not entirely sure
    }
    
    //MARK: - User Interaction
    
    func closeButtonDidPressed() {
        AlertManager.showAlert(title: "stop sharing your location with \(matchInfo.partnerName)?",
                               subtitle: "you won't be able to restart it afterwards",
                               primaryActionTitle: "stop sharing location",
                               primaryActionHandler: {
            //end the match
            DispatchQueue.main.async {
                self.finish()
            }
        },
                               secondaryActionTitle: "nevermind",
                               secondaryActionHandler: {
            //do nothing
        }, on: self)
    }
    
    func moreButtonDidPressed() {
        let moreVC = SheetVC.create(
            sheetButtons: [
                SheetButton(title: "view compatibility", systemImageName: "testtube.2", handler: {
                    self.presentCompatibility()
                }),
                SheetButton(title: "report", systemImageName: "exclamationmark.triangle", handler: {
                    self.presentReportAlert()
                }),
            ])
        present(moreVC, animated: true)
    }
    
    func presentCompatibility() {
        
    }
    
    func presentReportAlert() {
        AlertManager.showAlert(title: "would you like to report \(matchInfo.partnerName)?",
                               subtitle: "your location will stop sharing immediately",
                               primaryActionTitle: "report",
                               primaryActionHandler: {
            //block user
            
            DispatchQueue.main.async {
                self.finish()
            }
        },
                               secondaryActionTitle: "nevermind",
                               secondaryActionHandler: {
            //do nothing
        }, on: SceneDelegate.visibleViewController!)
    }
    
    //MARK: - Helpers

    @MainActor
    func finish() {
        connectManager.endConnection()
        transitionToStoryboard(storyboardID: Constants.SBID.SB.Main, duration: 0.5)
    }
    
    // MARK: - UICollectionViewDataSource
    
//    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
//        return CGSize(width: view.bounds.width, height: 300)
//    }
//
//    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
//        let headerView = messagesCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: CountdownCollectionReusableView.self), for: indexPath) as! CountdownCollectionReusableView
//        headerView.frame.size.height = CountdownCollectionReusableView.HEIGHT
//        return headerView
//    }
    
//    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
//        <#code#>
//    }
        
//    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
//        (view as? CountdownCollectionReusableView)?.configure(with: matchInfo, relativePositioning: relativePositioning)
//    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
//        (view as? CountdownCollectionReusableView)?.configure(with: matchInfo, relativePositioning: relativePositioning)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }

        // Very important to check this when overriding `cellForItemAt`
        // Super method will handle returning the typing indicator cell
        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)

        if let cell = messagesDataSource.textCell(for: message, at: indexPath, in: messagesCollectionView) {
            return cell
        } else {
            let cell = messagesCollectionView.dequeueReusableCell(FixedInsetTextMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
//        return super.collectionView(collectionView, cellForItemAt: indexPath) //this returned the old TextMessageCell with incorrect insets
    }
    
//    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if let cell = cell as? TextMessageCell {
//            cell.messageLabel.textInsets = .init(top: 8, left: 16, bottom: 8, right: 15)
//        }
//    }
    
}

//MARK: - ConnectManagerDelegate

extension CoordinateChatVC: ConnectManagerDelegate {
    
    func newSecondElapsed() {
        DispatchQueue.main.async { [self] in
            messagesCollectionView.reloadDataAndKeepOffset()
        }
    }
    
    func timeRanOut() {
        AlertManager.showAlert(title: "your time to connect with " + matchInfo.partnerName + " has run out",
                               subtitle: "",
                               primaryActionTitle: "return home",
                               primaryActionHandler: {
            DispatchQueue.main.async {
                self.finish()
            }
        }, on: self)
    }
    
    func newRelativePositioning(_ relativePositioning: RelativePositioning) {
        self.relativePositioning = relativePositioning
        DispatchQueue.main.async { [self] in
            messagesCollectionView.reloadDataAndKeepOffset()
        }
    }
    
}


//MARK: - MessagesDataSource

extension CoordinateChatVC: MessagesDataSource {
    
    var currentSender: MessageKit.SenderType {
        UserService.singleton.getUserAsReadOnlyUser()
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return conversation.getRenderedChatObjects().count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return conversation.getRenderedChatObjects()[indexPath.section]
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isMostRecentMessageFromSender(message: message, at: indexPath) {
            return NSAttributedString(string: "sent", attributes: [NSAttributedString.Key.font: UIFont(name: Constants.Font.Medium, size: 11)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
        return nil
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isTimeLabelVisible(at: indexPath) {
            return NSAttributedString(string: getFormattedTimeStringForChat(timestamp: message.sentDate.timeIntervalSince1970).lowercased(), attributes: [NSAttributedString.Key.font: UIFont(name: Constants.Font.Medium, size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
        return nil
    }
    
    func messageTimestampLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: getFormattedTimeStringForChat(timestamp: message.sentDate.timeIntervalSince1970).lowercased(), attributes: [NSAttributedString.Key.font: UIFont(name: Constants.Font.Medium, size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
}

extension InputBarAccessoryViewDelegate {
    func accessoryViewRemovedFromSuperview() {
        fatalError("Requries subclass implementation")
    }
}

// MARK: - InputBarDelegate

extension CoordinateChatVC: InputBarAccessoryViewDelegate {
    
    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        processInputBar(inputBar)
    }
    
    func processInputBar(_ inputBar: InputBarAccessoryView) {
        let messageString = inputBar.inputTextView.attributedText.string.trimmingCharacters(in: .whitespaces)
        inputBar.inputTextView.text = String()
        inputBar.sendButton.isEnabled = false
        inputBar.inputTextView.placeholder = INPUTBAR_PLACEHOLDER
        Task {
            do {
                try await conversation.sendMessage(messageText: messageString)
                DispatchQueue.main.async { [self] in
                    handleNewMessage()
                }
            } catch {
                AlertManager.displayError(error)
            }
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        //TODO later: when going onto a new line of text, recalculate inputBar like we do within the postVC
//        additionalBottomInset = 52
//        messagesCollectionView.scrollToLastItem()
    }
        
    @MainActor
    func handleNewMessage() {
//        ConversationService.singleton.updateLastMessageReadTime(withUserId: conversation.sangdaebang.id)
//        messagesCollectionView.performBatchUpdates({
//            messagesCollectionView.numberOfItems(inSection: 0) //prevents an occassional crash?
////            messagesCollectionView.insertSections([numberOfSections(in: messagesCollectionView) - 1])
//            if numberOfSections(in: messagesCollectionView) == 1 {
//                messagesCollectionView.reloadDataAndKeepOffset()
//            } else {
//                messagesCollectionView.insertSections([numberOfSections(in: messagesCollectionView)-1])
//                messagesCollectionView.reloadSections([numberOfSections(in: messagesCollectionView) - 2])
//            }
//
//        })
        messagesCollectionView.reloadDataAndKeepOffset()
//        messagesCollectionView.scrollToLastItem(animated: true)
    }
    
}

//MARK: - UITextViewDelegate

extension CoordinateChatVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.shouldChangeTextGivenMaxLengthOf(MAX_MESSAGE_LENGTH, range, text)
    }
}


// MARK: - MessagesDisplayDelegate

extension CoordinateChatVC: MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .customBlack
    }
        
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        return MessageLabel.defaultAttributes
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .phoneNumber]
    }
        
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .lightGray.withAlphaComponent(0.2) : .white
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return isFromCurrentSender(message: message) ? .bubble : .bubbleOutline(.darkGray.withAlphaComponent(0.23))
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        return
        //do nothing
//        let nextIndexPath = IndexPath(item: 0, section: indexPath.section+1)
//        avatarView.isHidden = isNextMessageSameSender(at: indexPath) && !isTimeLabelVisible(at: nextIndexPath)
//        let theirPic = isSangdaebangProfileHidden ? conversation.sangdaebang.silhouette : conversation.sangdaebang.profilePic
//        avatarView.set(avatar: Avatar(image: theirPic, initials: ""))
    }

}

// MARK: - MessagesLayoutDelegate

extension CoordinateChatVC: MessagesLayoutDelegate {
        
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isTimeLabelVisible(at: indexPath) ? 50 : 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isMostRecentMessageFromSender(message: message, at: indexPath) ? 16 : 0
    }
        
}

//MARK: - ScrollViewDelegate

extension CoordinateChatVC {
    
    override func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        print("Why is this not being called?")
    }
    
    //Refreshes new messages when you reach the top
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 && !refreshControl.isRefreshing && !conversation.hasRenderedAllChatObjects() && viewHasAppeared && refreshControl.isEnabled {
            refreshControl.beginRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                conversation.userWantsToSeeMoreMessages()
                messagesCollectionView.reloadDataAndKeepOffset()
                refreshControl.endRefreshing()
                if conversation.hasRenderedAllChatObjects() { refreshControl.removeFromSuperview() }
                refreshControl.isEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                    refreshControl.isEnabled = true //prevent another immediate reload
                }
            }
        }
    }
    
}


// MARK: - MessageCellDelegate

extension CoordinateChatVC: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
//        handleReceiverProfileDidTapped()
    }
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        dismissKeyboard()
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        dismissKeyboard()
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        dismissKeyboard()
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        dismissKeyboard()
    }
    
    @objc func dismissKeyboard() {
        updateAdditionalBottomInsetForDismissedKeyboard()
        inputBar.inputTextView.resignFirstResponder()
    }
    
}

// MARK: - MessageLabelDelegate

extension CoordinateChatVC: MessageLabelDelegate, MFMessageComposeViewControllerDelegate {
    
    func didSelectURL(_ url: URL) {
        openURL(url)
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = [phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Helpers

extension CoordinateChatVC {
    
    func isMostRecentMessageFromSender(message: MessageType, at indexPath: IndexPath) -> Bool {
        return isLastMessage(at: indexPath) && isFromCurrentSender(message: message)
    }
    
    func isLastMessage(at indexPath: IndexPath) -> Bool {
        return indexPath.section == numberOfSections(in: messagesCollectionView) - 1
    }
        
    func isLastSectionVisible() -> Bool {
        guard numberOfSections(in: messagesCollectionView) != 0 else { return false }
        let lastIndexPath = IndexPath(item: 0, section: numberOfSections(in: messagesCollectionView) - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        guard indexPath.section > 0 else {
            return conversation.hasRenderedAllChatObjects()
        }
        let previousIndexPath = IndexPath(item: 0, section: indexPath.section-1)
        let previousItem = messageForItem(at: previousIndexPath, in: messagesCollectionView)
        let thisItem = messageForItem(at: indexPath, in: messagesCollectionView)
        let elapsedTimeSincePreviousMessage =  thisItem.sentDate.timeIntervalSince1970.getElapsedTime(since: previousItem.sentDate.timeIntervalSince1970)
        if elapsedTimeSincePreviousMessage.hours > 0 {
            return true
        }
        return false
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section > 0 else { return false }
        let previousIndexPath = IndexPath(item: 0, section: indexPath.section-1)
        let previousItem = messageForItem(at: previousIndexPath, in: messagesCollectionView)
        let thisItem = messageForItem(at: indexPath, in: messagesCollectionView)
        return thisItem.sender.senderId == previousItem.sender.senderId
    }

    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < numberOfSections(in: messagesCollectionView) else { return false }
        let nextIndexPath = IndexPath(item: 0, section: indexPath.section+1)
        let nextItem = messageForItem(at: nextIndexPath, in: messagesCollectionView)
        let thisItem = messageForItem(at: indexPath, in: messagesCollectionView)
        return thisItem.sender.senderId == nextItem.sender.senderId
    }
}
