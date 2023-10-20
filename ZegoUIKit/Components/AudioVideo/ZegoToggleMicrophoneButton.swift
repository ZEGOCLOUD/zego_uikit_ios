//
//  ToggleMicButton.swift
//  ZegoUIKit
//
//  Created by zego on 2022/7/25.
//

import UIKit

public protocol ToggleMicrophoneButtonDelegate: AnyObject {
    func onToggleMicButtonClick(_ isOn: Bool)
}

extension ToggleMicrophoneButtonDelegate {
    func onToggleMicButtonClick(_ isOn: Bool) { }
}

public class ZegoToggleMicrophoneButton: UIButton {
    
    public var userID: String? = ZegoUIKit.shared.localUserInfo?.userID {
        didSet {
            guard let userID = userID else { return }
            self.isOn = ZegoUIKit.shared.isMicrophoneOn(userID)
        }
    }
    public var isOn: Bool = true {
        didSet {
            self.isSelected = !isOn
        }
    }
    public weak var delegate: ToggleMicrophoneButtonDelegate?
    
    public var iconMicrophoneOn: UIImage? = ZegoUIIconSet.iconMicNormal {
        didSet {
            self.setImage(iconMicrophoneOn, for: .normal)
        }
    }
    public var iconMicrophoneOff: UIImage? = ZegoUIIconSet.iconMicOff {
        didSet {
            self.setImage(iconMicrophoneOff, for: .selected)
        }
    }
    
    public var muteMode: Bool = false
    
    private let help = ZegoToggleMicrophoneButton_Help()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.help.toggleMicrophoneButton = self
        ZegoUIKit.shared.addEventHandler(self.help)
        self.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        self.setImage(self.iconMicrophoneOn, for: .normal)
        self.setImage(self.iconMicrophoneOff, for: .selected)
        if let userID = userID,
           ZegoUIKit.shared.isMicrophoneOn(userID)
        {
            self.isSelected = false
            self.isOn = true
        } else {
            self.isSelected = true
            self.isOn = false
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonClick() {
        self.isOn = !self.isOn
        ZegoUIKit.shared.turnMicrophoneOn(userID ?? "", isOn: self.isOn, mute: muteMode)
        self.delegate?.onToggleMicButtonClick(self.isOn)
    }

}

class ZegoToggleMicrophoneButton_Help: NSObject, ZegoUIKitEventHandle {
    
    weak var toggleMicrophoneButton: ZegoToggleMicrophoneButton?
    
    func onMicrophoneOn(_ user: ZegoUIKitUser, isOn: Bool) {
        if user.userID == toggleMicrophoneButton?.userID {
            toggleMicrophoneButton?.isOn = isOn
        }
    }
    
}
