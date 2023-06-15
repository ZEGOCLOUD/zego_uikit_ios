//
//  ZegoBaseAudioVideoForegroundView.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2023/2/13.
//

import UIKit

public protocol ZegoBaseAudioVideoForegroundViewDelegate:AnyObject {
    func onForegroundViewCreated(_ uikitUser: ZegoUIKitUser?)
    func onCameraStateChanged(_ isCameraOn: Bool)
    func onMicrophoneStateChanged(_ isMicrophoneOn: Bool)
    func onInRoomAttributesUpdated(_ inRoomAttributes: [String : String])
}

extension ZegoBaseAudioVideoForegroundViewDelegate {
    func onForegroundViewCreated(_ uikitUser: ZegoUIKitUser?){ }
    func onCameraStateChanged(_ isCameraOn: Bool) { }
    func onMicrophoneStateChanged(_ isMicrophoneOn: Bool) { }
    func onInRoomAttributesUpdated(_ inRoomAttributes: [String : String]) { }
}

open class ZegoBaseAudioVideoForegroundView: UIView {
    
    public weak var delegate: ZegoBaseAudioVideoForegroundViewDelegate?
    fileprivate var userID: String?
    
    public init(frame: CGRect, userID: String?, delegate: ZegoBaseAudioVideoForegroundViewDelegate?) {
        super.init(frame: frame)
        ZegoUIKit.shared.addEventHandler(self)
        self.userID = userID
        self.delegate?.onForegroundViewCreated(ZegoUIKit.shared.getUser(userID ?? ""))
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ZegoBaseAudioVideoForegroundView: ZegoUIKitEventHandle {
    
    open func onCameraOn(_ user: ZegoUIKitUser, isOn: Bool) {
        if self.userID == user.userID {
            self.delegate?.onCameraStateChanged(isOn)
        }
    }
    
    open func onMicrophoneOn(_ user: ZegoUIKitUser, isOn: Bool) {
        if self.userID == user.userID {
            self.delegate?.onMicrophoneStateChanged(isOn)
        }
    }
    
    open func onUsersInRoomAttributesUpdated(_ updateKeys: [String]?, oldAttributes: [ZegoUserInRoomAttributesInfo]?, attributes: [ZegoUserInRoomAttributesInfo]?, editor: ZegoUIKitUser?) {
        guard let attributes = attributes else { return }
        for attribute in attributes {
            if let userID = self.userID,
               userID == attribute.userID
            {
                self.delegate?.onInRoomAttributesUpdated(attribute.attributes)
            }
        }
    }
    
}
