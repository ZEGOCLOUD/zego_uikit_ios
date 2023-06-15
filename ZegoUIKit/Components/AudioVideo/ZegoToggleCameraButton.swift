//
//  ToggleCameraButton.swift
//  ZegoUIKit
//
//  Created by zego on 2022/7/25.
//

import UIKit

public protocol ZegoToggleCameraButtonDelegate: AnyObject {
    func onToggleCameraButtonClick(_ isOn: Bool)
}

extension ZegoToggleCameraButtonDelegate {
    func onToggleCameraButtonClick(_ isOn: Bool) { }
}


public class ZegoToggleCameraButton: UIButton {
    
    public weak var delegate: ZegoToggleCameraButtonDelegate?
    public var userID: String? = ZegoUIKit.shared.localUserInfo?.userID {
        didSet {
            guard let userID = userID else { return }
            self.isOn = ZegoUIKit.shared.isCameraOn(userID)
        }
    }
    public var iconCameraOn: UIImage? {
        didSet {
            self.setImage(iconCameraOn, for: .selected)
        }
    }
    public var iconCameraOff: UIImage? {
        didSet {
            self.setImage(iconCameraOff, for: .normal)
        }
    }
    
    public var isOn: Bool = true {
        didSet {
            if isOn {
                self.isSelected = true
            } else {
                self.isSelected = false
            }
        }
    }
    
    private let help = ZegoToggleCameraButton_Help()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.help.toggleCameraButton = self
        ZegoUIKit.shared.addEventHandler(self.help)
        self.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        self.setImage(ZegoUIIconSet.iconCameraOn, for: .selected)
        self.setImage(ZegoUIIconSet.iconCameraOff, for: .normal)
        if let userID = userID,
           ZegoUIKit.shared.isCameraOn(userID)
        {
            self.isSelected = true
            self.isOn = true
        } else {
            self.isSelected = false
            self.isOn = false
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func buttonClick(sender: UIButton) {
        self.isOn = !self.isOn
        ZegoUIKit.shared.turnCameraOn(userID ?? "", isOn: isOn)
        self.delegate?.onToggleCameraButtonClick(self.isOn)
    }
}

class ZegoToggleCameraButton_Help: NSObject, ZegoUIKitEventHandle {
    
    weak var toggleCameraButton: ZegoToggleCameraButton?
    
    func onCameraOn(_ user: ZegoUIKitUser, isOn: Bool) {
        if user.userID == toggleCameraButton?.userID {
            toggleCameraButton?.isOn = isOn
        }
    }
    
}

