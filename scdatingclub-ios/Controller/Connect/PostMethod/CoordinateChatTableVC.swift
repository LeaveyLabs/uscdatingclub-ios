////
////  CoordinateChatTableVC.swift
////  mist-ios
////
////  Created by Adam Novak on 2022/03/12.
////
//
//import UIKit
//import Contacts
//import InputBarAccessoryView //dependency of MessageKit. If we remove MessageKit, we should install this package independently
//
//let COMMENT_PLACEHOLDER_TEXT = "comment & tag friends"
//typealias PostCompletionHandler = (() -> Void)
//
//extension AutocompleteManagerDelegate {
//    func autocompleteDidScroll() {
//        fatalError("Override this within the class")
//    }
//}
//
//class CoordinateChatTableVC: UIViewController, UIViewControllerTransitioningDelegate {
//    
//    //MARK: - Properties
//    
//    //TableView
//    var activityIndicator = UIActivityIndicatorView(style: .medium)
//    @IBOutlet var messagesTableView: UITableView!
//    
//    //CommentInput
//    let keyboardManager = KeyboardManager() //InputBarAccessoryView
//    let inputBar = InputBarAccessoryView()
//    let MAX_COMMENT_LENGTH = 499
//    
//    //Flags
//    var fromMistbox: Bool!
//    var didFailLoadingComments: Bool = false
//        
//    //Keyboard
//    var shouldStartWithRaisedKeyboard: Bool!
//    var keyboardHeight: Double = 0
//    var isKeyboardForEmojiReaction: Bool = false
//    
//    //Data
//    var postId: Int!
//
//    //MARK: - Initialization
//    
//    class func createPostVC(with post: Post, shouldStartWithRaisedKeyboard: Bool, fromMistbox: Bool = false, completionHandler: PostCompletionHandler?) -> CoordinateChatTableVC {
//        let postVC =
//        UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.Post) as! CoordinateChatTableVC
//        postVC.postId = post.id
//        postVC.shouldStartWithRaisedKeyboard = shouldStartWithRaisedKeyboard
//        postVC.didDismiss = completionHandler
//        postVC.fromMistbox = fromMistbox
//        return postVC
//    }
//    
//    //MARK: Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupTableView()
//        setupCommentInputBar()
//        loadComments()
//        setupNavBar()
//        navigationController?.fullscreenInteractivePopGestureRecognizer(delegate: self)
//        addKeyboardObservers()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        enableInteractivePopGesture()
//        inputBar.inputTextView.canBecomeFirstResponder = true // to offset viewWillDisappear
//        
//        if !DeviceService.shared.hasBeenRequestedContactsOnPost() {
//            DeviceService.shared.requestContactsOnPost()
//            requestContactsAccess { wasShownPermissionRequest in
//                DispatchQueue.main.asyncAfter(deadline: .now(), execute: { [self] in
////                    if shouldStartWithRaisedKeyboard {
////                        inputBar.inputTextView.becomeFirstResponder()
////                    }
//                })
//            }
//        } else {
////            if shouldStartWithRaisedKeyboard {
////                inputBar.inputTextView.becomeFirstResponder()
////            }
//        }
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        inputBar.inputTextView.resignFirstResponder()
//        inputBar.inputTextView.canBecomeFirstResponder = false //so it doesnt become first responder again if the swipe back gesture is cancelled halfway through
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        disableInteractivePopGesture()
//        removeKeyboardObservers()
//    }
//    
//    //MARK: - Setup
//    
//    let navBarFavoriteButton = UIButton()
//    func setupNavBar() {
//        if fromMistbox { //instead of if fromMistbox
//            navBarFavoriteButton.tintColor = .black
//            navBarFavoriteButton.setImage(UIImage(systemName: "bookmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium, scale: .default))!, for: .normal)
//            navBarFavoriteButton.setImage(UIImage(systemName: "bookmark.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium, scale: .default))!, for: .selected)
//            navBarFavoriteButton.isSelected = FavoriteService.singleton.hasFavoritedPost(post.id)
//            navBarFavoriteButton.addTarget(self, action: #selector(handleFavoriteButtonInTopCorner), for: .touchUpInside)
//            navBar.addSubview(navBarFavoriteButton)
//            navBarFavoriteButton.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                navBarFavoriteButton.topAnchor.constraint(equalTo: navBar.topAnchor, constant: 15),
//                navBarFavoriteButton.widthAnchor.constraint(equalToConstant: 25),
//                navBarFavoriteButton.heightAnchor.constraint(equalToConstant: 27),
//                navBarFavoriteButton.rightAnchor.constraint(equalTo: navBar.rightAnchor, constant: -20),
//            ])
//        }
//        navBar.configure(title: "", leftItems: [.back], rightItems: [])
//        navBar.backButton.addTarget(self, action: #selector(didPressBack), for: .touchUpInside)
//        navBar.applyVeryLightBottomOnlyShadow()
//        //        navBar.layer.shadowOpacity = 0
//        messagesTableView.tableHeaderView = UIView(frame: .init(x: 0, y: 0, width: view.bounds.width, height: 10))
//    }
//        
//    func setupTableView() {
//        messagesTableView.estimatedRowHeight = 100
//        messagesTableView.rowHeight = UITableView.automaticDimension
//        messagesTableView.dataSource = self
//        messagesTableView.separatorStyle = .none
//        messagesTableView.keyboardDismissMode = .interactive
//        messagesTableView.sectionFooterHeight = 50
//
//        tableView.register(PostCell.self, forCellReuseIdentifier: Constants.SBID.Cell.Post)
//        let commentNib = UINib(nibName: Constants.SBID.Cell.Comment, bundle: nil)
//        tableView.register(commentNib, forCellReuseIdentifier: Constants.SBID.Cell.Comment)
//        let commentHeaderNib = UINib(nibName: Constants.SBID.Cell.CommentHeaderCell, bundle: nil)
//        tableView.register(commentHeaderNib, forCellReuseIdentifier: Constants.SBID.Cell.CommentHeaderCell)
//        
//        let tableViewTap = UITapGestureRecognizer.init(target: self, action: #selector(dismissAllKeyboards))
//        messagesTableView.addGestureRecognizer(tableViewTap)
//        
//        messagesTableView.tableFooterView = activityIndicator
//    }
//    
//    func setupCommentInputBar() {
//        inputBar.delegate = self
//        inputBar.inputTextView.delegate = self
//        inputBar.configureForCommenting()
//    }
//    
//}
//
////MARK: - Nav Bar Actions
//
//extension CoordinateChatTableVC {
//    
//    @objc func handleFavoriteButtonInTopCorner() {
//        handleFavorite(postId: post.id, isAdding: !navBarFavoriteButton.isSelected)
//    }
//    
//    @objc func didPressBack() {
//        navigationController?.popViewController(animated: true)
//    }
//}
//
//extension CoordinateChatTableVC: InputBarAccessoryViewDelegate {
//    
//    // MARK: - InputBarAccessoryViewDelegate
//    
//    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//        let commentAutocompletions = extractAutocompletionsFromInputBarText()
//        let tags = turnCommentAutocompletionsIntoTags(commentAutocompletions)
//        requestPermissionToTextIfNecessary(autocompletions: commentAutocompletions, tags: tags) { [self] permission in
//            guard permission else { return }
//            DispatchQueue.main.async {
//                self.inputBar.sendButton.setTitleColor(Constants.Color.mistLilac.withAlphaComponent(0.4), for: .disabled)
//                self.inputBar.sendButton.isEnabled = false
////              inputBar.inputTextView.isEditable = false
//            }
//            Task {
//                do {
//                    let trimmedCommentText = inputBar.inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
//                    let newComment = try await CommentService.singleton.uploadComment(text: trimmedCommentText, postId: post.id, tags: tags)
//                    handleSuccessfulCommentSubmission(newComment: newComment)
//                } catch {
//                    CustomSwiftMessages.displayError(error)
//                    DispatchQueue.main.async { [weak self] in
//                        self?.inputBar.sendButton.setTitleColor(.clear, for: .disabled)
//                        self?.inputBar.sendButton.isEnabled = true
//                        self?.inputBar.inputTextView.isEditable = true
//                    }
//                }
//            }
//        }
//    }
//
//    
//    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
//        print("didchangeinputbarintrinsicsizeto:", size)
//        updateMaxAutocompleteRows(keyboardHeight: keyboardHeight)
//        updateMessageCollectionViewBottomInset()
//        tableView.keyboardDismissMode = asyncCompletions.isEmpty ? .interactive : .none
//    }
//
//    @objc func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
//        inputBar.inputTextView.placeholderLabel.isHidden = !inputBar.inputTextView.text.isEmpty
//        inputBar.sendButton.isEnabled = inputBar.inputTextView.text != ""
//    }
//    
//    //MARK: - InputBar Helpers
//    
//    @MainActor
//    func handleSuccessfulCommentSubmission(newComment: Comment) {
//        inputBar.inputTextView.text = ""
//        inputBar.invalidatePlugins()
////        inputBar.inputTextView.isEditable = true //not needed righ tnow
//        inputBar.sendButton.setTitleColor(.clear, for: .disabled)
//        inputBar.inputTextView.resignFirstResponder()
//        comments.append(newComment)
//        commentAuthors[newComment.author] = UserService.singleton.getUserAsFrontendReadOnlyUser()
//        
//        guard !activityIndicator.isAnimating else { return } //only reload data if all commentAuthors are loaded in and rendered
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            self.messagesTableView.reloadData()
//            self.scrollToBottom()
//        }
//    }
//        
//}
//
////MARK: - UITextViewDelegate
//
////NOTE: We are snatching the UITextViewDelegate from the autocompleteManager, so  make sure to call autocompleteManager.textView(...) at the end
//
//extension CoordinateChatTableVC: UITextViewDelegate {
//        
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//
//        // Don't allow whitespace as first character
//        if (text == " " || text == "\n") && textView.text.count == 0 {
//            textView.text = ""
//            return false
//        }
//        
//        guard textView.shouldChangeTextGivenMaxLengthOf(MAX_COMMENT_LENGTH, range, text) else { return false }
//        
//        return true
//    }
//    
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        //no idea why, but this delegate function is just not being called
//        //instead, we make the inputBar appear via a keyboard notification
//        print("SHOULD BEGIN EDITING")
//        inputBar.isHidden = false
//        return true
//    }
//    
//}
//
////MARK: EmojiTextFieldDelegate
//
//extension CoordinateChatTableVC: UITextFieldDelegate {
//    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        inputBar.isHidden = true
//        return true
//    }
//    
//}
//
//extension CoordinateChatTableVC {
//    
//    //MARK: - User Interaction
//        
//    @IBAction func backButtonDidPressed(_ sender: UIBarButtonItem) {
//        navigationController?.popViewController(animated: true)
//    }
//    
//    @objc func dismissAllKeyboards() {
//        view.endEditing(true)
//    }
//        
//}
//
////MARK: - Db Calls
//
//extension CoordinateChatTableVC {
//        
//    func loadComments() {
//        activityIndicator.startAnimating()
//        Task {
//            
//        }
//    }
//    
//}
//
////MARK: - TableViewDelegate
//
////extension CoordinateChatTableVC: UITableViewDelegate {
////    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
////        <#code#>
////    }
////}
//
//// MARK: - TableViewDataSource
//
//extension CoordinateChatTableVC: UITableViewDataSource {
//    
//    
//}
//
////MARK: - React interaction
//
//extension CoordinateChatTableVC {
//    
//    
////    func handleReactTap(postId: Int) {
////        isKeyboardForEmojiReaction = true
////    }
////
////    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
////        view.endEditing(true)
////        guard textField is EmojiTextField else { return false }
////        if !string.isSingleEmoji { return false }
////        postView?.handleEmojiVote(emojiString: string)
////        return false
////    }
////
////    @objc func keyboardWillChangeFrame(sender: NSNotification) {
////        let i = sender.userInfo!
////        let previousK = keyboardHeight
////        keyboardHeight = (i[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
////
////        ///don't dismiss the keyboard when toggling to emoji search, which hardly (~1px) lowers the keyboard
////        /// and which does lower the keyboard at all (0px) on largest phones
////        ///do dismiss it when toggling to normal keyboard, which more significantly (~49px) lowers the keyboard
////        if keyboardHeight < previousK - 5 {
////            if !inputBar.inputTextView.isFirstResponder { //only for emoji, not comment, keyboard
////                view.endEditing(true)
////            }
////        }
////
////        if keyboardHeight > previousK && isKeyboardForEmojiReaction { //keyboard is appearing for the first time
////            isKeyboardForEmojiReaction = false
////            if commentAuthors.keys.count > 0 { //on big phones, if you scroll before comments have rendered, you get weird behavior
////                scrollFeedToPostRightAboveKeyboard()
////            }
////        }
////
////        if keyboardHeight > 0 {
////            inputBar.isHidden = !inputBar.inputTextView.isFirstResponder
////        }
////
////    }
////
////    @objc func keyboardWillDismiss(sender: NSNotification) {
////        keyboardHeight = 0
////        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
////            self?.inputBar.isHidden = false
////        }
////    }
//    
//}
//
//extension CoordinateChatTableVC {
//    
//    //also not quite working
//    func scrollFeedToPostRightAboveKeyboard() {
//        let postIndex = 0 //because postVC
//        let postRectWithinFeed = messagesTableView.rectForRow(at: IndexPath(row: postIndex, section: 0))
//        let postBottomYWithinView = messagesTableView.convert(postRectWithinFeed, to: view).maxY
//        
//        let keyboardTopYWithinView = view.bounds.height - keyboardHeight
//        let spaceBetweenPostCellAndPostView: Double = 15
//        let desiredOffset = postBottomYWithinView - keyboardTopYWithinView - spaceBetweenPostCellAndPostView
////        if desiredOffset < 0 { return } //dont scroll up for the post
////        tableView.setContentOffset(tableView.contentOffset.applying(.init(translationX: 0, y: desiredOffset)), animated: true)
//        messagesTableView.setContentOffset(CGPoint(x: 0, y: desiredOffset), animated: true)
//        
////        tableView.setContentOffset(.init(x: 0, y: 500), animated: true)
//    }
//    
//}
