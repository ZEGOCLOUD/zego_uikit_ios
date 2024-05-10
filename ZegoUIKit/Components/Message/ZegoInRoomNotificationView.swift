//
//  ZegoInRoomNotificationView.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/9/30.
//

import UIKit

public class ZegoInRoomNotificationViewConfig: NSObject {
    var notifyUserLeave: Bool = true
}

@objc public protocol ZegoInRoomNotificationViewDelegate: AnyObject {
    @objc optional func getJoinCell(_ tableView: UITableView, indexPath: IndexPath, uiKitUser: ZegoUIKitUser) -> UITableViewCell?
    @objc optional func getLeaveCell(_ tableView: UITableView, indexPath: IndexPath, uiKitUser: ZegoUIKitUser) -> UITableViewCell?
    @objc optional func getMessageCell(_ tableView: UITableView, indexPath: IndexPath, inRoomMessage: ZegoInRoomMessage) -> UITableViewCell?
    @objc optional func getJoinCellHeight(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, uiKitUser: ZegoUIKitUser) -> CGFloat
    @objc optional func getLeaveCellHeight(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, uiKitUser: ZegoUIKitUser) -> CGFloat
    @objc optional func getMessageCellHeight(_ tableView: UITableView, indexPath: IndexPath, inRoomMessage: ZegoInRoomMessage) -> CGFloat
}

public class ZegoInRoomNotificationView: UIView {
    
    public weak var delegate: ZegoInRoomNotificationViewDelegate?
    
    var config: ZegoInRoomNotificationViewConfig = ZegoInRoomNotificationViewConfig()
    
    var currentLastMessageIndex: Int = 0
    var messageNotificationList:[MessageNotificationModel] = [MessageNotificationModel]()
    var allMessageList: [MessageNotificationModel] = [MessageNotificationModel]()
    let help = ZegoInRoomNotificationView_Help()
    
    var lastFrame: CGRect?
    
//    private var countDownTimer: DispatchSourceTimer =  DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    var timer: ZegoTimerTool?
    
    fileprivate lazy var tableView: UITableView = {
        let messageTable = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height), style: UITableView.Style.plain)
        return messageTable
    }()
    
    public init(frame: CGRect, config: ZegoInRoomNotificationViewConfig?) {
        super.init(frame: frame)
        if let config = config {
            self.config = config
        }
        self.help.inRoomNotificationView = self
        ZegoUIKit.shared.addEventHandler(self.help)
        self.setupTableView()
        self.getDisplayMessage()
        self.timer = ZegoTimerTool.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerStart), userInfo: nil, repeats: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var frame: CGRect {
        didSet {
            if let lastFrame = lastFrame,
               frame.equalTo(lastFrame)
            {
                return
            }
            self.lastFrame = frame
            MessageNotificationModelBuilder.messageViewWidth = self.frame.size.width
            self.tableView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    @objc public func registerCell(_ cellClass: AnyClass?, forCellReuseIdentifier: String) {
        self.tableView.register(cellClass, forCellReuseIdentifier: forCellReuseIdentifier)
    }
    
    @objc public func registerNibCell(_ nib: UINib?, forCellReuseIdentifier: String) {
        self.tableView.register(nib, forCellReuseIdentifier: forCellReuseIdentifier)
    }
    
    private func setupTableView() {
        self.tableView.delegate = self.help
        self.tableView.dataSource = self.help
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.estimatedRowHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        self.tableView.estimatedSectionHeaderHeight = 0
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
            self.tableView.insetsContentViewsToSafeArea = false
        }
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.register(ZegoUIKitMessageNotificationCell.self, forCellReuseIdentifier: "ZegoUIKitMessageNotificationCell")
        self.addSubview(self.tableView)
    }
    
    func getDisplayMessage() {
        self.messageNotificationList.removeAll()
        for message in ZegoUIKit.shared.getInRoomMessages() {
            if message.user?.userID != ZegoUIKit.shared.localUserInfo?.userID {
                let notificationMessage = MessageNotificationModelBuilder.buildModel(with: message.user, message: message.message ?? "")
                if self.messageNotificationList.count >= 3 {
                    self.messageNotificationList.remove(at: 0)
                    self.messageNotificationList.append(notificationMessage)
                } else {
                    self.messageNotificationList.append(notificationMessage)
                }
            }
        }
        //self.startTiming()
        self.updateHeight()
        self.tableView.reloadData()
    }
    
    @objc func timerStart() {
        var needReload: Bool = false
        for message in self.messageNotificationList {
            message.displayTime = message.displayTime - 1
            if message.displayTime <= 0 {
                needReload = true
            }
        }
        self.messageNotificationList.removeAll(where: {$0.displayTime <= 0})
        if needReload {
            self.tableView.reloadData()
        }
    }
    
    func updateHeight() {
        var height: CGFloat = 0
        for message in self.messageNotificationList {
            height = height + (message.messageHeight + 10 + 4)
        }
        let offsetY = height - self.frame.size.height
        if offsetY == 0 {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
        } else {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y - offsetY, width: self.frame.size.width, height: height)
        }
    }
    
    deinit {
        self.timer?.invalidate()
        print("ZegoInRoomNotificationView release")
    }
}

class ZegoInRoomNotificationView_Help: NSObject, UITableViewDelegate, UITableViewDataSource, ZegoUIKitEventHandle {
    
    weak var inRoomNotificationView: ZegoInRoomNotificationView?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inRoomNotificationView?.messageNotificationList.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let inRoomNotificationView = inRoomNotificationView else { return UITableViewCell() }
        
        if indexPath.row < inRoomNotificationView.messageNotificationList.count {
            
            let index: Int = indexPath.row
            let messageModel: MessageNotificationModel = inRoomNotificationView.messageNotificationList[index]
            let inRoomMessage: ZegoInRoomMessage = ZegoInRoomMessage.init(messageModel.content ?? "", messageID: messageModel.messageID, sendTime: 0, user: ZegoUIKitUser.init(messageModel.userID ?? "", messageModel.userName ?? ""))
            var cell: UITableViewCell? = inRoomNotificationView.delegate?.getMessageCell?(tableView, indexPath: indexPath, inRoomMessage: inRoomMessage)
            if messageModel.isUserJoinNoti {
                cell = inRoomNotificationView.delegate?.getJoinCell?(tableView, indexPath: indexPath, uiKitUser: ZegoUIKitUser.init(messageModel.userID ?? "", messageModel.userName ?? ""))
            }
            if messageModel.isUserLeaveNoti {
                cell = inRoomNotificationView.delegate?.getLeaveCell?(tableView, indexPath: indexPath, uiKitUser: ZegoUIKitUser.init(messageModel.userID ?? "", messageModel.userName ?? ""))
            }
            if let cell = cell {
                return cell
            }
            let messageCell: ZegoUIKitMessageNotificationCell = tableView.dequeueReusableCell(withIdentifier: "ZegoUIKitMessageNotificationCell") as! ZegoUIKitMessageNotificationCell
            messageCell.messageModel = messageModel
            messageCell.selectionStyle = .none
            messageCell.backgroundColor = UIColor.clear
            return messageCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let inRoomNotificationView = inRoomNotificationView else { return 0 }
        let model: MessageNotificationModel = inRoomNotificationView.messageNotificationList[indexPath.row]
        if model.isUserJoinNoti {
            let height: CGFloat = inRoomNotificationView.delegate?.getJoinCellHeight?(tableView, heightForRowAt: indexPath, uiKitUser: ZegoUIKitUser.init(model.userID ?? "", model.userName ?? "")) ?? model.messageHeight + 10.0 + 4.0
            if height == -1 {
                return model.messageHeight + 10.0 + 4.0
            } else {
                return height
            }
        }
        if model.isUserLeaveNoti {
            let height: CGFloat = inRoomNotificationView.delegate?.getLeaveCellHeight?(tableView, heightForRowAt: indexPath, uiKitUser: ZegoUIKitUser.init(model.userID ?? "", model.userName ?? "")) ?? model.messageHeight + 10.0 + 4.0
            if height == -1 {
                return model.messageHeight + 10.0 + 4.0
            } else {
                return height
            }
        }
        let cellHeight: CGFloat = inRoomNotificationView.delegate?.getMessageCellHeight?(tableView, indexPath: indexPath, inRoomMessage: ZegoInRoomMessage.init(model.content ?? "", messageID: model.messageID, sendTime: 0, user: ZegoUIKitUser.init(model.userID ?? "", model.userName ?? ""))) ?? model.messageHeight + 10.0 + 4.0
        if cellHeight == -1 {
            return  model.messageHeight + 10.0 + 4.0
        } else {
            return cellHeight
        }
    }
    //MARK: -ZegoUIKitEventHandle
    func onInRoomMessageReceived(_ messageList: [ZegoInRoomMessage]) {
        self.buildDisplayMessage(messageList)
    }
    
    func onRemoteUserJoin(_ userList: [ZegoUIKitUser]) {
        guard let config = inRoomNotificationView?.config else { return }
        var messageList = [ZegoInRoomMessage]()
        for user in userList {
            let messageString = String(format: ZegoUIKitTranslationTextConfig.shared.translationText.enterRoomDialogMessage,user.userName ?? "")
            let message = ZegoInRoomMessage.init(messageString, messageID: 0, sendTime: 0, user: user)
            messageList.append(message)
        }
        self.buildDisplayMessage(messageList, isUserJoinNoti: true)
    }
    
    func onRemoteUserLeave(_ userList: [ZegoUIKitUser]) {
        guard let config = inRoomNotificationView?.config else { return }
        if config.notifyUserLeave {
            var messageList = [ZegoInRoomMessage]()
            for user in userList {
                let messageString = String(format: ZegoUIKitTranslationTextConfig.shared.translationText.quitRoomDialogMessage,user.userName ?? "")
                let message = ZegoInRoomMessage.init(messageString, messageID: 0, sendTime: 0, user: user)
                messageList.append(message)
            }
            self.buildDisplayMessage(messageList, isUserLeaveNoti: true)
        }
    }
    
    func buildDisplayMessage(_ messageList: [ZegoInRoomMessage], isUserJoinNoti: Bool = false, isUserLeaveNoti: Bool = false) {
        var newMessageList = [MessageNotificationModel]()
        for message in messageList {
            let model = MessageNotificationModelBuilder.buildModel(with: message.user, message: message.message ?? "", isUserLeaveNoti: isUserLeaveNoti, isUserJoinNoti: isUserJoinNoti)
            newMessageList.append(model)
        }
        guard let inRoomNotificationView = inRoomNotificationView else { return }
        for notificationMessage in newMessageList {
            if inRoomNotificationView.messageNotificationList.count >= 3 {
                inRoomNotificationView.messageNotificationList.remove(at: 0)
                inRoomNotificationView.messageNotificationList.append(notificationMessage)
            } else {
                inRoomNotificationView.messageNotificationList.append(notificationMessage)
            }
        }
        self.inRoomNotificationView?.updateHeight()
        self.inRoomNotificationView?.tableView.reloadData()
    }
    
}
