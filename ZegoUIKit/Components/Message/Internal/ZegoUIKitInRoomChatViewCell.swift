//
//  ZegoUIKitInRoomChatViewCell.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/9/29.
//

import UIKit

protocol ZegoUIKitInRoomChatViewCellDelegate: AnyObject {
    func resendButtonDidClick(_ messageModel: RoomChatMessageModel)
}

class ZegoUIKitInRoomChatViewCell: UITableViewCell {
    
    weak var delegate: ZegoUIKitInRoomChatViewCellDelegate?
    
    lazy var headLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor.colorWithHexString("#222222")
        label.backgroundColor = UIColor.colorWithHexString("#DBDDE3")
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.colorWithHexString("#CDCDCD")
        return label
    }()
    
    lazy var bubbleView: UIView = {
        let bubble: UIView = UIView()
        return bubble
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.colorWithHexString("#FFFFFF")
        return label
    }()
    
    lazy var loadingIconButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.addTarget(self, action: #selector(loadingButtonClick), for: .touchUpInside)
        return button
    }()
    
    var messageModel: RoomChatMessageModel? {
        didSet {
            guard let messageModel = messageModel else { return }
            let userName = messageModel.userName ?? ""
            let firstStr: String = String(userName[userName.startIndex])
            self.headLabel.text = firstStr
            
            self.nameLabel.textAlignment = messageModel.isSelf ? .right:.left
            
            let attributeStr: NSMutableAttributedString = NSMutableAttributedString()
            let nameStr = NSMutableAttributedString.init(string: messageModel.userName ?? "")
            nameStr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.colorWithHexString("#CDCDCD"), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)], range: NSRange.init(location: 0, length: messageModel.userName?.count ?? 0))
            let sendTime: Double = Double(messageModel.sendTime ?? "0") ?? 0
            let timeStr = NSMutableAttributedString.init(string: self.timeStampToString(timeStamp: sendTime))
            timeStr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.colorWithHexString("#A4A4A4"), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)], range: NSRange.init(location: 0, length: self.timeStampToString(timeStamp: sendTime).count))
            if messageModel.isSelf {
                attributeStr.append(timeStr)
                attributeStr.append(NSAttributedString.init(string: " "))
                attributeStr.append(nameStr)
            } else {
                attributeStr.append(nameStr)
                attributeStr.append(NSAttributedString.init(string: " "))
                attributeStr.append(timeStr)
            }
            self.nameLabel.attributedText = attributeStr
            self.messageLabel.attributedText = messageModel.attributedContent
            self.bubbleView.backgroundColor = messageModel.isSelf ? UIColor.colorWithHexString("#0055FF") : UIColor.colorWithHexString("#FFFFFF",alpha: 0.1)
            
            if messageModel.state == .sending {
                self.loadingIconButton.isHidden = false
                self.loadingIconButton.setImage(ZegoUIIconSet.iconMessageLoading, for: .normal)
            } else if messageModel.state == .failed {
                self.loadingIconButton.isHidden = false
                self.loadingIconButton.setImage(ZegoUIIconSet.iconMessageFail, for: .normal)
            } else {
                self.loadingIconButton.isHidden = true
            }
        }
    }
    
    func timeStampToString(timeStamp: Double) -> String {
        let timeSta:TimeInterval = TimeInterval(timeStamp)
        let date = NSDate(timeIntervalSince1970: timeSta)
        let dateformatter = DateFormatter()
        dateformatter.amSymbol = "A.M"
        dateformatter.pmSymbol = "P.M"
        dateformatter.dateFormat="aaa HH:mm"
        return dateformatter.string(from: date as Date)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.headLabel)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.bubbleView)
        self.bubbleView.addSubview(self.messageLabel)
        self.contentView.addSubview(self.loadingIconButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayout()
    }
    
    @objc func loadingButtonClick() {
        guard let messageModel = messageModel else {
            return
        }
        if self.messageModel?.state == .failed {
            self.delegate?.resendButtonDidClick(messageModel)
        }
    }
    
    func setupLayout() {
        guard let messageModel = messageModel else { return }
        let headX = messageModel.isSelf ? self.frame.size.width - 15 - 28 : 15
        self.headLabel.frame = CGRect(x: headX, y: 8, width: 28, height: 28)
        self.headLabel.layer.masksToBounds = true
        self.headLabel.layer.cornerRadius = 14
        let nameX =  messageModel.isSelf ? self.headLabel.frame.minX - 12 - 200 : self.headLabel.frame.maxX + 12
        self.nameLabel.frame = CGRect(x: nameX, y: 9.5, width: 200, height: 16.5)
        let bubbleX = messageModel.isSelf ? self.headLabel.frame.minX - 12 - messageModel.messageWidth - 28 : self.headLabel.frame.maxX + 12
        self.bubbleView.frame = CGRect(x: bubbleX, y: self.nameLabel.frame.maxY + 3, width: messageModel.messageWidth + 28, height: messageModel.messageHeight + 18)
        self.bubbleView.layer.masksToBounds = true
        self.bubbleView.layer.cornerRadius = 14
        self.messageLabel.frame = CGRect(x: 14, y: 9, width: self.bubbleView.frame.width - 28, height: self.bubbleView.frame.size.height - 18)
        let loadX = messageModel.isSelf ? self.bubbleView.frame.minX - 7 - 20 : self.bubbleView.frame.maxX + 7
        self.loadingIconButton.frame = CGRect(x: loadX, y: self.bubbleView.frame.midY - 10, width: 20, height: 20)
    }
    
}
