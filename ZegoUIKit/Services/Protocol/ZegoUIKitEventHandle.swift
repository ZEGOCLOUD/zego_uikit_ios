//
//  ZegoUIKitEvent.swift
//  ZegoUIKit
//
//  Created by zego on 2022/7/25.
//

import UIKit
import ZegoExpressEngine
import ZegoPluginAdapter

@objc public protocol ZegoUIKitEventHandle: AnyObject {
    
    //MARK: - user
    @objc optional func onRemoteUserJoin(_ userList:[ZegoUIKitUser])
    @objc optional func onRemoteUserLeave(_ userList:[ZegoUIKitUser])
    @objc optional func onOnlySelfInRoom(_ userList:[ZegoUIKitUser])
    @objc optional func onUserCountOrPropertyChanged(_ userList:[ZegoUIKitUser]?)
    
    //MARK: - room
    @objc optional func onRoomStateChanged(_ reason: ZegoUIKitRoomStateChangedReason, errorCode: Int32, extendedData: [AnyHashable : Any], roomID: String)
    @objc optional func onRoomPropertyUpdated(_ key: String, oldValue: String, newValue: String)
    @objc optional func onRoomPropertiesFullUpdated(_ updateKeys: [String], oldProperties: [String : String], properties: [String : String])
    
    //MARK: -audio video
    @objc optional func onCameraOn(_ user: ZegoUIKitUser, isOn: Bool)
    @objc optional func onMicrophoneOn(_ user: ZegoUIKitUser, isOn: Bool)
    @objc optional func onSoundLevelUpdate(_ userInfo: ZegoUIKitUser, level: Double)
    @objc optional func onAudioVideoAvailable(_ userList: [ZegoUIKitUser])
    @objc optional func onAudioVideoUnavailable(_ userList: [ZegoUIKitUser])
    @objc optional func onScreenSharingAvailable(_ userList: [ZegoUIKitUser])
    @objc optional func onScreenSharingUnavailable(_ userList: [ZegoUIKitUser])
    @objc optional func onAudioOutputDeviceChanged(_ audioOutput: ZegoUIKitAudioOutputDevice)
    @objc optional func onPlayerRecvSEI(_ seiString: String, streamID: String)
    @objc optional func onPlayerRecvAudioFirstFrame(_ streamID: String)
    @objc optional func onPlayerRecvVideoFirstFrame(_ streamID: String)
    
    
    //MARK: - room message
    @objc optional func onInRoomMessageReceived(_ messageList: [ZegoInRoomMessage])
    @objc optional func onInRoomMessageSendingStateChanged(_ message: ZegoInRoomMessage)
    @objc optional func onInRoomCommandReceived(_ fromUser: ZegoUIKitUser, command: String)
    @objc optional func onInRoomTextMessageReceived(_ messages: [ZegoSignalingInRoomTextMessage], roomID: String)
    @objc optional func onInRoomCommandMessageReceived(_ messages: [ZegoSignalingInRoomCommandMessage], roomID: String)
    @objc optional func onIMRecvBarrageMessage(_ roomID: String, messageList: [ZegoUIKitBarrageMessageInfo])
    //MARK: - user in room attributs
    @objc optional func onRoomMemberLeft(_ userIDList: [String]?, roomID: String)
    @objc optional func onMeRemovedFromRoom()
    @objc optional func onTurnOnYourCameraRequest(_ fromUser: ZegoUIKitUser)
    @objc optional func onTurnOnYourMicrophoneRequest(_ fromUser: ZegoUIKitUser)
    
    //MARK: - signal plugin
    @objc optional func onSignalingPluginConnectionState(_ params: [String: AnyObject])
    @objc optional func onIMRoomStateChanged(_ state: Int, event: Int, roomID: String)
    @objc optional func onInvitationReceived(_ inviter: ZegoUIKitUser, type: Int, data: String?)
    @objc optional func onInvitationTimeout(_ inviter: ZegoUIKitUser, data: String?)
    @objc optional func onInvitationResponseTimeout(_ invitees: [ZegoUIKitUser], data: String?)
    @objc optional func onInvitationAccepted(_ invitee: ZegoUIKitUser, data: String?)
    @objc optional func onInvitationRefused(_ invitee: ZegoUIKitUser, data: String?)
    @objc optional func onInvitationCanceled(_ inviter: ZegoUIKitUser, data: String?)
    @objc optional func onSignalPluginRoomPropertyUpdated(_ key: String, oldValue: String, newValue: String)
    @objc optional func onSignalPluginRoomPropertyFullUpdated(_ updateKeys: [String], oldProperties: [String : String], properties: [String : String])
    @objc optional func onUsersInRoomAttributesUpdated(_ updateKeys: [String]?, oldAttributes: [ZegoUserInRoomAttributesInfo]?, attributes: [ZegoUserInRoomAttributesInfo]?, editor: ZegoUIKitUser?)
    
    @objc optional func onRemoteVideoFrameCVPixelBuffer(_ buffer: CVPixelBuffer, param: ZegoVideoFrameParam, streamID: String)
    
    @objc optional func onCapturedVideoFrameCVPixelBuffer(_ buffer: CVPixelBuffer, param: ZegoVideoFrameParam, flipMode: ZegoVideoFlipMode, channel: ZegoPublishChannel)
    
}

