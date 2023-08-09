//
//  UIKitService.swift
//  ZegoUIKit
//
//  Created by zego on 2022/7/25.
//

import UIKit
import ZegoExpressEngine
import ZegoPluginAdapter

public typealias ZegoUIKitCallBack = (_ data: Dictionary<String, AnyObject>?) -> ()

public class ZegoUIKit: NSObject {
    
    /// @return UIKitService singleton instance
    public static let shared = ZegoUIKit()
    
    public var localUserInfo: ZegoUIKitUser? {
        get {
            let user: ZegoUIKitUser? = ZegoUIKitCore.shared.localParticipant?.toUserInfo()
            return user
        }
    }
    
    public var userList: [ZegoUIKitUser] {
        get {
            var users = [ZegoUIKitUser]()
            for participant in ZegoUIKitCore.shared.participantDic.values {
                users.append(participant.toUserInfo())
            }
            return users
        }
    }
    
    public let room: ZegoUIKitRoom? = ZegoUIKitCore.shared.room
    
    public var enableAudioVideoPlaying: Bool = true
    
    private let help: UIKitService_Help = UIKitService_Help()
    
    private override init() {
        super.init()
        ZegoUIKitCore.shared.addEventHandler(self.help)
    }

    public func initWithAppID(appID: UInt32, appSign: String) {
        ZegoUIKitCore.shared.initWithAppID(appID: appID, appSign: appSign)
    }
    
    public func uninit() {
        ZegoUIKitCore.shared.uninit()
    }
    
    public func getVersion() -> String {
        return "1.0.0"
    }
    
    public func addEventHandler(_ eventHandle: ZegoUIKitEventHandle?) {
        self.help.addEventHandler(eventHandle)
    }
    
    public static func getSignalingPlugin() -> ZegoUIKitSignalingPluginImpl {
        return ZegoUIKitSignalingPluginImpl.shared
    }

}

fileprivate class UIKitService_Help: NSObject, ZegoUIKitEventHandle {
    
    private let uikitEventDelegates: NSHashTable<ZegoUIKitEventHandle> = NSHashTable(options: .weakMemory)
    
    func addEventHandler(_ eventHandle: ZegoUIKitEventHandle?) {
        self.uikitEventDelegates.add(eventHandle)
    }
    
    func onRemoteUserJoin(_ userList: [ZegoUIKitUser]) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onRemoteUserJoin?(userList)
        }
    }
    
    func onRemoteUserLeave(_ userList: [ZegoUIKitUser]) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onRemoteUserLeave?(userList)
            if ZegoUIKit.shared.userList.count == 1 {
                delegate.onOnlySelfInRoom?()
            }
        }
    }
    
    func onRoomStateChanged(_ reason: ZegoUIKitRoomStateChangedReason, errorCode: Int32, extendedData: [AnyHashable : Any], roomID: String) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onRoomStateChanged?(reason, errorCode: errorCode, extendedData: extendedData, roomID: roomID)
        }
    }
    
    func onAudioVideoAvailable(_ userList: [ZegoUIKitUser]) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onAudioVideoAvailable?(userList)
        }
    }
    
    func onAudioVideoUnavailable(_ userList: [ZegoUIKitUser]) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onAudioVideoUnavailable?(userList)
        }
    }
    
    func onScreenSharingAvailable(_ userList: [ZegoUIKitUser]) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onScreenSharingAvailable?(userList)
        }
    }
    
    func onScreenSharingUnavailable(_ userList: [ZegoUIKitUser]) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onScreenSharingUnavailable?(userList)
        }
    }
    
    func onCameraOn(_ user: ZegoUIKitUser, isOn: Bool) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onCameraOn?(user, isOn: isOn)
        }
    }
    
    func onMicrophoneOn(_ user: ZegoUIKitUser, isOn: Bool) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onMicrophoneOn?(user, isOn: isOn)
        }
    }
    
    func onSoundLevelUpdate(_ userInfo: ZegoUIKitUser, level: Double) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onSoundLevelUpdate?(userInfo, level: level)
        }
    }
    
    func onAudioOutputDeviceChange(_ audioRoute: ZegoUIKitAudioOutputDevice) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onAudioOutputDeviceChange?(audioRoute)
        }
    }
    
    func onUserCountOrPropertyChanged(_ userList: [ZegoUIKitUser]?) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onUserCountOrPropertyChanged?(userList)
        }
    }
    
    func onRoomPropertyUpdated(_ key: String, oldValue: String, newValue: String) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onRoomPropertyUpdated?(key, oldValue: oldValue, newValue: newValue)
        }
    }
    
    func onRoomPropertiesFullUpdated(_ updateKeys: [String], oldProperties: [String : String], properties: [String : String]) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onRoomPropertiesFullUpdated?(updateKeys, oldProperties: oldProperties, properties: properties)
        }
    }
    
    //MARK: - call invitation
    func onInvitationReceived(_ inviter: ZegoUIKitUser, type: Int, data: String?) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onInvitationReceived?(inviter, type: type, data: data)
        }
    }
    
    func onInvitationTimeout(_ inviter: ZegoUIKitUser, data: String?) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onInvitationTimeout?(inviter, data: data)
        }
    }
    
    func onInvitationResponseTimeout(_ invitees: [ZegoUIKitUser], data: String?) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onInvitationResponseTimeout?(invitees, data: data)
        }
    }
    
    func onInvitationAccepted(_ invitee: ZegoUIKitUser, data: String?) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onInvitationAccepted?(invitee, data: data)
        }
    }
    
    func onInvitationRefused(_ invitee: ZegoUIKitUser, data: String?) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onInvitationRefused?(invitee, data: data)
        }
    }
    
    func onInvitationCanceled(_ inviter: ZegoUIKitUser, data: String?) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onInvitationCanceled?(inviter, data: data)
        }
    }
    
    func onInRoomMessageReceived(_ messageList: [ZegoInRoomMessage]) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onInRoomMessageReceived?(messageList)
        }
    }
    
    func onInRoomMessageSendingStateChanged(_ message: ZegoInRoomMessage) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onInRoomMessageSendingStateChanged?(message)
        }
    }
    
    func onSignalingPluginConnectionState(_ params: [String : AnyObject]) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onSignalingPluginConnectionState?(params)
        }
    }
    
    func onUsersInRoomAttributesUpdated(_ updateKeys: [String]?, oldAttributes: [ZegoUserInRoomAttributesInfo]?, attributes: [ZegoUserInRoomAttributesInfo]?, editor: ZegoUIKitUser?) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onUsersInRoomAttributesUpdated?(updateKeys, oldAttributes: oldAttributes, attributes: attributes, editor: editor)
        }
    }
    
    func onRoomMemberLeft(_ userIDList: [String]?, roomID: String) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onRoomMemberLeft?(userIDList, roomID: roomID)
        }
    }
    
    func onInRoomCommandReceived(_ fromUser: ZegoUIKitUser, command: String) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onInRoomCommandReceived?(fromUser, command: command)
        }
    }
    
    func onMeRemovedFromRoom() {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onMeRemovedFromRoom?()
        }
    }
    
    func onTurnOnYourCameraRequest(_ fromUser: ZegoUIKitUser) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onTurnOnYourCameraRequest?(fromUser)
        }
    }
    
    func onTurnOnYourMicrophoneRequest(_ fromUser: ZegoUIKitUser) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onTurnOnYourMicrophoneRequest?(fromUser)
        }
    }
    
    func onInRoomTextMessageReceived(_ messages: [ZegoSignalingInRoomTextMessage], roomID: String) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onInRoomTextMessageReceived?(messages, roomID: roomID)
        }
    }
    
    func onInRoomCommandMessageReceived(_ messages: [ZegoSignalingInRoomCommandMessage], roomID: String) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onInRoomCommandMessageReceived?(messages, roomID: roomID)
        }
    }
}
