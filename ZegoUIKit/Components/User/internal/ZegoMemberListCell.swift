//
//  ZegoMemberListCell.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/9/13.
//

import UIKit

class ZegoMemberListCell: UITableViewCell {
    
    var showMicrophoneState: Bool = true {
        didSet {
            self.micIcon.isHidden = !showMicrophoneState
            self.setupLayout()
        }
    }
    var showCameraState: Bool = true {
        didSet {
            self.cameraIcon.isHidden = !showCameraState
            self.setupLayout()
        }
    }
    
    var userInfo: ZegoUIKitUser? {
        didSet {
            guard let userInfo = userInfo else {
                return
            }
            self.cameraIcon.userID = userInfo.userID
            self.micIcon.userID = userInfo.userID
            if let userName = userInfo.userName {
                if userName.count > 0 {
                    let firstStr: String = String(userName[userName.startIndex])
                    self.userHead.text = firstStr
                }
                if userInfo.userID == ZegoUIKit.shared.localUserInfo?.userID {
                    self.userNameLabel.text = String(format: "%@%@", userName,ZegoUIKitTranslationTextConfig.shared.translationText.userIdentityYou)
                } else {
                    self.userNameLabel.text = userName
                }
            }
        }
    }
    
    lazy var userHead: UILabel = {
        let head: UILabel = UILabel()
        head.layer.masksToBounds = true
        head.layer.cornerRadius = 18
        head.backgroundColor = UIColor.colorWithHexString("#D8D8D8")
        head.textColor = UIColor.colorWithHexString("#222222")
        head.textAlignment = .center
        head.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return head
    }()
    
    lazy var userNameLabel: UILabel = {
        let userName: UILabel = UILabel()
        userName.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        userName.textColor = UIColor.colorWithHexString("#FFFFFF")
        return userName
    }()
    
    lazy var cameraIcon: ZegoCameraStateIcon = {
        let icon = ZegoCameraStateIcon(frame: .zero)
        icon.iconCameraOn = ZegoUIIconSet.iconMemberCamera
        icon.iconCameraOff = ZegoUIIconSet.iconMemberCameraOff
        return icon
    }()
    
    lazy var micIcon: ZegoMicrophoneStateIcon = {
        let icon = ZegoMicrophoneStateIcon(frame: .zero)
        icon.iconMicrophoneOn = ZegoUIIconSet.iconMemberMicNor
        icon.iconMicrophoneOff = ZegoUIIconSet.iconMemberMicOff
        icon.iconMicrophoneSpeaking = ZegoUIIconSet.iconMemberMicWave
        return icon
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.userHead)
        self.contentView.addSubview(self.userNameLabel)
        self.contentView.addSubview(self.cameraIcon)
        self.contentView.addSubview(self.micIcon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayout()
    }
    
    func setupLayout() {
        self.userHead.frame = CGRect(x: 18, y: 9, width: 36, height: 36)
        self.userNameLabel.frame = CGRect(x: self.userHead.frame.maxX + 10, y: 9, width: 150, height: 36)
        if self.showCameraState {
            self.cameraIcon.frame = CGRect(x: self.frame.size.width - 17 - 22, y: 16.5, width: 22, height: 22)
        } else {
            self.cameraIcon.frame = CGRect(x: self.frame.size.width, y: 16.5, width: 0, height: 22)
        }
        if self.showMicrophoneState {
            self.micIcon.frame = CGRect(x: self.cameraIcon.frame.minX - 12 - 22, y: 16.5, width: 22, height: 22)
        } else {
            self.micIcon.frame = CGRect(x: self.cameraIcon.frame.minX - 12 - 22, y: 16.5, width: 0, height: 22)
        }
    }
    
}
