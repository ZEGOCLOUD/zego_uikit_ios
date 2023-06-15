//
//  ZegoStartInvitationButton.swift
//  ZegoUIKit
//
//  Created by zego on 2022/8/9.
//

import UIKit

@objc public protocol ZegoStartInvitationButtonDelegate: AnyObject{
    func onStartInvitationButtonClick(_ data: [String : AnyObject]?)
}

extension ZegoStartInvitationButtonDelegate {
    func onStartInvitationButtonClick(_ data: [String : AnyObject]?) { }
}

@objc open class ZegoStartInvitationButton: UIButton {

    @objc public var icon: UIImage? {
        didSet {
            guard let icon = icon else {
                return
            }
            self.setImage(icon, for: .normal)
        }
    }
    @objc public var text: String? {
        didSet {
            self.setTitle(text, for: .normal)
        }
    }
    @objc public var invitees: [String] = []
    @objc public var data: String?
    @objc public var timeout: UInt32 = 60
    @objc public var type: Int = 0
    @objc public weak var delegate: ZegoStartInvitationButtonDelegate?

    @objc public init(_ type: Int) {
        super.init(frame: CGRect.zero)
        if type == 0 {
            self.setImage(ZegoUIIconSet.iconUsePhone, for: .normal)
        } else {
            self.setImage(ZegoUIIconSet.iconUseVideo, for: .normal)
        }
        self.type = type
        self.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
    }
    
    @objc open func buttonClick() {
        if invitees.count == 0 {
            return
        }
        ZegoUIKitSignalingPluginImpl.shared.sendInvitation(self.invitees, timeout: self.timeout, type: self.type, data: self.data, notificationConfig: nil) { data in
            self.delegate?.onStartInvitationButtonClick(data)
        }
    }
    
}
