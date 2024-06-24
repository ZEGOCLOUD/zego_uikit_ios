//
//  MicStatusIcon.swift
//  ZegoUIKit
//
//  Created by zego on 2022/7/25.
//

import UIKit
import ZegoExpressEngine

public class ZegoMicrophoneStateIcon: UIImageView {

    public var userID: String? = ZegoUIKit.shared.localUserInfo?.userID {
        didSet {
            guard let userID = userID else { return }
            self.isOn = ZegoUIKit.shared.isMicrophoneOn(userID)
        }
    }
    public var iconMicrophoneOn: UIImage = ZegoUIIconSet.iconMicStatusNormal
    public var iconMicrophoneOff: UIImage = ZegoUIIconSet.iconMicStatusOff
    public var iconMicrophoneSpeaking: UIImage = ZegoUIIconSet.iconMicStatusWave
    public var isOn: Bool = true {
        didSet {
            if isOn {
                self.image = self.iconMicrophoneOn
            } else {
                self.image = self.iconMicrophoneOff
            }
        }
    }
    
    private var help: MicStatusIcon_Help = MicStatusIcon_Help()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.help.micStatusIcon = self
        ZegoUIKit.shared.addEventHandler(self.help)
        self.isOn = true
        self.image = self.iconMicrophoneOn
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate class MicStatusIcon_Help: NSObject, ZegoUIKitEventHandle {
    
    weak var micStatusIcon: ZegoMicrophoneStateIcon?
    override init() {
        super.init()
        
    }
    
    func onMicrophoneOn(_ user: ZegoUIKitUser, isOn: Bool) {
        if self.micStatusIcon?.userID == user.userID {
            self.micStatusIcon?.isOn = isOn
        }
    }
    
    func onSoundLevelUpdate(_ userInfo: ZegoUIKitUser, level: Double) {
        guard let micStatusIcon = self.micStatusIcon else { return }
        if userInfo.userID == self.micStatusIcon?.userID {
            if level > 5 {
                micStatusIcon.image = micStatusIcon.iconMicrophoneSpeaking
            } else {
                self.micStatusIcon?.isOn = micStatusIcon.isOn
            }
        }
    }
}
