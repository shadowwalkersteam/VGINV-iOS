
//  CometChatMessageList.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatMessageList: The CometChatMessageList is a view controller with a list of messages for a particular user or group. The view controller has all the necessary delegates and methods.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */

// MARK: - Importing Frameworks.

import UIKit
import WebKit
import AVKit
import AVFoundation
import QuickLook
import AudioToolbox
import CometChatPro

enum MessageMode {
    case edit
    case send
    case reply
}

public enum Reaction {
    case heart
    case thumbsup
}

enum HideView {
    case blockedView
    case smartRepliesView
    case editMessageView
}

enum CometChatExtension {
    case linkPreview
    case smartReply
    case messageTranslation
    case thumbnailGeneration
    case imageModeration
    case profanityFilter
    case sentimentAnalysis
    case reply
    case none
}

public class Attachment : NSObject {
    var fName: String = ""
    var fileName: String {
        get {
            return fName
        }
        set (newVal) {
            fName = newVal
        }
    }
    
    var fExt: String = ""
    var fileExtension: String {
        get {
            return fExt
        }
        set (newVal) {
            fExt = newVal
        }
    }
    
    var fSize: Double = 0
    var fileSize: Double {
        get {
            return fSize
        }
        set (newVal) {
            fSize = newVal
        }
    }
    
    var fMimeType: String = ""
    var fileMimeType: String {
        get {
            return fMimeType
        }
        set (newVal) {
            fMimeType = newVal
        }
    }
    
    var fUrl: String = ""
    var fileUrl: String {
        get {
            return fUrl
        }
        set (newVal) {
            fUrl = newVal
        }
    }
}

struct LoggedInUser {
    static let uid = CometChat.getLoggedInUser()?.uid ?? ""
}

/*  ----------------------------------------------------------------------------------------- */

public class CometChatMessageList: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate {
    enum AudioRecodingState {
        case ready
        case recording
        case recorded
        case playing
        case paused
        
        var buttonImage: UIImage {
            switch self {
            case .ready, .recording:
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "pause.fill") ?? #imageLiteral(resourceName: "play")
                } else {}
            case .recorded, .paused:
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "play.fill") ?? #imageLiteral(resourceName: "play")
                } else {}
            case .playing:
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "pause.fill") ?? #imageLiteral(resourceName: "play")
                } else {}
            }
            return #imageLiteral(resourceName: "microphone")
        }
        
        var audioVisualizationMode: AudioVisualizationView.AudioVisualizationMode {
            switch self {
            case .ready, .recording:
                return .write
            case .paused, .playing, .recorded:
                return .read
            }
        }
    }
    
    // MARK: - Declaration of Outlets
    
    @IBOutlet weak var reactionView: LiveReaction!
    @IBOutlet weak var reaction: UIButton!
    @IBOutlet weak var microhone: UIButton!
    @IBOutlet weak var audioNotePauseButton: UIButton!
    @IBOutlet weak var audioNoteSendButton: UIButton!
    @IBOutlet weak var audioNoteDeleteButton: UIButton!
    @IBOutlet weak var audioNoteActionView: UIView!
    @IBOutlet weak var audioNoteTimer: UILabel!
    @IBOutlet weak var audioNoteView: UIView!
    @IBOutlet private var audioVisualizationView: AudioVisualizationView!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var chatView: ChatView!
    @IBOutlet weak var messageActionView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blockedView: UIView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editViewName: UILabel!
    @IBOutlet weak var editViewMessage: UILabel!
    @IBOutlet weak var blockedMessage: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var smartRepliesView: SmartRepliesView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet{
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    // MARK: - Declaration of Variables
    
    var currentUser: User?
    var currentGroup: Group?
    var currentReaction: Reaction = .thumbsup
    var currentEntity: CometChat.ReceiverType?
    var messageRequest:MessagesRequest?
    var memberRequest: GroupMembersRequest?
    var messages: [BaseMessage] = [BaseMessage]()
    var chatMessages: [[BaseMessage]] = [[BaseMessage]]()
    var filteredMessages:[BaseMessage] = [BaseMessage]()
    var selectedMessages:[BaseMessage] = [BaseMessage]()
    var typingIndicator: TypingIndicator?
    var safeArea: UILayoutGuide!
    let modelName = UIDevice.modelName
    var titleView : UIView?
    var buddyStatus: UILabel?
    var isGroupIs : Bool = false
    var refreshControl: UIRefreshControl!
    var membersCount:String?
    var totalHour = Int()
    var totalMinut = Int()
    var totalSecond = 0
    var timer:Timer?
    var isTimerRunning = false
    var messageMode: MessageMode = .send
    var selectedIndexPath: IndexPath?
    var selectedMessage: BaseMessage?
    lazy var previewItem = NSURL()
    var quickLook = QLPreviewController()
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var isAudioPaused : Bool = false
    private let viewModel = ViewModel()
    var audioURL:URL?
    var fileName : String?
    private var chronometer: Chronometer?
    var rawGroupMessages: [BaseMessage]? = [BaseMessage]()
    
    private var currentState: AudioRecodingState = .ready {
        didSet {
            self.audioNotePauseButton.setImage(self.currentState.buttonImage, for: .normal)
            self.audioVisualizationView.audioVisualizationMode = self.currentState.audioVisualizationMode
        }
    }
    
    let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.data","public.content","public.audiovisual-content","public.movie","public.audiovisual-content","public.video","public.audio","public.data","public.zip-archive","com.pkware.zip-archive","public.composite-content","public.text"], in: UIDocumentPickerMode.import)
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
        setupSuperview()
        setupDelegates()
        setupTableView()
        registerCells()
        setupChatView()
        setupKeyboard()
        setupRecorder()
        self.addObsevers()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        setupDelegates()
        hideSystemBackButton(bool: true)
    }
    
    
    deinit {
        print("CometChatMessageList deallocated ")
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public instance methods
    
    
    /**
     This method specifies the entity of user or group which user wants to begin the conversation.
     - Parameters:
     - conversationWith: Spcifies `AppEntity` Object which can take `User` or `Group` Object.
     - type: Spcifies a type of `AppEntity` such as `.user` or `.group`.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc public func set(conversationWith: AppEntity, type: CometChat.ReceiverType){
        switch type {
        case .user:
            isGroupIs = false
            guard let user = conversationWith as? User else{ return }
            currentUser = user
            currentEntity = .user
            fetchUserInfo(user: user)
            switch (conversationWith as? User)!.status {
            case .online:
                setupNavigationBar(withTitle: user.name?.capitalized ?? "")
                setupNavigationBar(withSubtitle: NSLocalizedString("ONLINE", comment: ""))
                setupNavigationBar(withImage: user.avatar ?? "", name: user.name ?? "", bool: true)
            case .offline:
                setupNavigationBar(withTitle: user.name?.capitalized ?? "")
                setupNavigationBar(withSubtitle: NSLocalizedString("OFFLINE", comment: ""))
                setupNavigationBar(withImage: user.avatar ?? "", name: user.name ?? "", bool: true)
            @unknown default:break
            }
            self.refreshMessageList(forID: user.uid ?? "" , type: .user, scrollToBottom: true)
            
        case .group:
            isGroupIs = true
            guard let group = conversationWith as? Group else{
                return
            }
            currentGroup = group
            currentEntity = .group
            setupNavigationBar(withTitle: group.name?.capitalized ?? "")
            if group.membersCount == 1 {
                setupNavigationBar(withSubtitle: "1 Member")
            }else {
                setupNavigationBar(withSubtitle: "\(group.membersCount) Members")
            }
            setupNavigationBar(withImage: group.icon ?? "", name: group.name ?? "", bool: true)
            fetchGroup(group: group.guid)
            self.refreshMessageList(forID: group.guid , type: .group, scrollToBottom: true)
            
        @unknown default:
            break
        }
    }
    
    public func set(liveReaction: Reaction) {
        switch liveReaction {
        case .heart:
            self.currentReaction = liveReaction
            reaction.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
            reactionView.image1 = #imageLiteral(resourceName: "heart")
        case .thumbsup:
            self.currentReaction = liveReaction
            reaction.setImage(#imageLiteral(resourceName: "thumbsup"), for: .normal)
            reactionView.image1 = #imageLiteral(resourceName: "thumbsup")
        }
    }
    
    
    // MARK: - CometChatPro Instance Methods
    
    
    /**
     This method group the new message as per timestamp and append it on UI
     - Parameters:
     - messages: Specifies the group of message containing same timestamp.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func addNewGroupedMessage(messages: [BaseMessage]){
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if messages.isEmpty { strongSelf.tableView?.setEmptyMessage("No Messages Found.")
            }else{ strongSelf.tableView?.restore() }
        }
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            self.chatMessages.append(values ?? [])
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView?.beginUpdates()
                strongSelf.hide(view: .smartRepliesView, true)
                strongSelf.tableView?.insertSections([0], with: .top)
                let lastSection = strongSelf.tableView?.numberOfSections
                strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection ?? 0].count - 1, section: lastSection ?? 0)], with: .automatic)
                strongSelf.tableView?.endUpdates()
                strongSelf.tableView?.scrollToBottomRow()
                strongSelf.chatView.textView.text = ""
            }
        }
    }
    
    /**
     This method groups the  messages as per timestamp.
     - Parameters:
     - messages: Specifies the group of message containing same timestamp.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func groupMessages(messages: [BaseMessage]){
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if messages.isEmpty { strongSelf.tableView?.setEmptyMessage("No Messages Found.")
            }else{ strongSelf.tableView?.restore() }
        }
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            self.chatMessages.append(values ?? [])
            DispatchQueue.main.async{  [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView?.reloadData()
                strongSelf.refreshControl.endRefreshing()
            }
        }
    }
    
    /**
     This method groups the  previous messages as per timestamp.
     - Parameters:
     - messages: Specifies the group of message containing same timestamp.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func groupPreviousMessages(messages: [BaseMessage]){
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        var sortedKeys = groupedMessages.keys.sorted()
        sortedKeys = sortedKeys.reversed()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            self.chatMessages.insert(values ?? [], at: 0)
            DispatchQueue.main.async{ [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView?.reloadData()
                strongSelf.refreshControl.endRefreshing()
            }
        }
    }
    
    /**
     This method fetches the older messages from the server using `MessagesRequest` class.
     - Parameter inTableView: This spesifies `Bool` value
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func fetchPreviousMessages(messageReq:MessagesRequest){
        messageReq.fetchPrevious(onSuccess: {  [weak self] (fetchedMessages) in
            guard let strongSelf = self else { return }
            if fetchedMessages?.count == 0 {
                DispatchQueue.main.async {
                    strongSelf.refreshControl.endRefreshing()
                }
            }
            guard let messages = fetchedMessages?.filter({
                ($0 as? TextMessage  != nil && $0.messageType == .text)  ||
                    ($0 as? MediaMessage != nil && $0.messageType == .image) ||
                    ($0 as? MediaMessage != nil && $0.messageType == .video) ||
                    ($0 as? MediaMessage != nil && $0.messageType == .audio) ||
                    ($0 as? MediaMessage != nil && $0.messageType == .file)  ||
                    ($0 as? Call != nil && ($0 as? Call)?.callStatus == .initiated)  ||
                    ($0 as? Call != nil && ($0 as? Call)?.callStatus == .unanswered) ||
                    ($0 as? ActionMessage != nil && (($0 as? ActionMessage)?.message != "Message is deleted." && ($0 as? ActionMessage)?.message != "Message is edited."))
            }) else { return }
            guard let lastMessage = messages.last else { return }
            if strongSelf.isGroupIs == true {
                CometChat.markAsRead(messageId: lastMessage.id, receiverId: strongSelf.currentGroup?.guid ?? "", receiverType: .group)
            }else{
                CometChat.markAsRead(messageId: lastMessage.id, receiverId: strongSelf.currentUser?.uid ?? "", receiverType: .user)
            }
            var oldMessages = [BaseMessage]()
            for msg in messages{ oldMessages.append(msg) }
            var oldMessageArray =  oldMessages
            oldMessageArray.sort { (obj1, obj2) -> Bool in
                return (obj1.sentAt) < (obj2.sentAt)
            }
            strongSelf.groupPreviousMessages(messages: oldMessageArray)
            
        }) { (error) in
            DispatchQueue.main.async {
                if let errorMessage = error?.errorDescription {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                    snackbar.show()
                }
                self.refreshControl.endRefreshing()
            }
            print("fetchPreviousMessages error: \(String(describing: error?.errorDescription))")
        }
    }
    
    
    /**
     This method refreshes the  messages  using `MessagesRequest` class.
     - Parameters:
     - forID: This specifies a string value which takes `uid` or `guid`.
     - type: This specifies `ReceiverType` Object which can be `.user` or `.group`.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func refreshMessageList(forID: String, type: CometChat.ReceiverType, scrollToBottom: Bool){
        chatMessages.removeAll()
        messages.removeAll()
        switch type {
        case .user:
            messageRequest = MessagesRequest.MessageRequestBuilder().set(uid: forID).set(limit: 30).build()
            messageRequest?.fetchPrevious(onSuccess: { [weak self] (fetchedMessages) in
                guard let strongSelf = self else { return }
                guard let messages = fetchedMessages?.filter({
                    ($0 as? TextMessage  != nil && $0.messageType == .text)  ||
                        ($0 as? MediaMessage != nil && $0.messageType == .image) ||
                        ($0 as? MediaMessage != nil && $0.messageType == .audio) ||
                        ($0 as? MediaMessage != nil && $0.messageType == .video) ||
                        ($0 as? MediaMessage != nil && $0.messageType == .file)  ||
                        ($0 as? Call != nil && ($0 as? Call)?.callStatus == .initiated)  ||
                        ($0 as? Call != nil && ($0 as? Call)?.callStatus == .unanswered) ||
                        ($0 as? ActionMessage != nil && (($0 as? ActionMessage)?.message != "Message is deleted." && ($0 as? ActionMessage)?.message != "Message is edited."))
                }) else { return }
                strongSelf.groupMessages(messages: messages)
                guard let lastMessage = messages.last else {
                    return
                }
                CometChat.markAsRead(messageId: lastMessage.id, receiverId: forID, receiverType: .user)
                strongSelf.messages.append(contentsOf: messages)
                strongSelf.filteredMessages = messages.filter {$0.sender?.uid == LoggedInUser.uid}
                DispatchQueue.main.async {
                    if lastMessage.sender?.uid != LoggedInUser.uid {
                        if let lastMessage = lastMessage as? TextMessage {
                            let titles = strongSelf.parseSmartRepliesMessages(message: lastMessage)
                            strongSelf.smartRepliesView.set(titles: titles)
                            strongSelf.hide(view: .smartRepliesView, false)
                        }
                    }else{
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                    strongSelf.tableView?.reloadData()
                    if scrollToBottom == true{
                        strongSelf.tableView?.scrollToBottomRow()
                    }
                }
                }, onError: { (error) in
                    DispatchQueue.main.async {
                        if let errorMessage = error?.errorDescription {
                            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                            snackbar.show()
                        }
                    }
                    print("error while fetching messages for user: \(String(describing: error?.errorDescription))")
            })
            typingIndicator = TypingIndicator(receiverID: forID, receiverType: .user)
        case .group:
            
//            let url = ConstantStrings.GROUP_CHATS + "/hmg"
//            CloudDataService.sharedInstance.getGroupChats(url, success: { (json) in
//                print("success")
//                for gp in json.groupChats {
//                    if (gp.message!.contains("jpeg") || gp.message!.contains("jpg") || gp.message!.contains("png")) {
//                        let user = User(uid: String((gp.groupChatSender?.id)!), name: ((gp.groupChatSender?.firstName)! + " " + (gp.groupChatSender?.lastName)!))
//                        user.role = "default"
//                        user.avatar = gp.groupChatSender?.urlToSourceLogo
//                        user.status = CometChat.UserStatus(rawValue: 0)!
//                        user.hasBlockedMe = false
//                        user.blockedByMe = false
//                        let textMessage = TextMessage(receiverUid: "", text: gp.message!, receiverType: CometChat.ReceiverType.group)
//                        textMessage.messageType = CometChat.MessageType.image
//                        textMessage.id = gp.id!
//                        textMessage.messageCategory = CometChat.MessageCategory(rawValue: 0)!
//                        textMessage.senderUid =  gp.groupChatSender?.id?.description as! String
//                        textMessage.sender = user
//                        self.rawGroupMessages!.append(textMessage)
//
//                    } else if (gp.message!.contains("mp3") || gp.message!.contains("wav")) {
//                        let user = User(uid: String((gp.groupChatSender?.id)!), name: ((gp.groupChatSender?.firstName)! + " " + (gp.groupChatSender?.lastName)!))
//                        user.role = "default"
//                        user.avatar = gp.groupChatSender?.urlToSourceLogo
//                        user.status = CometChat.UserStatus(rawValue: 0)!
//                        user.hasBlockedMe = false
//                        user.blockedByMe = false
//                        let voiceMessage = MediaMessage(receiverUid: "", fileurl: gp.urlToMedia, messageType: CometChat.MessageType.audio, receiverType: CometChat.ReceiverType.group)
//                        voiceMessage.messageType = CometChat.MessageType.audio
//                        voiceMessage.id = gp.id!
//                        voiceMessage.messageCategory = CometChat.MessageCategory(rawValue: 0)!
//                        voiceMessage.senderUid =  gp.groupChatSender?.id?.description as! String
//                        voiceMessage.sender = user
//                        voiceMessage.metaData = ["fileURL" : gp.urlToMedia]
//                        voiceMessage.filePath = gp.urlToMedia
//                        var attach : Attachment = Attachment()
//                        attach.fileName = "Voice Message"
//                        attach.fileExtension = "mp3"
//                        attach.fileSize = 1000
//                        attach.fileMimeType = "audio/mp3"
//                        attach.fileUrl = gp.urlToMedia
//                        voiceMessage.attachment = CometChatPro.Attachment(fileName: "Voice Message", fileExtension: gp.urlToMedia.pathExtension, fileSize: 1000, fileMimeType: "", fileUrl: gp.urlToMedia)
//                        voiceMessage.attachment = attach as? CometChatPro.Attachment
//                        self.rawGroupMessages!.append(voiceMessage)
//
//                    } else if (gp.message!.contains("mp4") || gp.message!.contains("mkv") || gp.message!.contains("flv")) {
//                        let user = User(uid: String((gp.groupChatSender?.id)!), name: ((gp.groupChatSender?.firstName)! + " " + (gp.groupChatSender?.lastName)!))
//                        user.role = "default"
//                        user.avatar = gp.groupChatSender?.urlToSourceLogo
//                        user.status = CometChat.UserStatus(rawValue: 0)!
//                        user.hasBlockedMe = false
//                        user.blockedByMe = false
//                        let textMessage = TextMessage(receiverUid: "", text: gp.message!, receiverType: CometChat.ReceiverType.group)
//                        textMessage.messageType = CometChat.MessageType.video
//                        textMessage.id = gp.id!
//                        textMessage.messageCategory = CometChat.MessageCategory(rawValue: 0)!
//                        textMessage.senderUid =  gp.groupChatSender?.id?.description as! String
//                        textMessage.sender = user
//                        self.rawGroupMessages!.append(textMessage)
//
//                    }
//                    else {
//                        let user = User(uid: String((gp.groupChatSender?.id)!), name: ((gp.groupChatSender?.firstName)! + " " + (gp.groupChatSender?.lastName)!))
//                        user.role = "default"
//                        user.avatar = gp.groupChatSender?.urlToSourceLogo
//                        user.status = CometChat.UserStatus(rawValue: 0)!
//                        user.hasBlockedMe = false
//                        user.blockedByMe = false
//                        let textMessage = TextMessage(receiverUid: "", text: gp.message!, receiverType: CometChat.ReceiverType.group)
//                        textMessage.messageType = CometChat.MessageType.text
//                        textMessage.id = gp.id!
//                        textMessage.messageCategory = CometChat.MessageCategory(rawValue: 0)!
//                        textMessage.senderUid =  gp.groupChatSender?.id?.description as! String
//                        textMessage.sender = user
//                        self.rawGroupMessages!.append(textMessage)
//                    }
//
//                }
//                guard let messages1 = self.rawGroupMessages?.filter({
//                    ($0 as? TextMessage  != nil && $0.messageType == .text)  ||
//                        ($0 as? MediaMessage != nil && $0.messageType == .image) ||
//                        ($0 as? MediaMessage != nil && $0.messageType == .audio) ||
//                        ($0 as? MediaMessage != nil && $0.messageType == .video) ||
//                        ($0 as? MediaMessage != nil && $0.messageType == .file)  ||
//                        ($0 as? Call != nil && ($0 as? Call)?.callStatus == .initiated)  ||
//                        ($0 as? Call != nil && ($0 as? Call)?.callStatus == .unanswered) ||
//                        ($0 as? ActionMessage != nil && (($0 as? ActionMessage)?.message != "Message is deleted." && ($0 as? ActionMessage)?.message != "Message is edited."))
//                }) else { return }
//                self.groupMessages(messages: messages1)
//                guard let lastMessage = messages1.last else {
//                    return
//                }
//                self.messages.append(contentsOf: messages1)
//                self.filteredMessages = messages1.filter {$0.sender?.uid == LoggedInUser.uid }
//
//                DispatchQueue.main.async {
//                    if lastMessage.sender?.uid != LoggedInUser.uid {
//                        if let lastMessage = lastMessage as? TextMessage {
//                            let titles = self.parseSmartRepliesMessages(message: lastMessage)
//                            self.smartRepliesView.set(titles: titles)
//                            self.hide(view: .smartRepliesView, false)
//                        }
//                    }else{
//                        self.hide(view: .smartRepliesView, true)
//                    }
//                    self.tableView?.reloadData()
//                    if scrollToBottom == true{
//                        self.tableView?.scrollToBottomRow()
//                    }
//                }
//
//            }, failure: { (error) in
//
//            })
            
            messageRequest = MessagesRequest.MessageRequestBuilder().set(guid: forID).set(limit: 30).build()
            messageRequest?.fetchPrevious(onSuccess: {[weak self] (fetchedMessages) in
                guard let strongSelf = self else { return }
                guard let messages = fetchedMessages?.filter({
                    ($0 as? TextMessage  != nil && $0.messageType == .text)  ||
                        ($0 as? MediaMessage != nil && $0.messageType == .image) ||
                        ($0 as? MediaMessage != nil && $0.messageType == .audio) ||
                        ($0 as? MediaMessage != nil && $0.messageType == .video) ||
                        ($0 as? MediaMessage != nil && $0.messageType == .file)  ||
                        ($0 as? Call != nil && ($0 as? Call)?.callStatus == .initiated)  ||
                        ($0 as? Call != nil && ($0 as? Call)?.callStatus == .unanswered) ||
                        ($0 as? ActionMessage != nil && (($0 as? ActionMessage)?.message != "Message is deleted." && ($0 as? ActionMessage)?.message != "Message is edited."))
                }) else { return }
                strongSelf.groupMessages(messages: messages)
                guard let lastMessage = messages.last else {
                    return
                }
                CometChat.markAsRead(messageId: lastMessage.id, receiverId: forID, receiverType: .group)
                strongSelf.messages.append(contentsOf: messages)
                strongSelf.filteredMessages = messages.filter {$0.sender?.uid == LoggedInUser.uid }
                DispatchQueue.main.async {
                    if lastMessage.sender?.uid != LoggedInUser.uid {
                        if let lastMessage = lastMessage as? TextMessage {
                            let titles = strongSelf.parseSmartRepliesMessages(message: lastMessage)
                            strongSelf.smartRepliesView.set(titles: titles)
                            strongSelf.hide(view: .smartRepliesView, false)
                        }
                    }else{
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                    strongSelf.tableView?.reloadData()
                    if scrollToBottom == true{
                        strongSelf.tableView?.scrollToBottomRow()
                    }
                }
                }, onError: { (error) in
                    DispatchQueue.main.async {
                        if let errorMessage = error?.errorDescription {
                            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                            snackbar.show()
                        }
                    }
                    print("error while fetching messages for group: \(String(describing: error?.errorDescription))")
            })
            typingIndicator = TypingIndicator(receiverID: forID, receiverType: .group)
        @unknown default:
            break
        }
    }
    
    /**
     This method fetches the  user information for particular user.
     - Parameter user: This specifies a  `User` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func fetchUserInfo(user: User){
        CometChat.getUser(UID: user.uid ?? "", onSuccess: { [weak self] (user) in
            guard let strongSelf = self else { return }
            if  user?.blockedByMe == true {
                if let name = strongSelf.currentUser?.name {
                    DispatchQueue.main.async {
                        strongSelf.hide(view: .blockedView, false)
                        strongSelf.blockedMessage.text = NSLocalizedString("YOU'VE_BLOCKED", comment: "") + " \(String(describing: name.capitalized))"
                    }
                }
            }
        }) { (error) in
            
            print("error while getUser info: \(String(describing: error?.errorDescription))")
        }
    }
    
    
    /**
     This method fetches list of  group members  for particular group.
     - Parameter group: This specifies a  `Group` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func fetchGroup(group: String){
        CometChat.getGroup(GUID: group, onSuccess: { [weak self] (group) in
            guard let strongSelf = self else { return }
            if  group.membersCount == 1 {
                strongSelf.setupNavigationBar(withTitle: group.name?.capitalized ?? "")
                strongSelf.setupNavigationBar(withSubtitle: "1 Member")
                strongSelf.membersCount = "1 Member"
            }else {
                strongSelf.setupNavigationBar(withTitle: group.name?.capitalized ?? "")
                strongSelf.setupNavigationBar(withSubtitle: "\(group.membersCount)" + NSLocalizedString("MEMBERS", comment: ""))
                strongSelf.membersCount = "\(group.membersCount) " + NSLocalizedString("MEMBERS", comment: "")
            }
        }) { (error) in
            print("Group Member list fetching failed with exception:" + error!.errorDescription)
        }
    }
    
    /**
     This method detects the extension is enabled or not for smart replies and link preview.
     - Parameter message: This specifies `TextMessage` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func didExtensionDetected(message: BaseMessage) -> CometChatExtension {
        var detectedExtension: CometChatExtension?
        
        if let metaData = message.metaData , let type = metaData["type"] as? String {
            if type == "reply" {
                detectedExtension = .reply
            }else{
                detectedExtension = .none
            }
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let linkPreviewDictionary = cometChatExtension["link-preview"] as? [String : Any], let linkArray = linkPreviewDictionary["links"] as? [[String: Any]], let _ = linkArray[safe: 0] {
            
            detectedExtension = .linkPreview
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["smart-reply"] as? [String : Any] {
            
            detectedExtension = .smartReply
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["message-translation"] as? [String : Any] {
            
            detectedExtension = .messageTranslation
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["thumbnail-generation"] as? [String : Any] {
            
            detectedExtension = .thumbnailGeneration
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["image-moderation"] as? [String : Any] {
            
            detectedExtension = .imageModeration
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["profanity-filter"] as? [String : Any] {
            
            detectedExtension = .profanityFilter
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["sentiment-analysis"] as? [String : Any] {
            
            detectedExtension = .profanityFilter
        }
        
        return detectedExtension ?? .none
    }
    
    
    /**
     This method parse the smart replies data from `TextMessage` Object.
     - Parameter message: This specifies `TextMessage` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func parseSmartRepliesMessages(message: TextMessage) -> [String] {
        var replyMessages: [String] = [String]()
        if  let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let smartReply = cometChatExtension["smart-reply"] as? [String : Any] {
            
            print("smartReply: \(smartReply)")
            if let positive = smartReply["reply_positive"] {
                replyMessages.append(positive as! String)
            }
            if let neutral = smartReply["reply_neutral"] {
                replyMessages.append(neutral as! String)
            }
            if let negative = smartReply["reply_negative"] {
                replyMessages.append(negative as! String)
            }
        }
        return replyMessages
    }
    
    
    
    
    // MARK: - Private instance methods
    
    /**
     This method setup the view to load CometChatMessageList.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupSuperview() {
        //        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CometChatMessageList", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view  = view
    }
    
    /**
     This method register the delegate for real time events from CometChatPro SDK.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupDelegates(){
        CometChat.messagedelegate = self
        CometChat.userdelegate = self
        CometChat.groupdelegate = self
        documentPicker.delegate = self
        smartRepliesView.smartRepliesDelegate = self
        quickLook.dataSource = self
    }
    
    
    func setupRecorder(){
        self.viewModel.askAudioRecordingPermission()
        self.viewModel.audioMeteringLevelUpdate = { [weak self] meteringLevel in
            guard let strongSelf = self, strongSelf.audioVisualizationView.audioVisualizationMode == .write else {
                return
            }
            strongSelf.audioVisualizationView.add(meteringLevel: meteringLevel)
        }
        self.viewModel.audioDidFinish = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.currentState = .recorded
            strongSelf.audioVisualizationView.stop()
        }
    }
    
    /**
     This method observers for the notifications of certain events.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func addObsevers(){
        NotificationCenter.default.addObserver(self, selector:#selector(self.didRefreshGroupDetails(_:)), name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didRefreshGroupDetails(_:)), name: NSNotification.Name(rawValue: "didRefreshMembers"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didUserBlocked(_:)), name: NSNotification.Name(rawValue: "didUserBlocked"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didUserUnblocked(_:)), name: NSNotification.Name(rawValue: "didUserUnblocked"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didGroupDeleted(_:)), name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didRefreshMembers"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didUserBlocked"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didUserUnblocked"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    /**
     This method triggers when group is deleted.
     - Parameter notification: An object containing information broadcast to registered observers
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didGroupDeleted(_ notification: NSNotification) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    /**
     This method triggers when user has been unblocked.
     - Parameter notification: An object containing information broadcast to registered observers
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didUserUnblocked(_ notification: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.hide(view: .blockedView, true)
        }
    }
    
    /**
     This method triggers when user has been blocked.
     - Parameter notification: An object containing information broadcast to registered observers
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didUserBlocked(_ notification: NSNotification) {
        if let name = notification.userInfo?["name"] as? String {
            self.hide(view: .blockedView, false)
            blockedMessage.text =
                NSLocalizedString("YOU'VE_BLOCKED", comment: "") + "\(String(describing: name.capitalized))"
        }
    }
    
    /**
     This method refreshes group details.
     - Parameter notification: An object containing information broadcast to registered observers
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didRefreshGroupDetails(_ notification: NSNotification) {
        if let guid = notification.userInfo?["guid"] as? String {
            self.refreshMessageList(forID: guid, type: .group, scrollToBottom: false)
            self.fetchGroup(group: guid)
        }
    }
    
    /**
     This method hides system defaults back button.
     - Parameter bool: specified `Bool` value.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func hideSystemBackButton(bool: Bool) {
        if self.navigationController != nil {
            if bool == true {
                self.navigationItem.hidesBackButton = false
            }
        }
    }
    
    /**
     This method setup navigationBar title for messageList viewController.
     - Parameter title: Specifies a String value for title to be displayed.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupNavigationBar(withTitle title: String){
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.navigationController != nil {
                strongSelf.addBackButton(bool: true)
                strongSelf.navigationItem.largeTitleDisplayMode = .never
                strongSelf.titleView = UIView(frame: CGRect(x: 0, y: 0, width: (strongSelf.navigationController?.navigationBar.bounds.size.width)! - 200, height: 50))
                let buddyName = UILabel(frame: CGRect(x:0,y: 3,width: 200 ,height: 21))
                strongSelf.buddyStatus = UILabel(frame: CGRect(x:0,y: (strongSelf.titleView?.frame.origin.y ?? 0.0) + 22,width: 200,height: 21))
                strongSelf.buddyStatus?.textColor = #colorLiteral(red: 0.2, green: 0.6, blue: 1, alpha: 1)
                strongSelf.buddyStatus?.font = UIFont (name: "SFProDisplay-Regular", size: 15)
                strongSelf.buddyStatus?.textAlignment = NSTextAlignment.center
                strongSelf.navigationItem.titleView = strongSelf.titleView
                if #available(iOS 13.0, *) {
                    buddyName.textColor = .label
                    buddyName.font = UIFont (name: "SFProDisplay-Medium", size: 17)
                    buddyName.textAlignment = NSTextAlignment.center
                    buddyName.text = title
                } else {
                    buddyName.textColor = .black
                    buddyName.font = UIFont (name: "SFProDisplay-Medium", size: 17)
                    buddyName.textAlignment = NSTextAlignment.center
                    buddyName.text = title
                }
                strongSelf.titleView?.addSubview(buddyName)
                strongSelf.titleView?.addSubview(strongSelf.buddyStatus!)
                strongSelf.titleView?.center = CGPoint(x: 0, y: 0)
                let tapOnTitleView = UITapGestureRecognizer(target: strongSelf, action: #selector(strongSelf.didPresentDetailView(tapGestureRecognizer:)))
                strongSelf.titleView?.isUserInteractionEnabled = true
                strongSelf.titleView?.addGestureRecognizer(tapOnTitleView)
            }
        }
    }
    
    
    /**
     This method adds back button in navigation bar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func addBackButton(bool: Bool) {
        let backButton = UIButton(type: .custom)
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal) // Image can be downloaded from here below link
        backButton.setTitle("Back".l10n(), for: .normal)
        backButton.setTitleColor(backButton.tintColor, for: .normal) // You can change the TitleColor
        backButton.addTarget(self, action: #selector(self.didBackButtonPressed(_:)), for: .touchUpInside)
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("close".l10n(), for: .normal)
        cancelButton.setTitleColor(backButton.tintColor, for: .normal) // You can change the TitleColor
        cancelButton.addTarget(self, action: #selector(self.didCancelButtonPressed(_:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = nil
        if bool == true {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }else{
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        }
    }
    
    /**
     This method triggeres when user pressed back button.
     - Parameter title: Specifies a String value for title to be displayed.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didBackButtonPressed(_ sender: UIButton) {
        if currentState == .playing {
            do {
                try self.viewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                self.showAlert(with: error)
            }
        }
        tableView = nil
        tableView?.removeFromSuperview()
        switch self.isModal() {
        case true:
            self.dismiss(animated: true, completion: nil)
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
        case false:
            let _ = self.navigationController?.popViewController(animated: true)
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
        }
        
    }
    
    @IBAction func didCancelButtonPressed(_ sender: UIButton) {
        self.didPreformCancel()
    }
    
    @IBAction func didAudioNoteDeletePressed(_ sender: UIButton) {
        if currentState == .playing {
            do {
                try self.viewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                self.showAlert(with: error)
            }
        }
        do {
            try self.viewModel.resetRecording()
            self.audioVisualizationView.reset()
            self.currentState = .ready
        } catch {
            self.showAlert(with: error)
        }
        
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            AudioServicesPlayAlertSound(SystemSoundID(1519))
            self.audioNoteView.isHidden = true
            self.audioNoteActionView.isHidden = true
            if #available(iOS 13.0, *) {
                self.audioNotePauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            self.isAudioPaused = false
        })
    }
    
    @IBAction func didAudioNoteSendPressed(_ sender: Any) {
        if currentState == .playing {
            do {
                try self.viewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                self.showAlert(with: error)
            }
        }
        if let url = self.viewModel.currentAudioRecord?.audioFilePathLocal?.absoluteURL {
            let newURL = "file://" + url.absoluteString
            self.sendMedia(withURL: newURL, type: .audio)
            UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                AudioServicesPlayAlertSound(SystemSoundID(1519))
                self.audioNoteView.isHidden = true
                self.audioNoteActionView.isHidden = true
            })
            if #available(iOS 13.0, *) {
                audioNotePauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            self.isAudioPaused = false
        }
    }
    
    
    @IBAction func didAudioNotePausePressed(_ sender: UIButton) {
        switch self.currentState {
        case .recording:
            self.chronometer?.stop()
            self.chronometer = nil
            self.viewModel.currentAudioRecord!.meteringLevels = self.audioVisualizationView.scaleSoundDataToFitScreen()
            self.audioVisualizationView.audioVisualizationMode = .read
            
            do {
                try self.viewModel.stopRecording()
                self.currentState = .recorded
            } catch {
                self.currentState = .ready
                self.showAlert(with: error)
            }
        case .recorded, .paused:
            do {
                let duration = try self.viewModel.startPlaying()
                self.currentState = .playing
                self.audioVisualizationView.meteringLevels = self.viewModel.currentAudioRecord!.meteringLevels
                self.audioVisualizationView.play(for: duration)
            } catch {
                self.showAlert(with: error)
            }
        case .playing:
            do {
                try self.viewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                self.showAlert(with: error)
            }
        default:
            break
        }
    }
    
    
    private func didPreformCancel(){
        self.selectedMessages.removeAll()
        self.selectedMessage = nil
        self.selectedIndexPath = nil
        self.tableView?.isEditing = false
        self.tableView?.reloadData()
        self.messageActionView.isHidden = true
        addBackButton(bool: true)
        
        if let user =  currentUser {
            self.setupNavigationBar(withImage: user.avatar ?? "", name: user.name ?? "", bool: true)
        }
        
        if let group = currentGroup {
            self.setupNavigationBar(withImage: group.icon ?? "", name: group.name ?? "", bool: true)
        }
    }
    
    /**
     This method setup navigationBar subtitle  for messageList viewController.
     - Parameter subtitle: Specifies a String value for title to be displayed.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupNavigationBar(withSubtitle subtitle: String){
        DispatchQueue.main.async {
            self.buddyStatus?.text = subtitle
        }
    }
    
    /**
     This method setup navigationBar subtitle  for messageList viewController.
     - Parameter URL: This spefies a string value which takes URL and loads the Avatar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupNavigationBar(withImage URL: String, name: String, bool: Bool){
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = nil
            let avatarView = UIView(frame: CGRect(x: -10 , y: 0, width: 40, height: 40))
            avatarView.backgroundColor = UIColor.clear
            avatarView.layer.masksToBounds = true
            avatarView.layer.cornerRadius = 19
            let avatar = Avatar(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            avatar.set(cornerRadius: 19).set(borderColor: .clear).set(backgroundColor: #colorLiteral(red: 0.6274509804, green: 0.7607843137, blue: 1, alpha: 1)).set(image: URL, with: name)
            avatarView.addSubview(avatar)
            let rightBarButton = UIBarButtonItem(customView: avatarView)
            let tapOnAvatar = UITapGestureRecognizer(target: self, action: #selector(self.didPresentDetailView(tapGestureRecognizer:)))
            avatarView.isUserInteractionEnabled = true
            avatarView.addGestureRecognizer(tapOnAvatar)
            if bool == true {
                self.navigationItem.rightBarButtonItem = rightBarButton
            }else{
                let copyButton = UIBarButtonItem(image: #imageLiteral(resourceName: "copy"), style: .done, target: self, action: #selector(self.didCopyButtonPressed(_:)))
                self.navigationItem.rightBarButtonItem = copyButton
            }
        }
    }
    
    
    @IBAction func didCopyButtonPressed(_ sender: UIButton) {
        if selectedMessages.isEmpty {
            DispatchQueue.main.async {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: NSLocalizedString("SELECT_A_MESSGE", comment: ""), duration: .short)
                snackbar.show()
            }
        }else{
            var messages = [String]()
            for message in selectedMessages {
                let name = message.sender?.name?.capitalized ?? ""
                let time = String().setMessageTime(time: Int(message.sentAt))
                var messageText = ""
                switch message.messageType {
                case .text: messageText = (message as? TextMessage)?.text ?? ""
                case .image: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
                case .video: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
                case .file: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
                case .custom: messageText = NSLocalizedString("CUSTOM_MESSAGE", comment: "")
                case .audio: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
                case .groupMember: break
                @unknown default: break
                }
                let message = name + "[\(time)]" + ": " + messageText
                messages.append(message)
            }
            UIPasteboard.general.string = messages.joined(separator: "\n\n")
            DispatchQueue.main.async {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: NSLocalizedString("TEXT_COPIED", comment: ""), duration: .short)
                snackbar.show()
                self.didPreformCancel()
            }
        }
    }
    /**
     This method triggers when user taps on AvatarView in Navigation var
     - Parameter tapGestureRecognizer: A concrete subclass of UIGestureRecognizer that looks for single or multiple taps.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didPresentDetailView(tapGestureRecognizer: UITapGestureRecognizer)
    {
        guard let entity = currentEntity else { return }
        switch entity{
        case .user:
            guard let user = currentUser else { return }
            if self.chatView.frame.origin.y != 0 { dismissKeyboard() }
            let userDetailView = CometChatUserDetail()
            let navigationController = UINavigationController(rootViewController: userDetailView)
            userDetailView.set(user: user)
            userDetailView.isPresentedFromMessageList = true
            self.present(navigationController, animated: true, completion: nil)
        case .group:
            guard let group = currentGroup else { return }
            let groupDetailView = CometChatGroupDetail()
            let navigationController = UINavigationController(rootViewController: groupDetailView)
            groupDetailView.set(group: group)
            self.present(navigationController, animated: true, completion: nil)
        @unknown default:break
        }
    }
    
    
    
    
    /**
     This method triggers when user long press on Particular message bubble.
     - Parameter tapGestureRecognizer: A concrete subclass of UIGestureRecognizer that looks for single or multiple taps.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didLongPressedOnMessage(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView?.indexPathForRow(at: touchPoint) {
                
                self.selectedIndexPath = indexPath
                tableView?.isEditing = true
                self.addBackButton(bool: false)
                self.setupNavigationBar(withImage: "", name: "", bool: false)
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? RightTextMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.textMessage
                    editButton.isHidden = false
                    deleteButton.isHidden = false
                    forwardButton.isHidden = false
                    messageActionView.isHidden = false
                }
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? RightReplyMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.textMessage
                    editButton.isHidden = false
                    deleteButton.isHidden = false
                    forwardButton.isHidden = false
                    messageActionView.isHidden = false
                }
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? RightFileMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.fileMessage
                    editButton.isHidden = true
                    deleteButton.isHidden = false
                    forwardButton.isHidden = false
                    messageActionView.isHidden = false
                }
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? RightAudioMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.audioMessage
                    editButton.isHidden = true
                    deleteButton.isHidden = false
                    forwardButton.isHidden = false
                    messageActionView.isHidden = false
                }
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? RightLinkPreviewBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.linkPreviewMessage
                    editButton.isHidden = true
                    deleteButton.isHidden = false
                    forwardButton.isHidden = false
                    messageActionView.isHidden = false
                }
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? RightImageMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.mediaMessage
                    editButton.isHidden = true
                    deleteButton.isHidden = false
                    forwardButton.isHidden = false
                    messageActionView.isHidden = false
                }
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? LeftTextMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    if currentGroup?.scope == .admin || currentGroup?.scope == .moderator {
                        self.selectedMessage = selectedCell.textMessage
                        editButton.isHidden = true
                        deleteButton.isHidden = false
                        forwardButton.isHidden = false
                        messageActionView.isHidden = false
                    }else{
                        self.selectedMessage = selectedCell.textMessage
                        editButton.isHidden = true
                        deleteButton.isHidden = true
                        forwardButton.isHidden = false
                        messageActionView.isHidden = false
                    }
                }
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? LeftReplyMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    if currentGroup?.scope == .admin || currentGroup?.scope == .moderator {
                        self.selectedMessage = selectedCell.textMessage
                        editButton.isHidden = true
                        deleteButton.isHidden = false
                        forwardButton.isHidden = false
                        messageActionView.isHidden = false
                    }else{
                        self.selectedMessage = selectedCell.textMessage
                        editButton.isHidden = true
                        deleteButton.isHidden = true
                        forwardButton.isHidden = false
                        messageActionView.isHidden = false
                    }
                }
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? LeftImageMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    if currentGroup?.scope == .admin || currentGroup?.scope == .moderator {
                        self.selectedMessage = selectedCell.mediaMessage
                        editButton.isHidden = true
                        deleteButton.isHidden = false
                        forwardButton.isHidden = false
                        messageActionView.isHidden = false
                    }else{
                        self.selectedMessage = selectedCell.mediaMessage
                        editButton.isHidden = true
                        deleteButton.isHidden = true
                        forwardButton.isHidden = false
                        messageActionView.isHidden = false
                    }
                }
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? LeftLinkPreviewBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    if currentGroup?.scope == .admin || currentGroup?.scope == .moderator {
                        self.selectedMessage = selectedCell.linkPreviewMessage
                        editButton.isHidden = true
                        deleteButton.isHidden = false
                        forwardButton.isHidden = false
                        messageActionView.isHidden = false
                    }else{
                        self.selectedMessage = selectedCell.linkPreviewMessage
                        editButton.isHidden = true
                        deleteButton.isHidden = true
                        forwardButton.isHidden = false
                        messageActionView.isHidden = false
                    }
                }
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? LeftFileMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    if currentGroup?.scope == .admin || currentGroup?.scope == .moderator {
                        self.selectedMessage = selectedCell.fileMessage
                        editButton.isHidden = true
                        deleteButton.isHidden = false
                        forwardButton.isHidden = false
                        messageActionView.isHidden = false
                    }else{
                        self.selectedMessage = selectedCell.fileMessage
                        editButton.isHidden = true
                        deleteButton.isHidden = true
                        forwardButton.isHidden = false
                        messageActionView.isHidden = false
                    }
                }
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? LeftAudioMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    if currentGroup?.scope == .admin || currentGroup?.scope == .moderator {
                        self.selectedMessage = selectedCell.audioMessage
                        editButton.isHidden = true
                        deleteButton.isHidden = false
                        forwardButton.isHidden = false
                        messageActionView.isHidden = false
                    }else{
                        self.selectedMessage = selectedCell.audioMessage
                        editButton.isHidden = true
                        deleteButton.isHidden = true
                        forwardButton.isHidden = false
                        messageActionView.isHidden = false
                    }
                }
                if  (tableView?.cellForRow(at: indexPath) as? ActionMessageBubble) != nil {
                    if currentGroup?.scope == .admin || currentGroup?.scope == .moderator {
                        editButton.isHidden = true
                        deleteButton.isHidden = false
                        forwardButton.isHidden = false
                        messageActionView.isHidden = false
                    }else{
                        editButton.isHidden = true
                        deleteButton.isHidden = true
                        forwardButton.isHidden = false
                        messageActionView.isHidden = false
                    }
                }
            }
        }
    }
    
    /**
     This method triggers when user pressed microphone  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didLongPressedOnMicrophone(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            self.audioNoteView.isHidden = false
            self.audioNoteActionView.isHidden = false
            if self.currentState == .ready {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.viewModel.startRecording { [weak self] soundRecord, error in
                    if let error = error {
                        self?.showAlert(with: error)
                        return
                    }
                    self?.audioNoteDeleteButton.tintColor = .systemGray
                    self?.currentState = .recording
                    self?.chronometer = Chronometer()
                    self?.chronometer?.start()
                    self?.startTimer()
                }
            }
        }else if sender.state == .ended {
            switch self.currentState {
            case .recording:
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.chronometer?.stop()
                self.chronometer = nil
                self.audioNoteDeleteButton.tintColor = .systemRed
                self.viewModel.currentAudioRecord!.meteringLevels = self.audioVisualizationView.scaleSoundDataToFitScreen()
                self.audioVisualizationView.audioVisualizationMode = .read
                do {
                    try self.viewModel.stopRecording()
                    self.currentState = .recorded
                } catch {
                    self.currentState = .ready
                    self.showAlert(with: error)
                }
            case .recorded, .paused:
                do {
                    self.totalSecond = 0
                    self.timer?.invalidate()
                    self.audioNoteDeleteButton.tintColor = UIColor.systemGray
                    let duration = try self.viewModel.startPlaying()
                    self.currentState = .playing
                    self.audioVisualizationView.meteringLevels = self.viewModel.currentAudioRecord!.meteringLevels
                    self.audioVisualizationView.play(for: duration)
                } catch {
                    self.showAlert(with: error)
                }
            case .playing:
                do {
                    self.totalSecond = 0
                    self.timer?.invalidate()
                    self.audioNoteDeleteButton.tintColor = UIColor.systemGray
                    try self.viewModel.pausePlaying()
                    self.currentState = .paused
                    self.audioVisualizationView.pause()
                } catch {
                    self.showAlert(with: error)
                }
            default:
                break
            }
        }
    }
    
    func startTimer(){
        self.audioNoteTimer.text = ""
        timer?.invalidate()
        self.totalSecond = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }
    
    @objc func countdown() {
        var hours: Int
        var minutes: Int
        var seconds: Int
        hours = totalSecond / 3600
        minutes = totalSecond / 60
        seconds = totalSecond % 60
        totalSecond = totalSecond + 1
        if currentState == .recording{
            audioNoteTimer.text = "\(hours):\(minutes):\(seconds)"
        }
    }
    /**
     This method setup the tableview to load CometChatMessageList.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupTableView() {
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.separatorColor = .clear
        self.tableView?.allowsMultipleSelectionDuringEditing = true
        self.tableView?.setEmptyMessage("Loading...")
        self.addRefreshControl(inTableView: true)
        //         Added Long Press
        let longPressOnMessage = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMessage))
        tableView?.addGestureRecognizer(longPressOnMessage)
        
        
        let longPressOnMicrophone = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMicrophone))
        microhone.addGestureRecognizer(longPressOnMicrophone)
        microhone.isUserInteractionEnabled = true
    }
    
    
    /**
     This method register All Types of MessageBubble  cells in tableView.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func registerCells(){
        
        let leftTextMessageBubble  = UINib.init(nibName: "LeftTextMessageBubble", bundle: nil)
        self.tableView?.register(leftTextMessageBubble, forCellReuseIdentifier: "leftTextMessageBubble")
        
        let rightTextMessageBubble  = UINib.init(nibName: "RightTextMessageBubble", bundle: nil)
        self.tableView?.register(rightTextMessageBubble, forCellReuseIdentifier: "rightTextMessageBubble")
        
        let leftImageMessageBubble  = UINib.init(nibName: "LeftImageMessageBubble", bundle: nil)
        self.tableView?.register(leftImageMessageBubble, forCellReuseIdentifier: "leftImageMessageBubble")
        
        let rightImageMessageBubble  = UINib.init(nibName: "RightImageMessageBubble", bundle: nil)
        self.tableView?.register(rightImageMessageBubble, forCellReuseIdentifier: "rightImageMessageBubble")
        
        let leftVideoMessageBubble  = UINib.init(nibName: "LeftVideoMessageBubble", bundle: nil)
        self.tableView?.register(leftVideoMessageBubble, forCellReuseIdentifier: "leftVideoMessageBubble")
        
        let rightVideoMessageBubble  = UINib.init(nibName: "RightVideoMessageBubble", bundle: nil)
        self.tableView?.register(rightVideoMessageBubble, forCellReuseIdentifier: "rightVideoMessageBubble")
        
        let leftFileMessageBubble  = UINib.init(nibName: "LeftFileMessageBubble", bundle: nil)
        self.tableView?.register(leftFileMessageBubble, forCellReuseIdentifier: "leftFileMessageBubble")
        
        let rightFileMessageBubble  = UINib.init(nibName: "RightFileMessageBubble", bundle: nil)
        self.tableView?.register(rightFileMessageBubble, forCellReuseIdentifier: "rightFileMessageBubble")
        
        let leftAudioMessageBubble  = UINib.init(nibName: "LeftAudioMessageBubble", bundle: nil)
        self.tableView?.register(leftAudioMessageBubble, forCellReuseIdentifier: "leftAudioMessageBubble")
        
        let rightAudioMessageBubble  = UINib.init(nibName: "RightAudioMessageBubble", bundle: nil)
        self.tableView?.register(rightAudioMessageBubble, forCellReuseIdentifier: "rightAudioMessageBubble")
        
        let actionMessageBubble  = UINib.init(nibName: "ActionMessageBubble", bundle: nil)
        self.tableView?.register(actionMessageBubble, forCellReuseIdentifier: "actionMessageBubble")
        
        let leftLinkPreviewBubble = UINib.init(nibName: "LeftLinkPreviewBubble", bundle: nil)
        self.tableView?.register(leftLinkPreviewBubble, forCellReuseIdentifier: "leftLinkPreviewBubble")
        
        let rightLinkPreviewBubble = UINib.init(nibName: "RightLinkPreviewBubble", bundle: nil)
        self.tableView?.register(rightLinkPreviewBubble, forCellReuseIdentifier: "rightLinkPreviewBubble")
        
        let leftReplyMessageBubble = UINib.init(nibName: "LeftReplyMessageBubble", bundle: nil)
        self.tableView?.register(leftReplyMessageBubble, forCellReuseIdentifier: "leftReplyMessageBubble")
        
        
        let rightReplyMessageBubble = UINib.init(nibName: "RightReplyMessageBubble", bundle: nil)
        self.tableView?.register(rightReplyMessageBubble, forCellReuseIdentifier: "rightReplyMessageBubble")
        
    }
    
    /**
     This method setup the Chat View where user can type the message or send the media.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupChatView(){
        chatView.internalDelegate = self
        chatView.textView.delegate = self
        textView.delegate = self
        textView.allowsEditingTextAttributes = true
    }
    
    /**
     This method will hide or unhide views such as blockedView, smartRepliesView and editMessageView as per user actions
     - Parameters:
     - view: This specified enum of  `HideView` which provides option such as `.blockedView`, `.smartRepliesView`,`.editMessageView`.
     - bool: specifies boolean value to hide or unhide view
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func hide(view: HideView, _ bool: Bool){
        if bool == true {
            switch view {
            case .blockedView:
                self.blockedView.isHidden = true
                self.tableViewBottomConstraint.constant = 0
            case .smartRepliesView:
                self.smartRepliesView.isHidden = true
                self.tableViewBottomConstraint.constant = 0
            case .editMessageView:
                self.editView.isHidden = true
                self.tableViewBottomConstraint.constant = 0
            }
        }else{
            switch view {
            case .blockedView:
                self.blockedView.isHidden = false
                self.tableViewBottomConstraint.constant = 110
            case .smartRepliesView:
                if !smartRepliesView.buttontitles.isEmpty {
                    self.smartRepliesView.isHidden = false
                    self.tableViewBottomConstraint.constant = 66
                    self.tableView?.scrollToBottomRow()
                }
            case .editMessageView:
                self.editView.isHidden = false
                self.tableViewBottomConstraint.constant = 66
            }
        }
    }
    
    /**
     This method add refresh control in tableview by using user will be able to load previous messages.
     - Parameter inTableView: This spesifies `Bool` value
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func addRefreshControl(inTableView: Bool){
        if inTableView == true{
            // Added Refresh Control
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(loadPreviousMessages), for: .valueChanged)
            tableView?.refreshControl = refreshControl
        }
    }
    
    /**
     This method add pull the list of privous messages when refresh control is triggered.
     - Parameter inTableView: This spesifies `Bool` value
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func loadPreviousMessages(_ sender: Any) {
        guard let request = messageRequest else {
            return
        }
        fetchPreviousMessages(messageReq: request)
    }
    
    
    /**
     This method handles  keyboard  events triggered by the Chat View.
     - Parameter inTableView: This spesifies `Bool` value
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupKeyboard(){
        chatView.textView.layer.cornerRadius = 4.0
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView?.addGestureRecognizer(tapGesture)
    }
    
    
    
    /**
     This method triggers when keyboard will change its frame.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            textViewBottomConstraint.constant = keyboardHeight + 8
            view.layoutIfNeeded()
        }
    }
    
    /**
     This method handles  keyboard  events triggered by the Chat View.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /**
     This method triggeres when user pressed the unblock button when the user is blocked.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didUnblockedUserPressed(_ sender: Any) {
        dismissKeyboard()
        if let uid =  currentUser?.uid {
            CometChat.unblockUsers([uid], onSuccess: { (success) in
                DispatchQueue.main.async {
                    self.hide(view: .blockedView, true)
                }
            }) { (error) in
                DispatchQueue.main.async {
                    if let errorMessage = error?.errorDescription {
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                        snackbar.show()
                    }
                }
                print("error while unblocking the user: \(String(describing: error?.errorDescription))")
            }
        }
    }
    
    
    /**
     This method triggeres when user pressed delete message button.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didDeleteMessageButtonPressed(_ sender: Any) {
        if selectedMessages.isEmpty {
            DispatchQueue.main.async {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: NSLocalizedString("SELECT_A_MESSGE", comment: ""), duration: .short)
                snackbar.show()
            }
        }else{
            guard let message = selectedMessages.first else { return }
            guard let indexPath = selectedIndexPath else { return }
            CometChat.delete(messageId: message.id, onSuccess: { (deletedMessage) in
                let textMessage:BaseMessage = (deletedMessage as? ActionMessage)?.actionOn as! BaseMessage
                if let row = self.chatMessages[indexPath.section].firstIndex(where: {$0.id == textMessage.id}) {
                    self.chatMessages[indexPath.section][row] = textMessage
                }
                DispatchQueue.main.async {
                    self.tableView?.reloadRows(at: [indexPath], with: .automatic)
                    self.didPreformCancel()
                }
            }) { (error) in
                DispatchQueue.main.async {
                    let errorMessage = error.errorDescription
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                    snackbar.show()
                    self.didPreformCancel()
                }
                print("unable to delete message: \(error.errorDescription)")
            }
        }
    }
    
    /**
     This method triggeres when user pressed forward message button.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    
    @IBAction func didForwardMessageButtonPressed(_ sender: Any) {
        if selectedMessages.isEmpty {
            DispatchQueue.main.async {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: NSLocalizedString("SELECT_A_MESSGE", comment: ""), duration: .short)
                snackbar.show()
            }
        }else{
            if let message = selectedMessages.first {
                let forwardMessageList = CometChatForwardMessageList()
                forwardMessageList.set(message: message)
                navigationController?.pushViewController(forwardMessageList, animated: true)
                self.didPreformCancel()
            }
        }
    }
    
    
    @IBAction func didShareButtonPressed(_ sender: Any) {
        if selectedMessages.isEmpty {
            DispatchQueue.main.async {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: NSLocalizedString("SELECT_A_MESSGE", comment: ""), duration: .short)
                snackbar.show()
            }
        }else{
            if let message = selectedMessages.first {
                var textToShare = ""
                messageActionView.isHidden = true
                if message.messageType == .text {
                    if message.receiverType == .user{
                        textToShare = (message as? TextMessage)?.text ?? ""
                    }else{
                        if let name = (message as? TextMessage)?.sender?.name , let text = (message as? TextMessage)?.text {
                            textToShare = name + " : " + text
                        }
                    }
                }else if message.messageType == .audio ||  message.messageType == .file ||  message.messageType == .image || message.messageType == .video {
                    
                    if message.receiverType == .user{
                        textToShare = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
                    }else{
                        if let name = (message as? MediaMessage)?.sender?.name, let url =  (message as? MediaMessage)?.attachment?.fileUrl {
                            textToShare = name + " : " +  url
                        }
                    }
                }
                let sendItems = [ textToShare]
                let activityViewController = UIActivityViewController(activityItems: sendItems, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                activityViewController.excludedActivityTypes = [.airDrop]
                self.present(activityViewController, animated: true, completion: nil)
                self.didPreformCancel()
            }
        }
    }
    
    
    /**
     This method triggeres when user pressed edit message button.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didEditMessageButtonPressed(_ sender: Any) {
        if selectedMessages.isEmpty {
            DispatchQueue.main.async {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: NSLocalizedString("SELECT_A_MESSGE", comment: ""), duration: .short)
                snackbar.show()
            }
        }else{
            self.messageMode = .edit
            self.messageActionView.isHidden = true
            self.hide(view: .editMessageView, false)
            guard let message = selectedMessages.first else { return }
            
            editViewName.text = "Edit Message"
            
            if let message = (message as? TextMessage)?.text {
                editViewMessage.text = message
                textView.text = message
            }
        }
    }
    
    
    @IBAction func didReplyButtonPressed(_ sender: Any) {
        if selectedMessages.isEmpty {
            DispatchQueue.main.async {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: NSLocalizedString("SELECT_A_MESSGE", comment: ""), duration: .short)
                snackbar.show()
            }
        }else{
            self.messageMode = .reply
            self.messageActionView.isHidden = true
            self.hide(view: .editMessageView, false)
            guard let message = selectedMessages.first else { return }
            if let name = message.sender?.name {
                editViewName.text = name.capitalized
            }
            switch message.messageType {
            case .text: editViewMessage.text = (message as? TextMessage)?.text
            case .image: editViewMessage.text = "📸 Photo"
            case .video: editViewMessage.text = "📹 Video"
            case .audio: editViewMessage.text = "🎵 Audio"
            case .file: editViewMessage.text = "📁 Document"
            case .custom: break
            case .groupMember: break
            @unknown default: break }
        }
    }
    
    /**
     This method triggeres when user pressed close  button on present on edit view.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didEditCloseButtonPressed(_ sender: Any) {
        self.hide(view: .editMessageView, true)
        self.didPreformCancel()
        textView.text = nil
    }
    
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
}
/*  ----------------------------------------------------------------------------------------- */

// MARK: - UIDocumentPickerDelegate 

extension CometChatMessageList: UIDocumentPickerDelegate {
    
    /// This method triggers when we open document menu to send the message of type `File`.
    /// - Parameters:
    ///   - controller: A view controller that provides access to documents or destinations outside your app’s sandbox.
    ///   - urls: A value that identifies the location of a resource, such as an item on a remote server or the path to a local file.
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            // This is what it should be
            var mediaMessage: MediaMessage?
            var lastSection = 0
            if chatMessages.count == 0 {
                lastSection = (self.tableView?.numberOfSections ?? 0)
            }else {
                lastSection = (self.tableView?.numberOfSections ?? 0) - 1
            }
            CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
            switch self.isGroupIs {
            case true:
                mediaMessage = MediaMessage(receiverUid: currentGroup?.guid ?? "", fileurl: urls[0].absoluteString,messageType: .file, receiverType: .group)
                mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                mediaMessage?.sender?.uid = LoggedInUser.uid
                mediaMessage?.senderUid = LoggedInUser.uid
                mediaMessage?.metaData = ["fileURL":urls[0].absoluteString]
                if let message = mediaMessage {
                    if chatMessages.count == 0 {
                        self.addNewGroupedMessage(messages: [mediaMessage!])
                        self.filteredMessages.append(mediaMessage!)
                    }else{
                        self.chatMessages[lastSection].append(message)
                        self.filteredMessages.append(message)
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.tableView?.beginUpdates()
                            strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                            strongSelf.tableView?.endUpdates()
                            strongSelf.tableView?.scrollToBottomRow()
                        }
                    }
                    CometChat.sendMediaMessage(message: message, onSuccess: { (message) in
                        if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                            self.chatMessages[lastSection][row] = message
                        }
                        DispatchQueue.main.async{ [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.tableView?.reloadData()}
                    }) { (error) in
                        
                        DispatchQueue.main.async {
                            if let errorMessage = error?.errorDescription {
                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                                snackbar.show()
                            }
                        }
                        print("sendMediaMessage error: \(String(describing: error?.errorDescription))")
                    }
                }
            case false:
                mediaMessage = MediaMessage(receiverUid: currentUser?.uid ?? "", fileurl: urls[0].absoluteString, messageType: .file, receiverType: .user)
                mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                mediaMessage?.sender?.uid = LoggedInUser.uid
                mediaMessage?.senderUid = LoggedInUser.uid
                mediaMessage?.metaData = ["fileURL":urls[0].absoluteString]
                if let message = mediaMessage {
                    if chatMessages.count == 0 {
                        self.addNewGroupedMessage(messages: [mediaMessage!])
                        self.filteredMessages.append(mediaMessage!)
                    }else{
                        self.chatMessages[lastSection].append(message)
                        self.filteredMessages.append(message)
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.tableView?.beginUpdates()
                            strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                            strongSelf.tableView?.endUpdates()
                            strongSelf.tableView?.scrollToBottomRow()
                        }
                    }
                    CometChat.sendMediaMessage(message: message, onSuccess: { (message) in
                        if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                            self.chatMessages[lastSection][row] = message
                        }
                        DispatchQueue.main.async{ [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.tableView?.reloadData()}
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let errorMessage = error?.errorDescription {
                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                                snackbar.show()
                            }
                        }
                        print("sendMediaMessage error: \(String(describing: error?.errorDescription))")
                    }
                }
            }
        }
    }
    
    fileprivate func addSwipeGestureForMessage(cell: UITableViewCell, message: BaseMessage) {
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(didSwipedOnCell))
        cell.addGestureRecognizer(swipeGesture)
        swipeGesture.delegate = self
        self.selectedMessage = message
    }
    
    @objc func didSwipedOnCell(recognizer: UIPanGestureRecognizer){
        if let senderView = recognizer.view {
            switch recognizer.state {
            case .possible,.began,.changed:
                
                let translation = recognizer.translation(in: view)
                if (recognizer.view?.frame.origin.x)! < 0.0 {
                    return
                }
                senderView.center = CGPoint(x: senderView.center.x + translation.x, y: senderView.center.y)
                recognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
                if senderView.frame.origin.x > UIScreen.main.bounds.size.width * 0.9 {
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                        senderView.frame = CGRect(x: 0.0, y: senderView.frame.origin.y, width: senderView.frame.size.width, height: senderView.frame.size.height)
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    })
                }
            case .ended:
                let x = senderView.frame.origin.x
                let y = senderView.frame.origin.y
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut,
                               animations: {
                                senderView.frame = CGRect(x: 0, y: y, width: senderView.frame.size.width, height: senderView.frame.size.height)
                }) { (finished) in
                    if x > (senderView.frame.size.width/3){
                        self.chatView.textView.becomeFirstResponder()
                        self.hide(view: .editMessageView, false)
                        self.messageMode = .reply
                        self.messageActionView.isHidden = true
                        self.hide(view: .editMessageView, false)
                        let point = recognizer.location(in: self.tableView)
                        if let indexPath = self.tableView?.indexPathForRow(at: point), let selectedCell = self.tableView?.cellForRow(at: indexPath) as? LeftTextMessageBubble,let message = selectedCell.message.text, let name = selectedCell.textMessage?.sender?.name{
                            
                            self.editViewName.text = name.capitalized
                            self.editViewMessage.text = message
                            
                        }else if let indexPath = self.tableView?.indexPathForRow(at: point), let selectedCell = self.tableView?.cellForRow(at: indexPath) as? RightTextMessageBubble, let message = selectedCell.message.text, let name = selectedCell.textMessage?.sender?.name{
                            
                            self.editViewName.text = name.capitalized
                            self.editViewMessage.text = message
                            
                        }else if let indexPath = self.tableView?.indexPathForRow(at: point), let selectedCell = self.tableView?.cellForRow(at: indexPath) as? LeftImageMessageBubble, let message = selectedCell.mediaMessage, let name = message.sender?.name{
                            
                            self.editViewName.text = name.capitalized
                            self.editViewMessage.text = "📸 Photo"
                            
                        }else if let indexPath = self.tableView?.indexPathForRow(at: point), let selectedCell = self.tableView?.cellForRow(at: indexPath) as? RightImageMessageBubble, let message = selectedCell.mediaMessage, let name = message.sender?.name{
                            
                            self.editViewName.text = name.capitalized
                            self.editViewMessage.text = "📸 Photo"
                            
                        }else if let indexPath = self.tableView?.indexPathForRow(at: point), let selectedCell = self.tableView?.cellForRow(at: indexPath) as? LeftVideoMessageBubble, let message = selectedCell.mediaMessage, let name = message.sender?.name{
                            
                            self.editViewName.text = name.capitalized
                            self.editViewMessage.text = "📹 Video"
                            
                        }else if let indexPath = self.tableView?.indexPathForRow(at: point), let selectedCell = self.tableView?.cellForRow(at: indexPath) as? RightVideoMessageBubble, let message = selectedCell.mediaMessage, let name = message.sender?.name{
                            
                            self.editViewName.text = name.capitalized
                            self.editViewMessage.text = "📹 Video"
                            
                        }else if let indexPath = self.tableView?.indexPathForRow(at: point), let selectedCell = self.tableView?.cellForRow(at: indexPath) as? LeftAudioMessageBubble, let message = selectedCell.audioMessage, let name = message.sender?.name{
                            
                            self.editViewName.text = name.capitalized
                            self.editViewMessage.text = "🎵 Audio"
                            
                        }else if let indexPath = self.tableView?.indexPathForRow(at: point), let selectedCell = self.tableView?.cellForRow(at: indexPath) as? RightAudioMessageBubble, let message = selectedCell.audioMessage, let name = message.sender?.name{
                            
                            self.editViewName.text = name.capitalized
                            self.editViewMessage.text = "🎵 Audio"
                            
                        }else if let indexPath = self.tableView?.indexPathForRow(at: point), let selectedCell = self.tableView?.cellForRow(at: indexPath) as? LeftFileMessageBubble, let message = selectedCell.fileMessage, let name = message.sender?.name{
                            
                            self.editViewName.text = name.capitalized
                            self.editViewMessage.text = "📁 Document"
                            
                        }else if let indexPath = self.tableView?.indexPathForRow(at: point), let selectedCell = self.tableView?.cellForRow(at: indexPath) as? RightFileMessageBubble, let message = selectedCell.fileMessage, let name = message.sender?.name{
                            
                            self.editViewName.text = name.capitalized
                            self.editViewMessage.text = "📁 Document"
                            
                        }else if let indexPath = self.tableView?.indexPathForRow(at: point), let selectedCell = self.tableView?.cellForRow(at: indexPath) as? LeftReplyMessageBubble, let message = selectedCell.textMessage, let name = message.sender?.name{
                            
                            self.editViewName.text = name.capitalized
                            self.editViewMessage.text = message.text
                            
                        }else if let indexPath = self.tableView?.indexPathForRow(at: point), let selectedCell = self.tableView?.cellForRow(at: indexPath) as? RightReplyMessageBubble, let message = selectedCell.textMessage, let name = message.sender?.name{
                            
                            self.editViewName.text = name.capitalized
                            self.editViewMessage.text = message.text
                            
                        }else if let indexPath = self.tableView?.indexPathForRow(at: point), let selectedCell = self.tableView?.cellForRow(at: indexPath) as? LeftLinkPreviewBubble, let message = selectedCell.linkPreviewMessage, let name = message.sender?.name{
                            
                            self.editViewName.text = name.capitalized
                            self.editViewMessage.text = message.text
                            
                        }else if let indexPath = self.tableView?.indexPathForRow(at: point), let selectedCell = self.tableView?.cellForRow(at: indexPath) as? RightLinkPreviewBubble, let message = selectedCell.linkPreviewMessage, let name = message.sender?.name{
                            
                            self.editViewName.text = name.capitalized
                            self.editViewMessage.text = message.text
                            
                        }
                    }
                }
            case .cancelled: break
            case .failed: break
            @unknown default: break
            }
        }
        
    }
    
    
    
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods

extension CometChatMessageList: UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies the number of sections to display list of messages.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        if chatMessages.isEmpty {
            return 0
        }else {
            return chatMessages.count
        }
    }
    
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let firstMessageInSection = chatMessages[section].first {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let dateString = String().setMessageDateHeader(time: Int(firstMessageInSection.sentAt))
            let label = MessageDateHeader()
            if dateString == "01/01/1970" {
                label.text = NSLocalizedString("TODAY", comment: "")
            }else{
                label.text = dateString
            }
            let containerView = UIView()
            containerView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            return containerView
        }
        return nil
    }
    
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    /// This method specifiesnumber of rows in CometChatMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages[section].count
    }
    
    /// This method specifies the height for row in CometChatMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    
    /// This method specifies the height for row in CometChatMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /// This method specifies the view for message  in CometChatMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell()
        if let message = chatMessages[indexPath.section][safe: indexPath.row] {
            if message.messageCategory == .message {
                if message.deletedAt > 0.0 && message.senderUid != LoggedInUser.uid {
                    let  deletedCell = tableView.dequeueReusableCell(withIdentifier: "leftTextMessageBubble", for: indexPath) as! LeftTextMessageBubble
                    deletedCell.deletedMessage = message
                    return deletedCell
                    
                }else if message.deletedAt > 0.0 && message.senderUid == LoggedInUser.uid {
                    
                    let deletedCell = tableView.dequeueReusableCell(withIdentifier: "rightTextMessageBubble", for: indexPath) as! RightTextMessageBubble
                    deletedCell.deletedMessage = message
                    if  chatMessages[indexPath.section][safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                        deletedCell.receiptStack.isHidden = false
                    }else{
                        deletedCell.receiptStack.isHidden = true
                    }
                    return deletedCell
                }else{
                    switch message.messageType {
                    case .text where message.senderUid != LoggedInUser.uid:
                        if let textMessage = message as? TextMessage {
                            let isContainsExtension = didExtensionDetected(message: textMessage)
                            switch isContainsExtension {
                            case .linkPreview:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftLinkPreviewBubble", for: indexPath) as! LeftLinkPreviewBubble
                                let linkPreviewMessage = message as? TextMessage
                                receiverCell.linkPreviewMessage = linkPreviewMessage
                                receiverCell.linkPreviewDelegate = self
                                self.addSwipeGestureForMessage(cell: receiverCell, message: message)
                                return receiverCell
                            case .reply:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftReplyMessageBubble", for: indexPath) as! LeftReplyMessageBubble
                                receiverCell.indexPath = indexPath
                                receiverCell.delegate = self
                                receiverCell.textMessage = textMessage
                                self.addSwipeGestureForMessage(cell: receiverCell, message: message)
                                return receiverCell
                            case .smartReply,.messageTranslation, .profanityFilter, .sentimentAnalysis, .none:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftTextMessageBubble", for: indexPath) as! LeftTextMessageBubble
                                receiverCell.indexPath = indexPath
                                receiverCell.delegate = self
                                receiverCell.textMessage = textMessage
                                self.addSwipeGestureForMessage(cell: receiverCell, message: message)
                                
                                return receiverCell
                                
                            case .thumbnailGeneration, .imageModeration: break
                                
                            }
                        }
                    case .text where message.senderUid == LoggedInUser.uid:
                        if let textMessage = message as? TextMessage {
                            let isContainsExtension = didExtensionDetected(message: textMessage)
                            switch isContainsExtension {
                            case .linkPreview:
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightLinkPreviewBubble", for: indexPath) as! RightLinkPreviewBubble
                                let linkPreviewMessage = message as? TextMessage
                                senderCell.linkPreviewMessage = linkPreviewMessage
                                senderCell.linkPreviewDelegate = self
                                self.addSwipeGestureForMessage(cell: senderCell, message: message)
                                if  chatMessages[indexPath.section][safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                    senderCell.receiptStack.isHidden = false
                                }else{
                                    senderCell.receiptStack.isHidden = true
                                }
                                return senderCell
                            case .reply:
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightReplyMessageBubble", for: indexPath) as! RightReplyMessageBubble
                                senderCell.textMessage = textMessage
                                senderCell.indexPath = indexPath
                                self.addSwipeGestureForMessage(cell: senderCell, message: message)
                                
                                if  chatMessages[indexPath.section][safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                    senderCell.receiptStack.isHidden = false
                                }else{
                                    senderCell.receiptStack.isHidden = true
                                }
                                return senderCell
                                
                            case .smartReply,.messageTranslation, .profanityFilter, .sentimentAnalysis, .none:
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightTextMessageBubble", for: indexPath) as! RightTextMessageBubble
                                senderCell.textMessage = textMessage
                                senderCell.indexPath = indexPath
                                self.addSwipeGestureForMessage(cell: senderCell, message: message)
                            
                                if  chatMessages[indexPath.section][safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                    senderCell.receiptStack.isHidden = false
                                }else{
                                    senderCell.receiptStack.isHidden = true
                                }
                                
                                return senderCell
                            case .thumbnailGeneration, .imageModeration: break
                            
                            }
                        }
                    case .image where message.senderUid != LoggedInUser.uid:
                        
                        if let imageMessage = message as? MediaMessage {
                            let isContainsExtension = didExtensionDetected(message: imageMessage)
                            switch isContainsExtension {
                            case .linkPreview, .smartReply, .messageTranslation, .profanityFilter,.sentimentAnalysis, .reply: break
                            case .thumbnailGeneration, .imageModeration,.none:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftImageMessageBubble", for: indexPath) as! LeftImageMessageBubble
                                receiverCell.mediaMessage = imageMessage
                                self.addSwipeGestureForMessage(cell: receiverCell, message: message)
                                return receiverCell
                            }
                        }
                        
                    case .image where message.senderUid == LoggedInUser.uid:
                        
                        if let imageMessage = message as? MediaMessage {
                            let isContainsExtension = didExtensionDetected(message: imageMessage)
                            switch isContainsExtension {
                            case .linkPreview, .smartReply, .messageTranslation, .profanityFilter,.sentimentAnalysis, .reply: break
                            case .thumbnailGeneration, .imageModeration,.none:
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightImageMessageBubble", for: indexPath) as! RightImageMessageBubble
                                senderCell.mediaMessage = imageMessage
                                self.addSwipeGestureForMessage(cell: senderCell, message: message)
                                if  chatMessages[indexPath.section][safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                    senderCell.receiptStack.isHidden = false
                                }else{
                                    senderCell.receiptStack.isHidden = true
                                }
                                return senderCell
                            }
                        }
                    case .video where message.senderUid != LoggedInUser.uid:
                        if let videoMessage = message as? MediaMessage {
                            let isContainsExtension = didExtensionDetected(message: videoMessage)
                            switch isContainsExtension {
                            case .linkPreview, .smartReply, .messageTranslation, .profanityFilter,.sentimentAnalysis, .imageModeration, .reply: break
                            case .thumbnailGeneration,.none:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftVideoMessageBubble", for: indexPath) as! LeftVideoMessageBubble
                                receiverCell.mediaMessage = videoMessage
                                self.addSwipeGestureForMessage(cell: receiverCell, message: message)
                                return receiverCell
                            }
                        }
                    case .video where message.senderUid == LoggedInUser.uid:
                        if let videoMessage = message as? MediaMessage {
                            let isContainsExtension = didExtensionDetected(message: videoMessage)
                            switch isContainsExtension {
                            case .linkPreview, .smartReply, .messageTranslation, .profanityFilter,.sentimentAnalysis, .imageModeration, .reply: break
                            case .thumbnailGeneration,.none:
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightVideoMessageBubble", for: indexPath) as! RightVideoMessageBubble
                                senderCell.mediaMessage = videoMessage
                                self.addSwipeGestureForMessage(cell: senderCell, message: message)
                                if  chatMessages[indexPath.section][safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                    senderCell.receiptStack.isHidden = false
                                }else{
                                    senderCell.receiptStack.isHidden = true
                                }
                                return senderCell
                            }
                        }
                    case .audio where message.senderUid != LoggedInUser.uid:
                        
                        if let audioMessage = message as? MediaMessage {
                            let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftAudioMessageBubble", for: indexPath) as! LeftAudioMessageBubble
                            receiverCell.audioMessage = audioMessage
                            return receiverCell
                        }
                    case .audio where message.senderUid == LoggedInUser.uid:
                        if let audioMessage = message as? MediaMessage {
                            let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightAudioMessageBubble", for: indexPath) as! RightAudioMessageBubble
                            senderCell.audioMessage = audioMessage
                            self.addSwipeGestureForMessage(cell: senderCell, message: message)
                            if  chatMessages[indexPath.section][safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                senderCell.receiptStack.isHidden = false
                            }else{
                                senderCell.receiptStack.isHidden = true
                            }
                            return senderCell
                        }
                    case .file where message.senderUid != LoggedInUser.uid:
                        if let fileMessage = message as? MediaMessage {
                            let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftFileMessageBubble", for: indexPath) as! LeftFileMessageBubble
                            receiverCell.fileMessage = fileMessage
                            self.addSwipeGestureForMessage(cell: receiverCell, message: message)
                            return receiverCell
                        }
                    case .file where message.senderUid == LoggedInUser.uid:
                        if let fileMessage = message as? MediaMessage {
                            let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightFileMessageBubble", for: indexPath) as! RightFileMessageBubble
                            senderCell.fileMessage = fileMessage
                            self.addSwipeGestureForMessage(cell: senderCell, message: message)
                            if  chatMessages[indexPath.section][safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                senderCell.receiptStack.isHidden = false
                            }else{
                                senderCell.receiptStack.isHidden = true
                            }
                            return senderCell
                        }
                    case .custom: break
                    case .groupMember:  break
                    case .image: break
                    case .text: break
                    case .file: break
                    case .video: break
                    case .audio: break
                    @unknown default: fatalError()
                    }
                }
            }else if message.messageCategory == .action {
                //  ActionMessage Cell
                let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
                let actionMessage = message as? ActionMessage
                actionMessageCell.message.text = actionMessage?.message
                return actionMessageCell
            }else if message.messageCategory == .call {
                //  CallMessage Cell
                let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
                actionMessageCell.call = message
                return actionMessageCell
            }else if message.messageCategory == .custom {
                
                //  CustomMessage Cell
                let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
                let customMessage = message as? CustomMessage
                receiverCell.message.text = NSLocalizedString("CUSTOM_MESSAGE", comment: "") +  "\(String(describing: customMessage?.customData))"
                return receiverCell
            }
        }
        return cell
    }
    
    
    /// This method triggers when particular cell is clicked by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.beginUpdates()
        
        UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightTextMessageBubble, let message =  selectedCell.textMessage {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true && selectedCell.textMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftTextMessageBubble, let message = selectedCell.textMessage {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true && selectedCell.textMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftReplyMessageBubble, let message = selectedCell.textMessage {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true && selectedCell.textMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightReplyMessageBubble, let message = selectedCell.textMessage {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true && selectedCell.textMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightImageMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.mediaMessage) {
                        self.selectedMessages.append(selectedCell.mediaMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.mediaMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightVideoMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.mediaMessage) {
                        self.selectedMessages.append(selectedCell.mediaMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.mediaMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            var player = AVPlayer()
                            if let videoURL = fileURL,
                                let url = URL(string: videoURL.absoluteString) {
                                player = AVPlayer(url: url)
                            }
                            DispatchQueue.main.async{[weak self] in
                                let playerViewController = AVPlayerViewController()
                                playerViewController.player = player
                                self?.present(playerViewController, animated: true) {
                                    playerViewController.player!.play()
                                }
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftImageMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.mediaMessage) {
                        self.selectedMessages.append(selectedCell.mediaMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.mediaMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if let selectedCell = tableView.cellForRow(at: indexPath) as? LeftVideoMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.mediaMessage) {
                        self.selectedMessages.append(selectedCell.mediaMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.mediaMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            var player = AVPlayer()
                            if let videoURL = fileURL,
                                let url = URL(string: videoURL.absoluteString) {
                                player = AVPlayer(url: url)
                            }
                            DispatchQueue.main.async{ [weak self] in
                                let playerViewController = AVPlayerViewController()
                                playerViewController.player = player
                                self?.present(playerViewController, animated: true) {
                                    playerViewController.player!.play()
                                }
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightFileMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.fileMessage) {
                        self.selectedMessages.append(selectedCell.fileMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.fileMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftFileMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.fileMessage) {
                        self.selectedMessages.append(selectedCell.fileMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.fileMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightAudioMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.audioMessage) {
                        self.selectedMessages.append(selectedCell.audioMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.audioMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftAudioMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.audioMessage) {
                        self.selectedMessages.append(selectedCell.audioMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.audioMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftLinkPreviewBubble {
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.linkPreviewMessage) {
                        self.selectedMessages.append(selectedCell.linkPreviewMessage)
                    }
                }
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightLinkPreviewBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.linkPreviewMessage) {
                        self.selectedMessages.append(selectedCell.linkPreviewMessage)
                    }
                }
            }
        },completion: nil)
        
        if tableView.isEditing == true {
            if selectedMessages.count <= 1 {
                messageActionView.isHidden = false
            }else{
                messageActionView.isHidden = true
            }
        }
        
        tableView.endUpdates()
        
    }
    
    /// This method triggers when particular cell is deselected by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        
        UIView.animate(withDuration: 1,delay: 0.0, usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 1, options: [], animations: {
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightLinkPreviewBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.linkPreviewMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.linkPreviewMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftLinkPreviewBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.linkPreviewMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.linkPreviewMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                            
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightTextMessageBubble, let message =  selectedCell.textMessage {
                            selectedCell.receiptStack.isHidden = true
                            if selectedCell.textMessage != nil && self.selectedMessages.contains(message) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == message.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                            
                        }
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftTextMessageBubble, let message =  selectedCell.textMessage {
                            selectedCell.receiptStack.isHidden = true
                            if selectedCell.textMessage != nil && self.selectedMessages.contains(message) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == message.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightImageMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.mediaMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.mediaMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightVideoMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.mediaMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.mediaMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftImageMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.mediaMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.mediaMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftVideoMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.mediaMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.mediaMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightFileMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.fileMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.fileMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftFileMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.fileMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.fileMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightAudioMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.audioMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.audioMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftAudioMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.audioMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.audioMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
        },completion: nil)
        
        if tableView.isEditing == true {
            if selectedMessages.count <= 1 {
                messageActionView.isHidden = false
            }else{
                messageActionView.isHidden = true
            }
        }
        tableView.endUpdates()
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - UITextView Delegate

extension CometChatMessageList : UITextViewDelegate {
    
    
    /// This method triggers when  user stops typing in textView.
    /// - Parameter textView: A scrollable, multiline text region.
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
            chatView.microphone.isHidden = false
            chatView.reaction.isHidden = false
            chatView.send.isHidden = true
        }
    }
    
    /// This method triggers when  user starts typing in textView.
    /// - Parameter textView: A scrollable, multiline text region.
    public func textViewDidChange(_ textView: UITextView) {
        guard let indicator = typingIndicator else {
            return
        }
        if textView.text?.count == 0 {
            CometChat.startTyping(indicator: indicator)
            chatView.microphone.isHidden = false
            chatView.reaction.isHidden = false
            chatView.send.isHidden = true
        }else{
            CometChat.endTyping(indicator: indicator)
            chatView.microphone.isHidden = true
            chatView.reaction.isHidden = true
            chatView.send.isHidden = false
        }
        CometChat.startTyping(indicator: indicator)
    }  
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - QuickLook Preview Delegate

extension CometChatMessageList:QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    
    /**
     This method will open  quick look preview controller.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func presentQuickLook(){
        DispatchQueue.main.async { [weak self] in
            let previewController = QLPreviewController()
            previewController.modalPresentationStyle = .popover
            previewController.dataSource = self
            previewController.navigationController?.title = ""
            self?.present(previewController, animated: true, completion: nil)
        }
    }
    
    /**
     This method will preview media message under  quick look preview controller.
     - Parameters:
     - url:  this specifies the `url` of Media Message.
     - completion: This handles the completion of method.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func previewMediaMessage(url: String, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void){
        let itemUrl = URL(string: url)
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(itemUrl?.lastPathComponent ?? "")
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(true, destinationUrl)
        } else {
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Downloading...", duration: .long)
            snackbar.animationType = .fadeInFadeOut
            snackbar.show()
            URLSession.shared.downloadTask(with: itemUrl!, completionHandler: { (location, response, error) -> Void in
                guard let tempLocation = location, error == nil else { return }
                do {
                    snackbar.dismiss()
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    completion(true, destinationUrl)
                } catch let error as NSError {
                    print(error.localizedDescription)
                    completion(false, nil)
                }
            }).resume()
        }
    }
    
    
    /// Invoked when the Quick Look preview controller needs to know the number of preview items to include in the preview navigation list.
    /// - Parameter controller: A specialized view for previewing an item.
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int { return 1 }
    
    
    /// Invoked when the Quick Look preview controller needs the preview item for a specified index position.
    /// - Parameters:
    ///   - controller: A specialized view for previewing an item.
    ///   - index: The index position, within the preview navigation list, of the item to preview.
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previewItem as QLPreviewItem
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - ChatView Internal Delegate

extension CometChatMessageList : ChatViewInternalDelegate {
    
    
    public func didReactionButtonPressed() {
        if let user = currentUser {
            let reactionIndicator = TypingIndicator(receiverID: user.uid ?? "", receiverType: .user)
            if currentReaction == .heart {
                reactionIndicator.metadata = ["type":"live_reaction", "reaction": "heart"]
            }else{
                reactionIndicator.metadata = ["type":"live_reaction", "reaction": "thumbsup"]
            }
            CometChat.startTyping(indicator: reactionIndicator)
            reactionView.startAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                CometChat.endTyping(indicator: reactionIndicator)
                self.reactionView.stopAnimation()
            })
        }else if let group = currentGroup {
            let reactionIndicator = TypingIndicator(receiverID: group.guid , receiverType: .group)
            if currentReaction == .heart {
                reactionIndicator.metadata = ["type":"live_reaction", "reaction":"heart"]
            }else{
                reactionIndicator.metadata = ["type":"live_reaction", "reaction":"thumbsup"]
            }
            CometChat.startTyping(indicator: reactionIndicator)
            reactionView.startAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                CometChat.endTyping(indicator: reactionIndicator)
                self.reactionView.stopAnimation()
            })
        }
    }
    
    public func didMicrophoneButtonPressed(with: UILongPressGestureRecognizer) {
        
    }
    
    /**
     This method triggers when user pressed attachment  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didAttachmentButtonPressed() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Take a Photo", comment: ""), style: .default) { action -> Void in
            CameraHandler.shared.presentCamera(for: self)
            CameraHandler.shared.imagePickedBlock = {(photoURL) in
                self.sendMedia(withURL: photoURL, type: .image)
            }
        }
        let photoLibraryAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("PHOTO_&_VIDEO_LIBRARY", comment: ""), style: .default) { action -> Void in
            CameraHandler.shared.presentPhotoLibrary(for: self)
            CameraHandler.shared.imagePickedBlock = {(photoURL) in
                self.sendMedia(withURL: photoURL, type: .image)
            }
            CameraHandler.shared.videoPickedBlock = {(videoURL) in
                self.sendMedia(withURL: videoURL, type: .video)
            }
        }
        let documentAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("DOCUMENT", comment: ""), style: .default) { action -> Void in
            self.documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.present(self.documentPicker, animated: true, completion: nil)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel) { action -> Void in
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheetController.addAction(cameraAction)
        actionSheetController.addAction(photoLibraryAction)
        actionSheetController.addAction(documentAction)
        actionSheetController.addAction(cancelAction)
        
        // Added ActionSheet support for iPad
        if self.chatView.frame.origin.y != 0 { dismissKeyboard() }
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            if let currentPopoverpresentioncontroller =
                actionSheetController.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = self.chatView.attachment
                self.present(actionSheetController, animated: true, completion: nil)
            }
        }else{
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
    
    private func sendMedia(withURL: String, type: CometChat.MessageType){
        var lastSection = 0
        if chatMessages.count == 0 {
            lastSection = (self.tableView?.numberOfSections ?? 0)
        }else {
            lastSection = (self.tableView?.numberOfSections ?? 0) - 1
        }
        CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
        var mediaMessage: MediaMessage?
        switch self.isGroupIs {
        case true:
            mediaMessage = MediaMessage(receiverUid: self.currentGroup?.guid ?? "", fileurl: withURL, messageType: type, receiverType: .group)
            mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            mediaMessage?.sender?.uid = LoggedInUser.uid
            mediaMessage?.senderUid = LoggedInUser.uid
            mediaMessage?.metaData = ["fileURL":withURL]
            if self.chatMessages.count == 0 {
                self.addNewGroupedMessage(messages: [mediaMessage!])
                self.filteredMessages.append(mediaMessage!)
            }else{
                self.chatMessages[lastSection].append(mediaMessage!)
                self.filteredMessages.append(mediaMessage!)
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.tableView?.beginUpdates()
                    strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                    strongSelf.tableView?.endUpdates()
                    strongSelf.tableView?.scrollToBottomRow()
                }
            }
            CometChat.sendMediaMessage(message: mediaMessage!, onSuccess: { (message) in
                if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                    self.chatMessages[lastSection][row] = message
                }
                DispatchQueue.main.async{ [weak self] in
                    guard let strongSelf = self else { return }
                    if message.messageType == .audio || message.messageType == .file {
                        do {
                            try strongSelf.viewModel.resetRecording()
                            strongSelf.audioVisualizationView.reset()
                            strongSelf.currentState = .ready
                        } catch {
                            strongSelf.showAlert(with: error)
                        }
                    }
                    strongSelf.tableView?.reloadData()}
            }) { (error) in
                DispatchQueue.main.async {
                    if let errorMessage = error?.errorDescription {
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                        snackbar.show()
                    }
                }
                print("sendMediaMessage error: \(String(describing: error?.errorDescription))")
            }
        case false:
            mediaMessage = MediaMessage(receiverUid: self.currentUser?.uid ?? "", fileurl: withURL, messageType: type, receiverType: .user)
            mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            mediaMessage?.sender?.uid = LoggedInUser.uid
            mediaMessage?.senderUid = LoggedInUser.uid
            mediaMessage?.metaData = ["fileURL":withURL]
            if self.chatMessages.count == 0 {
                self.addNewGroupedMessage(messages: [mediaMessage!])
                self.filteredMessages.append(mediaMessage!)
            }else{
                self.chatMessages[lastSection].append(mediaMessage!)
                self.filteredMessages.append(mediaMessage!)
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.tableView?.beginUpdates()
                    strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                    strongSelf.tableView?.endUpdates()
                    strongSelf.tableView?.scrollToBottomRow()
                }
            }
            CometChat.sendMediaMessage(message: mediaMessage!, onSuccess: { (message) in
                if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                    self.chatMessages[lastSection][row] = message
                }
                DispatchQueue.main.async{  [weak self] in
                    guard let strongSelf = self else { return }
                    if message.messageType == .audio || message.messageType == .file {
                        do {
                            try strongSelf.viewModel.resetRecording()
                            strongSelf.audioVisualizationView.reset()
                            strongSelf.currentState = .ready
                        } catch {
                            strongSelf.showAlert(with: error)
                        }
                    }
                    strongSelf.tableView?.reloadData()}
            }) { (error) in
                DispatchQueue.main.async {
                    if let errorMessage = error?.errorDescription {
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                        snackbar.show()
                    }
                }
                print("sendMediaMessage error: \(String(describing: error?.errorDescription))")
            }
        }
    }
    
    
    /**
     This method triggers when user pressed sticker  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didStickerButtonPressed() {
        
        
    }
    
    
    
    /**
     This method triggers when user pressed send  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didSendButtonPressed() {
        var lastSection = 0
        if chatMessages.count == 0 {
            lastSection = (self.tableView?.numberOfSections ?? 0)
        }else {
            lastSection = (self.tableView?.numberOfSections ?? 0) - 1
        }
        if messageMode == .edit {
            guard let textMessage = selectedMessage as? TextMessage else { return }
            guard let indexPath = selectedIndexPath else { return }
            CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
            if let message:String = chatView?.textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                textMessage.text = message
                CometChat.edit(message: textMessage, onSuccess: { (editedMessage) in
                    if let row = self.chatMessages[indexPath.section].firstIndex(where: {$0.id == editedMessage.id}) {
                        self.chatMessages[indexPath.section][row] = editedMessage
                    }
                    DispatchQueue.main.async{  [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.tableView?.reloadRows(at: [indexPath], with: .automatic)
                        strongSelf.hide(view: .editMessageView, true)
                        strongSelf.hide(view: .smartRepliesView, true)
                        strongSelf.didPreformCancel()
                        strongSelf.messageMode = .send
                        strongSelf.textView.text = ""
                    }
                }) { (error) in
                    DispatchQueue.main.async{ [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.hide(view: .editMessageView, true)
                        strongSelf.hide(view: .smartRepliesView, true)
                        strongSelf.didPreformCancel()
                        strongSelf.messageMode = .send
                        strongSelf.textView.text = ""
                    }
                    print("unable to edit Message: \(error.errorDescription)")
                }
            }
        }else if messageMode == .reply {
            var textMessage: TextMessage?
            let message:String = chatView?.textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if(message.count == 0){
                
            }else{
                CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                switch self.isGroupIs {
                case true:
                    textMessage = TextMessage(receiverUid: currentGroup?.guid ?? "", text: message, receiverType: .group)
                    textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                    textMessage?.sender?.uid = LoggedInUser.uid
                    textMessage?.senderUid = LoggedInUser.uid
                    textMessage?.metaData = ["type": "reply","message":editViewMessage.text as Any]
                    
                    if chatMessages.count == 0 {
                        self.addNewGroupedMessage(messages: [textMessage!])
                        self.filteredMessages.append(textMessage!)
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                    }else{
                        self.chatMessages[lastSection].append(textMessage!)
                        self.filteredMessages.append(textMessage!)
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                        DispatchQueue.main.async {[weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.hide(view: .editMessageView, true)
                            strongSelf.hide(view: .smartRepliesView, true)
                            strongSelf.tableView?.beginUpdates()
                            strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                            strongSelf.tableView?.endUpdates()
                            strongSelf.tableView?.scrollToBottomRow()
                            strongSelf.chatView.textView.text = ""
                        }
                    }
                    CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                        print("sendTextMessage onSuccess: \(String(describing: message.stringValue()))")
                        if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                            self.chatMessages[lastSection][row] = message
                            DispatchQueue.main.async{ [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.tableView?.reloadData()
                                strongSelf.didPreformCancel()
                                strongSelf.messageMode = .send
                                strongSelf.textView.text = ""
                                textMessage = nil
                            }
                        }
                        textMessage = nil
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let errorMessage = error?.errorDescription {
                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                                snackbar.show()
                            }
                        }
                        print("sendTextMessage error: \(String(describing: error?.errorDescription))")
                    }
                case false:
                    textMessage = TextMessage(receiverUid: currentUser?.uid ?? "", text: message, receiverType: .user)
                    textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                    textMessage?.sender?.uid = LoggedInUser.uid
                    textMessage?.senderUid = LoggedInUser.uid
                    textMessage?.metaData = ["google":"google"]
                    textMessage?.metaData = ["type": "reply","message":editViewMessage.text as Any]
                    
                    if chatMessages.count == 0 {
                        self.addNewGroupedMessage(messages: [textMessage!])
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                    }else{
                        self.chatMessages[lastSection].append(textMessage!)
                        self.filteredMessages.append(textMessage!)
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                        DispatchQueue.main.async {  [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.hide(view: .editMessageView, true)
                            strongSelf.hide(view: .smartRepliesView, true)
                            strongSelf.tableView?.beginUpdates()
                            strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                            strongSelf.tableView?.endUpdates()
                            strongSelf.tableView?.scrollToBottomRow()
                            strongSelf.chatView.textView.text = ""
                        }
                    }
                    CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                        print("sendTextMessage onSuccess: \(String(describing: message.stringValue()))")
                        if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                            self.chatMessages[lastSection][row] = message
                            DispatchQueue.main.async{ [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.tableView?.reloadData()
                                strongSelf.didPreformCancel()
                                strongSelf.messageMode = .send
                                strongSelf.textView.text = ""
                                textMessage = nil
                            }
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let errorMessage = error?.errorDescription {
                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                                snackbar.show()
                            }
                        }
                        print("sendTextMessage error: \(String(describing: error?.errorDescription))")
                    }
                }
            }
        }else{
            var textMessage: TextMessage?
            let message:String = chatView?.textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if(message.count == 0){
                
            }else{
                CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                switch self.isGroupIs {
                case true:
                    textMessage = TextMessage(receiverUid: currentGroup?.guid ?? "", text: message, receiverType: .group)
                    textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                    textMessage?.sender?.uid = LoggedInUser.uid
                    textMessage?.senderUid = LoggedInUser.uid
                    
                    if chatMessages.count == 0 {
                        self.addNewGroupedMessage(messages: [textMessage!])
                        self.filteredMessages.append(textMessage!)
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                    }else{
                        self.chatMessages[lastSection].append(textMessage!)
                        self.filteredMessages.append(textMessage!)
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                        DispatchQueue.main.async {[weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.hide(view: .smartRepliesView, true)
                            strongSelf.tableView?.beginUpdates()
                            strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                            strongSelf.tableView?.endUpdates()
                            strongSelf.tableView?.scrollToBottomRow()
                            strongSelf.chatView.textView.text = ""
                        }
                    }
                    CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                        print("sendTextMessage onSuccess: \(String(describing: message.stringValue()))")
                        if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                            self.chatMessages[lastSection][row] = message
                            DispatchQueue.main.async{ [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.tableView?.reloadData()
                                textMessage = nil
                            }
                        }
                        textMessage = nil
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let errorMessage = error?.errorDescription {
                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                                snackbar.show()
                            }
                        }
                        print("sendTextMessage error: \(String(describing: error?.errorDescription))")
                    }
                case false:
                    textMessage = TextMessage(receiverUid: currentUser?.uid ?? "", text: message, receiverType: .user)
                    textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                    textMessage?.sender?.uid = LoggedInUser.uid
                    textMessage?.senderUid = LoggedInUser.uid
                    
                    if chatMessages.count == 0 {
                        self.addNewGroupedMessage(messages: [textMessage!])
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                    }else{
                        self.chatMessages[lastSection].append(textMessage!)
                        self.filteredMessages.append(textMessage!)
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                        DispatchQueue.main.async {  [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.hide(view: .smartRepliesView, true)
                            strongSelf.tableView?.beginUpdates()
                            strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                            strongSelf.tableView?.endUpdates()
                            strongSelf.tableView?.scrollToBottomRow()
                            strongSelf.chatView.textView.text = ""
                        }
                    }
                    CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                        print("sendTextMessage onSuccess: \(String(describing: message.stringValue()))")
                        if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                            self.chatMessages[lastSection][row] = message
                            DispatchQueue.main.async{ [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.tableView?.reloadData()
                                textMessage = nil
                            }
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let errorMessage = error?.errorDescription {
                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                                snackbar.show()
                            }
                        }
                        print("sendTextMessage error: \(String(describing: error?.errorDescription))")
                    }
                }
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatMessageDelegate

extension CometChatMessageList : CometChatMessageDelegate {
    
    /**
     This method append new message on UI when new message is received.
     /// - Parameter message: This specified the `BaseMessage` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func appendNewMessage(message: BaseMessage) {
        DispatchQueue.main.async{ CometChatSoundManager().play(sound: .incomingMessage, bool: true)}
        switch message.receiverType {
        case .user:
            CometChat.markAsRead(messageId: message.id, receiverId: message.senderUid, receiverType: .user)
            if chatMessages.count == 0 {
                self.addNewGroupedMessage(messages: [message])
            }else{
                DispatchQueue.main.async{ [weak self] in
                    if let strongSelf = self, let lastSection = strongSelf.tableView?.numberOfSections {
                        strongSelf.chatMessages[lastSection - 1].append(message)
                        strongSelf.tableView?.reloadData()
                        strongSelf.tableView?.scrollToBottomRow()
                    }
                }
            }
            
        case .group:
            CometChat.markAsRead(messageId: message.id, receiverId: message.receiverUid, receiverType: .group)
            if chatMessages.count == 0 {
                self.addNewGroupedMessage(messages: [message])
            }else{
                DispatchQueue.main.async{ [weak self] in
                    if let strongSelf = self, let lastSection = strongSelf.tableView?.numberOfSections {
                        strongSelf.chatMessages[lastSection - 1].append(message)
                        strongSelf.tableView?.reloadData()
                        strongSelf.tableView?.scrollToBottomRow()
                    }
                }
            }
        @unknown default: break
        }
    }
    
    /**
     This method triggers when real time text message message arrives from CometChat Pro SDK
     - Parameter textMessage: This Specifies TextMessage Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onTextMessageReceived(textMessage: TextMessage) {
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            //Appending Real time text messages for User.
            if let sender = textMessage.sender?.uid, let currentUser = strongSelf.currentUser?.uid {
                if sender == currentUser && textMessage.receiverType == .user {
                    strongSelf.appendNewMessage(message: textMessage)
                    let titles = strongSelf.parseSmartRepliesMessages(message: textMessage)
                    strongSelf.smartRepliesView.set(titles: titles)
                    strongSelf.hide(view: .smartRepliesView, false)
                    
                }else if sender == LoggedInUser.uid && textMessage.receiverType == .user {
                    strongSelf.appendNewMessage(message: textMessage)
                    let titles = strongSelf.parseSmartRepliesMessages(message: textMessage)
                    strongSelf.smartRepliesView.set(titles: titles)
                    strongSelf.hide(view: .smartRepliesView, true)
                }
            }else{
                CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true)
            }
            
            //Appending Real time text messages for Group.
            if let currentGroup = strongSelf.currentGroup?.guid {
                let sender = textMessage.senderUid
                let group = textMessage.receiverUid
                // Receiving real time messages for the group this window is opened for.
                if group == currentGroup && textMessage.receiverType == .group && sender != LoggedInUser.uid {
                    strongSelf.appendNewMessage(message: textMessage)
                    let titles = strongSelf.parseSmartRepliesMessages(message: textMessage)
                    strongSelf.smartRepliesView.set(titles: titles)
                    strongSelf.hide(view: .smartRepliesView, false)
                }else if sender == LoggedInUser.uid && textMessage.receiverType == .group && group == currentGroup {
                    strongSelf.appendNewMessage(message: textMessage)
                    let titles = strongSelf.parseSmartRepliesMessages(message: textMessage)
                    strongSelf.smartRepliesView.set(titles: titles)
                    strongSelf.hide(view: .smartRepliesView, true)
                }
            }else{
                CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true)
            }
        }
    }
    
    /**
     This method triggers when real time media message arrives from CometChat Pro SDK
     - Parameter mediaMessage: This Specifies TextMessage Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            //Appending Real time text messages for User.
            if let sender = mediaMessage.sender?.uid, let currentUser = strongSelf.currentUser?.uid {
                if sender == currentUser && mediaMessage.receiverType == .user {
                    strongSelf.appendNewMessage(message: mediaMessage)
                    strongSelf.hide(view: .smartRepliesView, true)
                    
                }else if sender == LoggedInUser.uid && mediaMessage.receiverType == .user {
                    strongSelf.appendNewMessage(message: mediaMessage)
                    strongSelf.hide(view: .smartRepliesView, true)
                }
            }
            
            //Appending Real time text messages for Group.
            if let currentGroup = strongSelf.currentGroup?.guid {
                let sender = mediaMessage.receiverUid
                // Receiving real time messages for the group this window is opened for.
                if sender == currentGroup && mediaMessage.receiverType == .group {
                    strongSelf.appendNewMessage(message: mediaMessage)
                    strongSelf.hide(view: .smartRepliesView, true)
                }else if sender == LoggedInUser.uid && mediaMessage.receiverType == .group {
                    strongSelf.hide(view: .smartRepliesView, true)
                }
            }
        }
    }
    
    /**
     This method triggers when receiver reads the message sent by you.
     - Parameter receipt: This Specifies MessageReceipt Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onMessagesRead(receipt: MessageReceipt) {
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            if receipt.sender?.uid == strongSelf.currentUser?.uid && receipt.receiverType == .user{
                for messages in strongSelf.chatMessages {
                    for message in messages where message.readAt == 0 {
                        message.readAt = Double(receipt.timeStamp)
                    }
                }
                DispatchQueue.main.async {strongSelf.tableView?.reloadData()}
            }else if receipt.receiverId == strongSelf.currentGroup?.guid && receipt.receiverType == .group{
                for messages in strongSelf.chatMessages {
                    for message in messages where message.readAt == 0 {
                        message.readAt = Double(receipt.timeStamp)
                    }
                }
                DispatchQueue.main.async {strongSelf.tableView?.reloadData()}
            }
        }
    }
    
    /**
     This method triggers when  message sent by you reaches to the receiver.
     - Parameter receipt: This Specifies MessageReceipt Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onMessagesDelivered(receipt: MessageReceipt) {
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            if receipt.sender?.uid == strongSelf.currentUser?.uid && receipt.receiverType == .user{
                for messages in strongSelf.chatMessages {
                    for message in messages where message.deliveredAt == 0 {
                        message.deliveredAt = Double(receipt.timeStamp)
                    }
                }
                DispatchQueue.main.async {strongSelf.tableView?.reloadData()}
            }else if receipt.receiverId == strongSelf.currentGroup?.guid && receipt.receiverType == .group{
                for messages in strongSelf.chatMessages {
                    for message in messages where message.deliveredAt == 0 {
                        message.deliveredAt = Double(receipt.timeStamp)
                    }
                }
                DispatchQueue.main.async {strongSelf.tableView?.reloadData()}
            }
        }
    }
    
    /**
     This method triggers when real time event for  start typing received from  CometChat Pro SDK
     - Parameter typingDetails: This specifies TypingIndicator Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onTypingStarted(_ typingDetails: TypingIndicator) {
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            if typingDetails.sender?.uid == strongSelf.currentUser?.uid && typingDetails.receiverType == .user{
                
                if let typingMetaData = typingDetails.metadata, let type = typingMetaData["type"] as? String ,let reaction = typingMetaData["reaction"] as? String {
                    if type == "live_reaction" {
                        if reaction == "heart" || reaction == "thumbsup" {
                            strongSelf.reactionView.startAnimation()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                strongSelf.reactionView.stopAnimation()
                            })
                        }
                    }
                }else{
                    strongSelf.setupNavigationBar(withSubtitle: NSLocalizedString("TYPING", comment: ""))
                }
                
            }else if typingDetails.receiverType == .group  && typingDetails.receiverID == strongSelf.currentGroup?.guid {
                
                if let typingMetaData = typingDetails.metadata, let type = typingMetaData["type"] as? String ,let reaction = typingMetaData["reaction"] as? String {
                    if type == "live_reaction" {
                        if reaction == "heart" || reaction == "thumbsup" {
                            strongSelf.reactionView.startAnimation()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                strongSelf.reactionView.stopAnimation()
                            })
                        }
                    }
                }else{
                    if let user = typingDetails.sender?.name {
                        strongSelf.setupNavigationBar(withSubtitle: "\(String(describing: user)) " + NSLocalizedString("IS_TYPING", comment: ""))
                    }
                    
                }
            }
        }
    }
    
    /**
     This method triggers when real time event for  stop typing received from  CometChat Pro SDK
     - Parameter typingDetails: This specifies TypingIndicator Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onTypingEnded(_ typingDetails: TypingIndicator) {
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            
            if typingDetails.sender?.uid == strongSelf.currentUser?.uid && typingDetails.receiverType == .user{
                
                if let typingMetaData = typingDetails.metadata, let type = typingMetaData["type"] as? String ,let reaction = typingMetaData["reaction"] as? String {
                    if type == "live_reaction" {
                        if type == "live_reaction" {
                            if reaction == "heart" || reaction == "thumbsup" {
                                strongSelf.reactionView.stopAnimation()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                    strongSelf.reactionView.stopAnimation()
                                })
                            }
                        }
                    }else{
                        strongSelf.setupNavigationBar(withSubtitle: NSLocalizedString("ONLINE", comment: ""))
                    }
                    
                }else if typingDetails.receiverType == .group  && typingDetails.receiverID == strongSelf.currentGroup?.guid {
                    
                    if let typingMetaData = typingDetails.metadata, let type = typingMetaData["type"] as? String ,let reaction = typingMetaData["reaction"] as? String {
                        if type == "live_reaction" {
                            if type == "live_reaction" {
                                if reaction == "heart" || reaction == "thumbsup" {
                                    strongSelf.reactionView.stopAnimation()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                        strongSelf.reactionView.stopAnimation()
                                    })
                                }
                            }
                        }else{
                            strongSelf.setupNavigationBar(withSubtitle: strongSelf.membersCount ?? "")
                        }
                    }
                }
            }
        }
    }
    
    public func onMessageEdited(message: BaseMessage) {
        
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            switch message.receiverType {
            case .user:
                strongSelf.refreshMessageList(forID: strongSelf.currentUser?.uid ?? "" , type: .user, scrollToBottom: false)
            case .group:
                strongSelf.refreshMessageList(forID: strongSelf.currentGroup?.guid ?? "" , type: .group, scrollToBottom: false)
            @unknown default: break
            }
        }
    }
    
    public func onMessageDeleted(message: BaseMessage) {
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            switch message.receiverType {
            case .user:
                strongSelf.refreshMessageList(forID: strongSelf.currentUser?.uid ?? "" , type: .user, scrollToBottom: false)
            case .group:
                strongSelf.refreshMessageList(forID: strongSelf.currentGroup?.guid ?? "" , type: .group, scrollToBottom: false)
            @unknown default: break
            }
        }
    }
    
}
/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatUserDelegate Delegate

extension CometChatMessageList : CometChatUserDelegate {
    
    /**
     This event triggers when user is Online.
     - Parameter user: This specifies `User` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onUserOnline(user: User) {
        if user.uid == currentUser?.uid{
            if user.status == .online {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.setupNavigationBar(withSubtitle: NSLocalizedString("ONLINE", comment: ""))
                }
            }
        }
    }
    
    /**
     This event triggers when user goes Offline..
     - Parameter user: This specifies `User` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onUserOffline(user: User) {
        if user.uid == currentUser?.uid {
            if user.status == .offline {
                DispatchQueue.main.async {  [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.setupNavigationBar(withSubtitle: NSLocalizedString("OFFLINE", comment: ""))
                }
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatGroupDelegate Delegate


extension CometChatMessageList : CometChatGroupDelegate {
    
    /**
     This method triggers when someone joins group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - joinedUser: Specifies `User` Object
     - joinedGroup: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            self.fetchGroup(group: joinedGroup.guid)
            CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
            self.refreshMessageList(forID: joinedGroup.guid, type: .group, scrollToBottom: true)
        }
    }
    
    /**
     This method triggers when someone lefts group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - leftUser: Specifies `User` Object
     - leftGroup: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            self.fetchGroup(group: leftGroup.guid)
            CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
            self.appendNewMessage(message: action)
        }
    }
    
    /**
     This method triggers when someone kicked from the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - kickedUser: Specifies `User` Object
     - kickedBy: Specifies `User` Object
     - kickedFrom: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            self.fetchGroup(group: kickedFrom.guid)
            CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
            self.appendNewMessage(message: action)
        }
    }
    
    /**
     This method triggers when someone banned from the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - bannedUser: Specifies `User` Object
     - bannedBy: Specifies `User` Object
     - bannedFrom: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
            self.appendNewMessage(message: action)
        }
    }
    
    /**
     This method triggers when someone unbanned from the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - unbannedUser: Specifies `User` Object
     - unbannedBy: Specifies `User` Object
     - unbannedFrom: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
            self.appendNewMessage(message: action)
        }
    }
    
    /**
     This method triggers when someone's scope changed  in the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - scopeChangeduser: Specifies `User` Object
     - scopeChangedBy: Specifies `User` Object
     - scopeChangedTo: Specifies `User` Object
     - scopeChangedFrom:  Specifies  description for scope changed
     - group: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
            self.appendNewMessage(message: action)
        }
    }
    
    /**
     This method triggers when someone added in  the  group.
     - Parameters:
     - action:  Spcifies `ActionMessage` Object
     - addedBy: Specifies `User` Object
     - addedUser: Specifies `User` Object
     - addedTo: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            self.fetchGroup(group: addedTo.guid)
            CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
            self.appendNewMessage(message: action)
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Smart Replies Delegate

extension CometChatMessageList : SmartRepliesViewDelegate {
    
    /**
     This method triggers when user pressed particular button in smart replies view.
     - Parameter title: `title` specifies the title of the button.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func didSendButtonPressed(title: String) {
        var textMessage: TextMessage?
        let lastSection = (self.tableView?.numberOfSections ?? 0) - 1
        CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
        switch self.isGroupIs {
        case true:
            textMessage = TextMessage(receiverUid: currentGroup?.guid ?? "", text: title, receiverType: .group)
            textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            textMessage?.sender?.uid = LoggedInUser.uid
            textMessage?.senderUid = LoggedInUser.uid
            
            self.chatMessages[lastSection].append(textMessage!)
            self.filteredMessages.append(textMessage!)
            self.hide(view: .smartRepliesView, true)
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
            DispatchQueue.main.async {  [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView?.beginUpdates()
                strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                strongSelf.tableView?.endUpdates()
                strongSelf.tableView?.scrollToBottomRow()
                strongSelf.chatView.textView.text = ""
            }
            
            CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                print("sendTextMessage onSuccess: \(String(describing: message.stringValue()))")
                CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                    self.chatMessages[lastSection][row] = message
                }
                DispatchQueue.main.async{  [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.tableView?.reloadData()
                }
            }) { (error) in
                DispatchQueue.main.async {
                    if let errorMessage = error?.errorDescription {
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                        snackbar.show()
                    }
                }
                print("sendTextMessage error: \(String(describing: error?.errorDescription))")
            }
        case false:
            textMessage = TextMessage(receiverUid: currentUser?.uid ?? "", text: title, receiverType: .user)
            textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            textMessage?.sender?.uid = LoggedInUser.uid
            textMessage?.senderUid = LoggedInUser.uid
            
            self.chatMessages[lastSection].append(textMessage!)
            self.filteredMessages.append(textMessage!)
            self.hide(view: .smartRepliesView, true)
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView?.beginUpdates()
                strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                strongSelf.tableView?.endUpdates()
                strongSelf.tableView?.scrollToBottomRow()
                strongSelf.chatView.textView.text = ""
            }
            CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                print("sendTextMessage onSuccess: \(String(describing: message.stringValue()))")
                CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                    self.chatMessages[lastSection][row] = message
                }
                DispatchQueue.main.async{ [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.tableView?.reloadData() }
            }) { (error) in
                DispatchQueue.main.async {
                    if let errorMessage = error?.errorDescription {
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                        snackbar.show()
                    }
                }
                print("sendTextMessage error: \(String(describing: error?.errorDescription))")
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Link Preview Delegate

extension CometChatMessageList: LinkPreviewDelegate {
    
    /**
     This method triggers when user pressed visit button in link preview bubble.
     - Parameters:
     - link: link specifies `link` of the message.
     - sender: specifies the user who is pressing this button.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didVisitButtonPressed(link: String, sender: UIButton) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
    
    /**
     This method triggers when user pressed play button in link preview bubble.
     - Parameters:
     - link: link specifies `link` of the message.
     - sender: specifies the user who is pressing this button.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didPlayButtonPressed(link: String, sender: UIButton) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
}

/*  ----------------------------------------------------------------------------------------- */


extension CometChatMessageList: LeftTextMessageBubbleDelegate {
    
    
    func didTapOnSentimentAnalysisViewForLeftBubble(indexPath: IndexPath) {
        if let cell = self.tableView?.cellForRow(at: indexPath) as? LeftTextMessageBubble {
        let alert = UIAlertController(title: "Warning!", message: "Are you sure want to view this message?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.tableView?.beginUpdates()
                cell.message.font = UIFont (name: "SFProDisplay-Regular", size: 17)
                cell.sentimentAnalysisView.isHidden = true
                cell.spaceConstraint.constant = 0
                cell.widthconstraint.constant = 0
                if let message = cell.textMessage {
                    cell.parseProfanityFilter(forMessage: message)
                    if #available(iOS 13.0, *) {
                        cell.message.textColor = .label
                    } else {
                        cell.message.textColor = .black
                    }
                }
             self.tableView?.endUpdates()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(alert, animated: true, completion: nil)
    }
    }
}

/*  ----------------------------------------------------------------------------------------- */



extension CometChatMessageList: LeftReplyMessageBubbleDelegate {
    
    
    func didTapOnSentimentAnalysisViewForLeftReplyBubble(indexPath: IndexPath) {
            if let cell = self.tableView?.cellForRow(at: indexPath) as? LeftReplyMessageBubble {
            let alert = UIAlertController(title: "Warning!", message: "Are you sure want to view this message?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    self.tableView?.beginUpdates()
                    cell.message.font = UIFont (name: "SFProDisplay-Regular", size: 17)
                    cell.sentimentAnalysisView.isHidden = true
                    cell.spaceConstraint.constant = 0
                    cell.widthconstraint.constant = 0
                    if let message = cell.textMessage {
                        cell.parseProfanityFilter(forMessage: message)
                        if #available(iOS 13.0, *) {
                            cell.message.textColor = .label
                        } else {
                            cell.message.textColor = .black
                        }
                    }
                 self.tableView?.endUpdates()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
}

