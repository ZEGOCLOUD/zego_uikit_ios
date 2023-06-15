//
//  ZegoUIKitMessageNotificationCell.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/9/30.
//

import UIKit

class ZegoUIKitMessageNotificationCell: UITableViewCell {
    
    var messageModel: MessageNotificationModel? {
        didSet {
            guard let messageModel = messageModel else { return }
            self.messageLabel.attributedText = messageModel.attributedContent
        }
    }
    
    lazy var bubbleView: UIView = {
        let bubble = UIView()
        bubble.backgroundColor = UIColor.colorWithHexString("#2A2A2A", alpha: 0.3)
        bubble.layer.masksToBounds = true
        bubble.layer.cornerRadius = 8
        return bubble
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.colorWithHexString("#FFFFFF")
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.bubbleView)
        self.bubbleView.addSubview(self.messageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupUI()
    }
    
    func setupUI() {
        guard let messageModel = messageModel else { return }
        self.bubbleView.frame = CGRect.init(x: 0, y: 0, width: messageModel.messageWidth + 20, height: self.frame.size.height - 4)
        self.messageLabel.frame = CGRect.init(x: 10, y: 5, width: messageModel.messageWidth, height: self.frame.size.height - 10 - 4)
    }
    
}
