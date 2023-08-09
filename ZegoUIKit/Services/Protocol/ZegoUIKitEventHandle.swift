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
    @objc optional func onOnlySelfInRoom()
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
    @objc optional func onAudioOutputDeviceChange(_ audioRoute: ZegoUIKitAudioOutputDevice)
    
    //MARK: - call invitation
    @objc optional func onInvitationReceived(_ inviter: ZegoUIKitUser, type: Int, data: String?)
    @objc optional func onInvitationTimeout(_ inviter: ZegoUIKitUser, data: String?)
    @objc optional func onInvitationResponseTimeout(_ invitees: [ZegoUIKitUser], data: String?)
    @objc optional func onInvitationAccepted(_ invitee: ZegoUIKitUser, data: String?)
    @objc optional func onInvitationRefused(_ invitee: ZegoUIKitUser, data: String?)
    @objc optional func onInvitationCanceled(_ inviter: ZegoUIKitUser, data: String?)
    
    //MARK: - room message
    @objc optional func onInRoomMessageReceived(_ messageList: [ZegoInRoomMessage])
    @objc optional func onInRoomMessageSendingStateChanged(_ message: ZegoInRoomMessage)
    @objc optional func onSignalingPluginConnectionState(_ params: [String: AnyObject])
    @objc optional func onInRoomCommandReceived(_ fromUser: ZegoUIKitUser, command: String)
    @objc optional func onInRoomTextMessageReceived(_ messages: [ZegoSignalingInRoomTextMessage], roomID: String)
    @objc optional func onInRoomCommandMessageReceived(_ messages: [ZegoSignalingInRoomCommandMessage], roomID: String)
    
    //MARK: - user in room attributs
    @objc optional func onUsersInRoomAttributesUpdated(_ updateKeys: [String]?, oldAttributes: [ZegoUserInRoomAttributesInfo]?, attributes: [ZegoUserInRoomAttributesInfo]?, editor: ZegoUIKitUser?)
    @objc optional func onRoomMemberLeft(_ userIDList: [String]?, roomID: String)
    @objc optional func onMeRemovedFromRoom()
    @objc optional func onTurnOnYourCameraRequest(_ fromUser: ZegoUIKitUser)
    @objc optional func onTurnOnYourMicrophoneRequest(_ fromUser: ZegoUIKitUser)
}

