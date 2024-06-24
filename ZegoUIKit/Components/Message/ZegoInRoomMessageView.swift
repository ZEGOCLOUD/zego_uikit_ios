//
//  ZegoInRoomMessageView.swift
//  ZegoUIKit
//
//  Created by zego on 2022/8/22.
//

import UIKit

public class ZegoInRoomMessageView: UIView {
    
    public weak var delegate: ZegoInRoomMessageViewDelegate?
    
    fileprivate var maxHeight: CGFloat = 200
    
    fileprivate var messageList: [MessageModel] = [MessageModel]()
    
    private let help: ZegoInRoomMessageView_Help = ZegoInRoomMessageView_Help()
    
    var originalDataList:[ZegoInRoomMessage] = [ZegoInRoomMessage]()
    
    var lastOffsetY: CGFloat = 0
    var minHeight: CGFloat = 0
    var lastFrame: CGRect?
    
    fileprivate lazy var tableView: UITableView = {
        let messageTable = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height), style: UITableView.Style.plain)
        return messageTable
    }()
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initRoomMessageView()
        self.setupTableView()
    }
    
    @objc public init(frame: CGRect,customerRegisterCell:Bool = false) {
        super.init(frame: frame)
        self.initRoomMessageView()
        self.setupTableView(customerRegisterCell: customerRegisterCell)
    }
    
    private func initRoomMessageView() {
        self.help.roomMessageView = self
        ZegoUIKit.shared.addEventHandler(self.help)
        self.getAllMessage()
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
            MessageModelBuilder.messageViewWidth = self.frame.size.width
            self.tableView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            self.getAllMessage()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func registerClassForCellReuseIdentifier(_ cellClass: AnyClass?, forCellReuseIdentifier: String) {
        self.tableView.register(cellClass, forCellReuseIdentifier: forCellReuseIdentifier)
    }
    
    fileprivate func getAllMessage() {
        self.messageList.removeAll()
        self.originalDataList = ZegoUIKit.shared.getInRoomMessages()
        var height: CGFloat = 0
        for message in ZegoUIKit.shared.getInRoomMessages() {
            let model = MessageModelBuilder.buildModel(with: message.user, message: message.message ?? "")
            self.messageList.append(model)
            height = height + (model.messageHeight + 10 + 4) > maxHeight ? maxHeight : height + (model.messageHeight + 10 + 4)
        }
        self.lastOffsetY = 0
        self.updateHeight(height)
        self.tableView.reloadData()
    }
    
    private func setupTableView(customerRegisterCell:Bool = false) {
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
        if customerRegisterCell == false {
            self.tableView.register(ZegoUIKitMessageCell.self, forCellReuseIdentifier: "ZegoUIKitMessageCell")
        }
        self.addSubview(self.tableView)
    }
    
    func updateHeight(_ height: CGFloat) {
        let offsetY = height - self.frame.size.height
        if lastOffsetY == offsetY {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
        } else {
            let newOffsetY: CGFloat = lastOffsetY - offsetY
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y + newOffsetY, width: self.frame.size.width, height: height)
        }
        lastOffsetY = offsetY
    }
    
}

class ZegoInRoomMessageView_Help: NSObject, ZegoUIKitEventHandle {
    
    weak var roomMessageView: ZegoInRoomMessageView?
    
    func onInRoomMessageReceived(_ messageList: [ZegoInRoomMessage]) {
        self.roomMessageView?.originalDataList.append(contentsOf: messageList)
        
        var newMessageList = [MessageModel]()
        for message in messageList {
            let model = MessageModelBuilder.buildModel(with: message.user, message: message.message ?? "")
            newMessageList.append(model)
        }
        self.roomMessageView?.messageList.append(contentsOf: newMessageList)
        self.roomMessageView?.tableView.reloadData()
        
        var height: CGFloat = 0
        for model in self.roomMessageView?.messageList ?? [] {
            height = height + (model.messageHeight + 10 + 4) > self.roomMessageView?.maxHeight ?? 200 ? self.roomMessageView?.maxHeight ?? 200 : height + (model.messageHeight + 10 + 4)
        }
        self.roomMessageView?.updateHeight(height)
        self.scrollToBottom()
    }
    
    func onInRoomMessageSendingStateChanged(_ message: ZegoInRoomMessage) {
        self.roomMessageView?.getAllMessage()
        self.scrollToBottom()
    }
    
    
    
    func scrollToBottom() -> Void {
        guard let roomMessageView = roomMessageView else { return }
        if roomMessageView.messageList.count == 0 {
            return
        }
        roomMessageView.layoutIfNeeded()
        let indexPath: IndexPath = IndexPath.init(row: roomMessageView.messageList.count - 1, section: 0)
        roomMessageView.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: true)
    }
}

extension ZegoInRoomMessageView_Help: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.roomMessageView?.messageList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.roomMessageView?.delegate?.getInRoomMessageItemView?(tableView, indexPath: indexPath, message: self.roomMessageView!.originalDataList[indexPath.row])

        guard let cell = cell else {
            if let _ = tableView.dequeueReusableCell(withIdentifier: "ZegoUIKitMessageCell") as? ZegoUIKitMessageCell {
                    
            } else {
                self.roomMessageView?.tableView.register(ZegoUIKitMessageCell.self, forCellReuseIdentifier: "ZegoUIKitMessageCell")
            }
                
            let messageCell: ZegoUIKitMessageCell = tableView.dequeueReusableCell(withIdentifier: "ZegoUIKitMessageCell") as! ZegoUIKitMessageCell
            if indexPath.row < self.roomMessageView?.messageList.count ?? 0 {
                let index: Int = indexPath.row
                messageCell.messageModel = self.roomMessageView?.messageList[index]
            }
            messageCell.selectionStyle = .none
            messageCell.backgroundColor = UIColor.clear
            return messageCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let roomMessageView = roomMessageView else { return 0 }
        let model: MessageModel = roomMessageView.messageList[indexPath.row]
        return model.messageHeight + 10.0 + 4.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messages = ZegoUIKit.shared.getInRoomMessages()
        if indexPath.row < messages.count {
            let message = messages[indexPath.row]
            roomMessageView?.delegate?.onInRoomMessageClick?(message)
        }
    }
}

