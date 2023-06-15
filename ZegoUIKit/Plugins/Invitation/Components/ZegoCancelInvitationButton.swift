//
//  ZegoCancelInvitationButton.swift
//  ZegoUIKit
//
//  Created by zego on 2022/8/11.
//

import UIKit

public protocol ZegoCancelInvitationButtonDelegate: AnyObject {
    func onCancelInvitationButtonClick()
}

extension ZegoCancelInvitationButtonDelegate {
    func onCancelInvitationButtonClick() {}
}

open class ZegoCancelInvitationButton: UIButton {

    public var icon: UIImage = ZegoUIIconSet.iconCallCancel {
        didSet {
            self.setImage(self.icon, for: .normal)
        }
    }
    public var text: String? {
        didSet {
            self.setTitle(text, for: .normal)
        }
    }
    public var invitees: [String] = []
    public var data: String?
    public weak var delegate: ZegoCancelInvitationButtonDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        self.setImage(self.icon, for: .normal)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        self.setImage(self.icon, for: .normal)
    }
    
    @objc open func buttonClick() {
        self.delegate?.onCancelInvitationButtonClick()
        if invitees.count == 0 {
            return
        }
        ZegoUIKitSignalingPluginImpl.shared.cancelInvitation(self.invitees, data: self.data, callback: nil)
    }

}
