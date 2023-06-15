//
//  ZegoInRoomChatView.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/9/29.
//

import UIKit

@objc public protocol ZegoInRoomChatViewDelegate: AnyObject {
    @objc optional func getChatViewItemView(_ tableView: UITableView, indexPath: IndexPath, message: ZegoInRoomMessage) -> UITableViewCell?
    @objc optional func getChatViewItemHeight(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, message: ZegoInRoomMessage) -> CGFloat
    @objc optional func getChatViewHeaderHeight(_ tableView: UITableView, section: Int) -> CGFloat
    @objc optional func getChatViewForHeaderInSection(_ tableView: UITableView, section: Int) -> UIView?
}

public class ZegoInRoomChatView: UIView {
    
    public weak var delegate: ZegoInRoomChatViewDelegate?
    
    fileprivate var messageList: [RoomChatMessageModel] = [RoomChatMessageModel]()
    
    var currentIsInBottom: Bool = true
    
    let help = ZegoInRoomChatView_Help()
    
    fileprivate lazy var tableView: UITableView = {
        let messageTable = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height), style: UITableView.Style.plain)
        return messageTable
    }()
    
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
        self.tableView.register(ZegoUIKitInRoomChatViewCell.self, forCellReuseIdentifier: "ZegoUIKitInRoomChatViewCell")
        self.addSubview(self.tableView)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        RoomChatMessageModelBuilder.messageViewWidth = UIKitAdaptLandscapeWidth(241)
        self.help.inRoomChatView = self
        ZegoUIKit.shared.addEventHandler(self.help)
        self.setupTableView()
        self.getAllMessage()
        self.scrollToBottom()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    @objc public func registerCell(_ cellClass: AnyClass?, forCellReuseIdentifier: String) {
        self.tableView.register(cellClass, forCellReuseIdentifier: forCellReuseIdentifier)
    }
    
    @objc public func registerNibCell(_ nib: UINib?, forCellReuseIdentifier: String) {
        self.tableView.register(nib, forCellReuseIdentifier: forCellReuseIdentifier)
    }
    
    fileprivate func getAllMessage() {
        self.messageList.removeAll()
        for message in ZegoUIKit.shared.getInRoomMessages() {
            let model: RoomChatMessageModel = RoomChatMessageModelBuilder.buildChatRoomMessageModel(message)
            self.messageList.append(model)
        }
        self.tableView.reloadData()
    }
    
    public func scrollToLastLine() {
        if self.messageList.count == 0 {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            //code
            let indexPath: IndexPath = IndexPath.init(row: self.messageList.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: true)
        }
    }
    
    func scrollToBottom() -> Void {
        if !self.currentIsInBottom {
            return
        }
        if self.messageList.count == 0 {
            return
        }
        let indexPath: IndexPath = IndexPath.init(row: self.messageList.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: true)
    }
    
}

class ZegoInRoomChatView_Help: NSObject, ZegoUIKitEventHandle, UITableViewDelegate,UITableViewDataSource, ZegoUIKitInRoomChatViewCellDelegate, UIScrollViewDelegate {
    
    weak var inRoomChatView: ZegoInRoomChatView?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inRoomChatView?.messageList.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let inRoomChatView = inRoomChatView else {
            return UITableViewCell()
        }
        if indexPath.row < inRoomChatView.messageList.count {
            let index: Int = indexPath.row
            let messageModel: RoomChatMessageModel = inRoomChatView.messageList[index]
            let user: ZegoUIKitUser = ZegoUIKitUser.init(messageModel.userID ?? "", messageModel.userName ?? "")
            let roomMessage: ZegoInRoomMessage = ZegoInRoomMessage.init(messageModel.content ?? "", messageID: messageModel.messageID, sendTime: UInt64(Int(messageModel.sendTime ?? "0") ?? 0), user: user)
            let cell: UITableViewCell? = inRoomChatView.delegate?.getChatViewItemView?(tableView, indexPath: indexPath, message: roomMessage)
            if let cell = cell {
                return cell
            }
            let messageCell: ZegoUIKitInRoomChatViewCell = tableView.dequeueReusableCell(withIdentifier: "ZegoUIKitInRoomChatViewCell") as! ZegoUIKitInRoomChatViewCell
            messageCell.messageModel = messageModel
            messageCell.selectionStyle = .none
            messageCell.backgroundColor = UIColor.clear
            messageCell.delegate = self
            return messageCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let inRoomChatView = inRoomChatView else { return 0 }
        let messageModel: RoomChatMessageModel = inRoomChatView.messageList[indexPath.row]
        let user: ZegoUIKitUser = ZegoUIKitUser.init(messageModel.userID ?? "", messageModel.userName ?? "")
        let roomMessage: ZegoInRoomMessage = ZegoInRoomMessage.init(messageModel.content ?? "", messageID: messageModel.messageID, sendTime: UInt64(Int64(Int(messageModel.sendTime ?? "0") ?? 0)), user: user)
        let height: CGFloat = inRoomChatView.delegate?.getChatViewItemHeight?(tableView, heightForRowAt: indexPath, message: roomMessage) ?? messageModel.messageHeight + 18 + 8.0 + 3 + 17 + 9
        if height == -1 {
            return messageModel.messageHeight + 18 + 8.0 + 3 + 17 + 9
        } else {
            return height
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.inRoomChatView?.delegate?.getChatViewHeaderHeight?(tableView, section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.inRoomChatView?.delegate?.getChatViewForHeaderInSection?(tableView, section: section)
    }
    
    //MARK: -UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height: CGFloat = scrollView.frame.size.height;
        let contentOffsetY: CGFloat = scrollView.contentOffset.y;
        let bottomOffset: CGFloat = scrollView.contentSize.height - contentOffsetY;
        if ((bottomOffset - height) < 5 || (bottomOffset - height) > -5)
        {
            self.inRoomChatView?.currentIsInBottom = true;
        } else {
            self.inRoomChatView?.currentIsInBottom = false;
        }
    }
    
    //MARK: -ZegoUIKitEventHandle
    func onInRoomMessageReceived(_ messageList: [ZegoInRoomMessage]) {
        self.inRoomChatView?.getAllMessage()
        self.inRoomChatView?.scrollToBottom()
    }
    
    func onInRoomMessageSendingStateChanged(_ message: ZegoInRoomMessage) {
        guard let inRoomChatView = inRoomChatView else { return }
        inRoomChatView.getAllMessage()
        self.inRoomChatView?.scrollToBottom()
    }
    
    //MARK: -ZegoUIKitInRoomChatViewCellDelegate
    func resendButtonDidClick(_ messageModel: RoomChatMessageModel) {
        guard let content = messageModel.content,
        let userID = messageModel.userID,
        let userName = messageModel.userName
        else { return }
        let message: ZegoInRoomMessage = ZegoInRoomMessage.init(content, messageID: messageModel.messageID, sendTime: 0, user: ZegoUIKitUser.init(userID, userName))
        ZegoUIKit.shared.resendInRoomMessage(message)
    }
}
