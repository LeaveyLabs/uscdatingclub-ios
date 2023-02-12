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
import Mixpanel
import FirebaseAnalytics

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
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var timeSublabel: UILabel!
    @IBOutlet var locationImageView: UIImageView!
    @IBOutlet var locationImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var bottomStackVerticalConstraint: NSLayoutConstraint!
    @IBOutlet var locationLabel: UILabel!
    var locationImage: UIImage {
        if !locationLabel.text!.contains("<") {
            return UIImage(systemName: "location.north", withConfiguration: UIImage.SymbolConfiguration(weight: countdownStackView.axis == .horizontal ? .bold : .light))!
        } else {
            return UIImage(systemName: "figure.stand.line.dotted.figure.stand")!
        }
    }
    
    @IBOutlet var countdownBgView: UIView!
    @IBOutlet var countdownStackView: UIStackView!
    @IBOutlet var countdownToggleButton: UIButton!
    @IBOutlet var locationStackView: UIStackView!
    
    //Data
    var relativePositioning: RelativePositioning = .init(heading: 0, distance: 100)
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
        view.tintAdjustmentMode = .normal
        setupMessagesCollectionView()
        setupNavBar()
        setupKeyboard()
        setupMessageInputBarForChatting()
        setupButtons()
        setupLabels() //must come after connect manager created
        setCountdownDirection(to: .vertical, animated: false)
        locationImageView.setImage(locationImage)

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
        handleFirstLoad()
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
    
    //MARK: - Keybaord
    
    @objc func keyboardWillShow(sender: NSNotification) {
        setCountdownDirection(to: .horizontal, animated: true)
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
//        updateAdditionalBottomInsetForDismissedKeyboard()
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
//        additionalBottomInset = 52 + (window?.safeAreaInsets.bottom ?? 0)
    }
    
    //i had to add this code because scrollstolastitemonkeyboardbeginsediting doesnt work
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    func setupKeyboard() {
        messagesCollectionView.contentInsetAdjustmentBehavior = .never //dont think this does anything
        messageInputBar = inputBar
        inputBar.delegate = self
        inputBar.inputTextView.delegate = self
        
        additionalBottomInset = 5
        
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
    
    //MARK: - Setup
    
    func handleFirstLoad() {
        if let recentCoordinateDate = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.mostRecentCoordinateDate) as? Date,
           recentCoordinateDate.isMoreRecentThan(Calendar.current.date(byAdding: .minute, value: -1 * Constants.minutesToConnect, to: Date())!) {
            //is it's not the first load of this view controller during this session
        } else {
            UserDefaults.standard.set(Date(), forKey: Constants.UserDefaultsKeys.mostRecentCoordinateDate)
            AlertManager.showInfoCentered(
                "you have 5 minutes to chat & meet up!",
                "\nnote: location sharing doesn't work well underground",
                on: self)
            Mixpanel.mainInstance().track(
                event: Constants.MP.CoordinateOpen.EventName,
                properties: [Constants.MP.MatchOpen.match_id:matchInfo.matchId,
                             Constants.MP.MatchOpen.time_remaining:matchInfo.timeLeftToConnectString])
            Analytics.logEvent(Constants.MP.CoordinateOpen.EventName, parameters: [
                Constants.MP.MatchOpen.match_id:matchInfo.matchId,
                Constants.MP.MatchOpen.time_remaining:matchInfo.timeLeftToRespondString])
            Mixpanel.mainInstance().people.increment(property: Constants.MP.Profile.CoordinateOpen, by: 1)
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
        timeLabel.font = AppFont.bold.size(25)
        timeSublabel.font = AppFont.light.size(16)
        locationLabel.font = AppFont.light.size(16)
        
        timeLabel.text = matchInfo.timeLeftToConnectString
        timeSublabel.text = "left to connect"
        locationLabel.text = prettyDistance(meters: relativePositioning.distance, shortened: true)
        locationImageView.transform = CGAffineTransform.identity.rotated(by: relativePositioning.heading)
    }
        
    func setupMessagesCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.delegate = self
        
        messagesCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        //UI
        messagesCollectionView.backgroundColor = .clear
        view.backgroundColor = .tintColor
        
        //Nibs
        messagesCollectionView.register(FixedInsetTextMessageCell.self)

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
        messagesCollectionView.topAnchor.constraint(equalTo: countdownBgView.bottomAnchor, constant: -10).isActive = true
        
        countdownStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleCountdownDirection)))
        countdownStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleNavPan)))
    }
    
    func setupMessageInputBarForChatting() {
        inputBar.inputTextView.placeholder = INPUTBAR_PLACEHOLDER
        inputBar.configureForChatting()
        inputBar.delegate = self
        inputBar.inputTextView.delegate = self //does this cause issues? i'm not entirely sure
    }
    
    //MARK: - User Interaction
    
    @objc func handleNavPan(recognizer: UIPanGestureRecognizer) {
        setCountdownDirection(to: recognizer.velocity(in: view).y < 0 ? .horizontal : .vertical, animated: true)
    }
    
    func closeButtonDidPressed() {
        AlertManager.showAlert(title: "stop sharing your location with \(matchInfo.partnerName)?",
                               subtitle: "you won't be able to restart it afterwards",
                               primaryActionTitle: "stop sharing location",
                               primaryActionHandler: {
            self.stopSharingLocationAndFinish()
        },
                               secondaryActionTitle: "nevermind",
                               secondaryActionHandler: {

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
        present(ViewCompatibilityVC.create(matchInfo: matchInfo), animated: true)
    }
    
    func presentReportAlert() {
        AlertManager.showAlert(title: "would you like to report \(matchInfo.partnerName)?",
                               subtitle: "your location will stop sharing immediately",
                               primaryActionTitle: "report",
                               primaryActionHandler: {
            self.stopSharingLocationAndFinish()
        },
                               secondaryActionTitle: "nevermind",
                               secondaryActionHandler: {

        }, on: SceneDelegate.visibleViewController!)
    }
    
    @IBAction func toggleCountdownViewPressed() {
        view.endEditing(true)
        toggleCountdownDirection()
    }
    
    //MARK: - Helpers
    
    func handlePartnerStoppedSharing() {
        AlertManager.showAlert(title: "your match ended the connection",
                               subtitle: "",
                               primaryActionTitle: ":(",
                               primaryActionHandler: {
            self.stopSharingLocationAndFinish()
        }, on: self)
    }
    
    func stopSharingLocationAndFinish() {
        Task {
            do {
                try await MatchAPI.stopSharingLocation(selfId: UserService.singleton.getId(),
                                                       partnerId: matchInfo.partnerId)
                UserDefaults.standard.set(Date(), forKey: Constants.UserDefaultsKeys.mostRecentStopConnectionDate)
            } catch {
                print("FAILL")
                //post to firebase analytics
            }
            DispatchQueue.main.async {
                self.finish()
            }
        }
    }

    @MainActor
    func finish() {
        connectManager.endConnection()
        transitionToStoryboard(storyboardID: Constants.SBID.SB.Main, duration: 0.5)
    }
    
    @MainActor
    @objc func toggleCountdownDirection() {
        setCountdownDirection(to: countdownStackView.axis == .horizontal ? .vertical : .horizontal, animated: true)
    }
    
    @MainActor
    func setCountdownDirection(to newAxis: NSLayoutConstraint.Axis, animated: Bool) {
        view.layoutIfNeeded()
        locationLabel.font = newAxis == .horizontal ? AppFont.light.size(16) : AppFont.bold.size(16)
        if newAxis == .vertical {
            locationImageView.setImage(locationImage)
        }
        
        UIView.animate(withDuration: animated ? 0.3 : 0,
                       delay: 0,
                       options: .curveLinear) { [self] in
            countdownToggleButton.transform = CGAffineTransform.identity.rotated(by: newAxis == .vertical ? .pi : 0)
            countdownStackView.axis = newAxis
            bottomStackVerticalConstraint.constant = newAxis == .horizontal ? 18 : 43
            locationImageViewWidthConstraint.constant = newAxis == .horizontal ? 40 : view.frame.width * 0.5
            locationStackView.spacing = newAxis == .horizontal ? 4 : 25
            locationLabel.alpha = newAxis == .horizontal ? 0.7 : 1
            countdownStackView.spacing = newAxis == .horizontal ? -40 : 20
            locationLabel.transform = newAxis == .horizontal ? CGAffineTransform(scaleX: 1, y: 1) : CGAffineTransform(scaleX: 2, y: 2)
            view.layoutIfNeeded()
        } completion: { [self] finished in
            if newAxis == .horizontal && finished {
                locationImageView.setImage(locationImage)
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
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
    
}

//MARK: - ConnectManagerDelegate

extension CoordinateChatVC: ConnectManagerDelegate {
    
    func newSecondElapsed() {
        DispatchQueue.main.async { [self] in
            timeLabel.text = matchInfo.timeLeftToConnectString
        }
    }
    
    func timeRanOut() {
        DispatchQueue.main.async { [self] in
            view.tintAdjustmentMode = .dimmed
            AlertManager.showAlert(title: "your time to connect with " + matchInfo.partnerName + " has run out",
                                   subtitle: "",
                                   primaryActionTitle: "return home",
                                   primaryActionHandler: {
                DispatchQueue.main.async {
                    self.finish()
                }
            }, on: self)
        }
    }
    
    func newRelativePositioning(_ relativePositioning: RelativePositioning) {
        self.relativePositioning = relativePositioning
        DispatchQueue.main.async { [self] in
            locationLabel.text = prettyDistance(meters: relativePositioning.distance, shortened: false)
            locationImageView.transform = CGAffineTransform.identity.rotated(by: locationLabel.text!.contains("<") ? 0 : relativePositioning.heading)
            if locationLabel.text!.contains("<") {
                if locationImageView.transform != CGAffineTransform.identity.rotated(by: 0) {
                    locationImageView.setImage(locationImage) //update the image to "figures nearby"
                }
                locationImageView.transform = CGAffineTransform.identity.rotated(by: 0)
            } else {
                locationImageView.transform = CGAffineTransform.identity.rotated(by: relativePositioning.heading)
            }
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
            return NSAttributedString(string: "sent", attributes: [NSAttributedString.Key.font: UIFont(name: Constants.Font.Medium, size: 11)!, NSAttributedString.Key.foregroundColor: UIColor.customWhite.withAlphaComponent(0.5)])
        }
        return nil
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isTimeLabelVisible(at: indexPath) {
            return NSAttributedString(string: getFormattedTimeStringForChat(timestamp: message.sentDate.timeIntervalSince1970).lowercased(), attributes: [NSAttributedString.Key.font: UIFont(name: Constants.Font.Medium, size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.customWhite.withAlphaComponent(0.5)])
        }
        return nil
    }
    
    func messageTimestampLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: getFormattedTimeStringForChat(timestamp: message.sentDate.timeIntervalSince1970).lowercased(), attributes: [NSAttributedString.Key.font: UIFont(name: Constants.Font.Medium, size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.customWhite.withAlphaComponent(0.5)])
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
                    rerenderMessages()
                }
            } catch {
                AlertManager.displayError(error)
            }
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        //TODO later: when going onto a new line of text, recalculate inputBar like we do within the postVC
//        additionalBottomInset = 52
        messagesCollectionView.scrollToLastItem()
    }
        
    @MainActor
    func rerenderMessages() {
        if numberOfSections(in: messagesCollectionView) > 15 {
            messagesCollectionView.reloadDataAndKeepOffset()
        } else {
            messagesCollectionView.reloadData()
        }
        
        //More ideal UI, but still some issues crashing upon rapid message receiving / hitting 50 messages received
//        messagesCollectionView.performBatchUpdates({
//            messagesCollectionView.insertSections([numberOfSections(in: messagesCollectionView) - 1])
//            if numberOfSections(in: messagesCollectionView) >= 2 {
//                messagesCollectionView.reloadSections([numberOfSections(in: messagesCollectionView) - 2])
//            }
//        }) {_ in
//            self.messagesCollectionView.scrollToLastItem(animated: true)
//        }
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
    
    //Note: i don't think this function actually gets called
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .customWhite : .customBlack
    }
        
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        return MessageLabel.defaultAttributes
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .phoneNumber]
    }
        
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .customWhite.withAlphaComponent(0.2) : .customWhite
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return isFromCurrentSender(message: message) ? .bubble : .bubble
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        return
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


//Unused message rerender code:
//        let range = Range(uncheckedBounds: (0, max(0, messagesCollectionView.numberOfSections - 1)))
//        let indexSet = IndexSet(integersIn: range)
//        messagesCollectionView.reloadSections(indexSet)
//     Reload last section to update header/footer labels and insert a new one
//        UIView.animate(withDuration: <#T##TimeInterval#>, delay: <#T##TimeInterval#>, animations: <#T##() -> Void#>)
//        messagesCollectionView.reloadDataAndKeepOffset()

//        messagesCollectionView.numberOfItems(inSection: 0) //prevents an occassional crash?

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
//        })
//        messagesCollectionView.reloadDataAndKeepOffset()
