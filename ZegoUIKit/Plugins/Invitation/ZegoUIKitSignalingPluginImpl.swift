//
//  ZegoUIKitInvitationService.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/10/12.
//

import UIKit
import ZegoPluginAdapter


class SignalingPluginRoomInfo: NSObject {
    var roomID: String = ""
    var roomName: String = ""
}

public typealias PluginCallBack = (_ data: Dictionary<String, AnyObject>?) -> ()

public class ZegoUIKitSignalingPluginImpl: NSObject {
    
    public static let shared = ZegoUIKitSignalingPluginImpl()
    
    var signalingRoomInfo: SignalingPluginRoomInfo = SignalingPluginRoomInfo()
    
    var _usersInRoomAttributes: [ZegoUserInRoomAttributesInfo] = []
    var _oldUsersInRoomAttributes: [ZegoUserInRoomAttributesInfo] = []
    var _roomAttributes: [String : String] = [:]
    
    var invitationDB: [String : InvitationData] = [:]
    
    var queryUserInRoomAttributeCallBack: PluginCallBack?
    
    override init() {
        super.init()
    }
    
    public func installPlugins(_ plugins: [ZegoPluginProtocol]) {
        ZegoPluginAdapter.installPlugins(plugins)
    }
    
    public func getPlugin(_ type: ZegoPluginType) -> ZegoPluginProtocol? {
        switch type {
        case .signaling:
            return ZegoPluginAdapter.signalingPlugin
        @unknown default:
            break
        }
        return nil
    }
    
    public func initWithAppID(appID: UInt32, appSign: String) {
        ZegoPluginAdapter.signalingPlugin?.registerPluginEventHandler(self)
        ZegoPluginAdapter.signalingPlugin?.initWith(appID: appID, appSign: appSign)
    }
    
    public func uninit() {
        
    }
    
    public func login(_ userID: String, userName: String, callback: PluginCallBack?) {
        ZegoUIKitCore.shared.login(userID, userName: userName)
        ZegoPluginAdapter.signalingPlugin?.connectUser(userID: userID, userName: userName, token: nil, callback: { errorCode, errorMessage in
            guard let callback = callback else { return }
            let callbackParams: [String : AnyObject] = [
                "code": errorCode as AnyObject,
                "message": errorMessage as AnyObject,
            ]
            callback(callbackParams)
        })
    }
    
    public func loginOut() {
        ZegoPluginAdapter.signalingPlugin?.disconnectUser()
    }
    

    public func sendInvitation(_ invitees: [String], timeout: UInt32, type: Int, data: String?, notificationConfig: ZegoSignalingPluginNotificationConfig?, callback: PluginCallBack?) {
        let dataDict: [String : AnyObject] = [
            "inviter_name": ZegoUIKit.shared.localUserInfo?.userName as AnyObject,
            "inviter_id": ZegoUIKit.shared.localUserInfo?.userID as AnyObject,
            "invitees": invitees as AnyObject,
            "timeout": timeout as AnyObject,
            "type" : type as AnyObject,
            "data" : data as AnyObject
        ]
        ZegoPluginAdapter.signalingPlugin?.sendInvitation(with: invitees, timeout: timeout, data: dataDict.jsonString,notificationConfig: notificationConfig, callback: { errorCode, errorMessage, invitationID, errorInvitees in
            if errorCode == 0 {
                if let inviter = ZegoUIKit.shared.localUserInfo {
                    self.buildInvitationData(invitationID, inviter: inviter,invitees: invitees, type: type)
                    self.updateInvitationData(invitationID, invitees: errorInvitees, state: .error)
                }
            }
            guard let callback = callback else { return }
            let callbackParams: [String : AnyObject] = ["code": errorCode as AnyObject, "message": errorMessage as AnyObject, "callID": invitationID as AnyObject, "errorInvitees": errorInvitees as AnyObject]
            callback(callbackParams)
            
        })
    }
    
    func buildInvitationData(_ invitationID: String, inviter: ZegoUIKitUser, invitees: [String], type: Int) {
        var newInvitees: [ZegoInvitationUser] = []
        for userID in invitees {
            let user = ZegoUIKitUser.init(userID, "")
            let invitationUser = ZegoInvitationUser.init(user, state: .waiting)
            newInvitees.append(invitationUser)
        }
        let invitationData: InvitationData = InvitationData.init(invitationID, inviter: inviter, invitees: newInvitees, type: type)
        self.invitationDB[invitationID] = invitationData
    }
    
    func updateInvitationData(_ invitationID: String, invitees: [String], state: InvitationState) {
        let invitationData: InvitationData? = self.invitationDB[invitationID]
        guard let invitationData = invitationData,
              let invitationInvitees = invitationData.invitees
        else {
            return
        }
        for user in invitationInvitees {
            for userID in invitees {
                if user.user?.userID == userID {
                    user.state = state
                }
            }
        }
    }
    
    func findCallID(_ invitees: [String]) -> [String] {
        var cancelCallList: [String] = []
        for userID in invitees {
            for invitationData in self.invitationDB.values {
                let callID: String? = invitationData.inviteesDict[userID]
                if let callID = callID {
                    cancelCallList.append(callID)
                }
            }
        }
        return cancelCallList
    }
    
    func findCallIDWithInvitation(_ inviterID: String) -> InvitationData? {
        var targetInvitationData: InvitationData?
        for invitationData in self.invitationDB.values {
            if invitationData.inviter?.userID == inviterID {
                targetInvitationData = invitationData
                break
            }
        }
        return targetInvitationData
    }
    
    func clearCall(_ callID: String) {
        guard let invitationData = self.invitationDB[callID],
        let invitationInvitees = invitationData.invitees
        else { return }
        var needClear: Bool = true
        for user in invitationInvitees {
            if user.state == .waiting {
                needClear = false
                break
            }
        }
        if needClear {
            self.invitationDB.removeValue(forKey: callID)
        }
    }
    
    public func cancelInvitation(_ invitees: [String], data: String?, callback: PluginCallBack?) {
        let cancelList: [String] = self.findCallID(invitees)
        for callID in cancelList {
            ZegoPluginAdapter.signalingPlugin?.cancelInvitation(with: invitees, invitationID: callID, data: data, callback: { errorCode, errorMessage, errorInvitees in
                if errorCode == 0 {
                    self.invitationDB.removeValue(forKey: callID)
                }
                guard let callback = callback else { return }
                callback(["code": errorCode as AnyObject, "message": errorMessage as AnyObject])
            })
        }
    }
    
    public func refuseInvitation(_ inviterID: String, data: String?) {
//        let dataDict: [String : AnyObject] = [
//            "inviterID": inviterID as AnyObject,
//            "data" : data as AnyObject
//        ]
        var invitationID: String? = data?.convertStringToDictionary()?["invitationID"] as? String
        if invitationID == nil {
            invitationID = self.findCallIDWithInvitation(inviterID)?.invitationID
        }
        guard let invitationID = invitationID else { return }
        ZegoPluginAdapter.signalingPlugin?.refuseInvitation(with: invitationID, data: data, callback: { errorCode, errorMessage in
            if errorCode == 0 {
                self.invitationDB.removeValue(forKey: invitationID)
            }
        })
    }
    
    public func acceptInvitation(_ inviterID: String, invitationID: String? = nil, data: String?, callback: PluginCallBack?) {
//        let dataDict: [String : AnyObject] = [
//            "inviterID": inviterID as AnyObject,
//            "data" : data as AnyObject
//        ]
        var invitationID: String? = invitationID
        if invitationID == nil {
            invitationID = self.findCallIDWithInvitation(inviterID)?.invitationID
        }
        guard let invitationID = invitationID else { return }
        ZegoPluginAdapter.signalingPlugin?.acceptInvitation(with: invitationID, data: data, callback: { errorCode, errorMessage in
            if errorCode == 0 {
                self.invitationDB.removeValue(forKey: invitationID)
            }
            guard let callback = callback else { return }
            callback(["code": errorCode as AnyObject, "message": errorMessage as AnyObject])
        })
    }
    
    //------ZegoUserInRoomAttributes
    public func joinRoom(roomID: String, callback: PluginCallBack?) {
        if !signalingRoomInfo.roomID.isEmpty {
            print("[zim] room has login.")
            guard let callback = callback else {
                return
            }
            callback(["code": -1 as AnyObject,
                      "message": "room has login" as AnyObject])
            return
        }
        
        signalingRoomInfo.roomID = roomID
        signalingRoomInfo.roomName = roomID
        ZegoPluginAdapter.signalingPlugin?.joinRoom(with: roomID, roomName: roomID, callBack: { errorCode, errorMessage in
            if errorCode == 0 {
                self.queryRoomProperties { data in
                    guard let data = data else { return }
                    let code: Int = data["code"] as? Int ?? 0
                    if code == 0 {
                        self._roomAttributes = data["roomAttributes"] as! [String : String]
                    }
                }
            }
            
            guard let callback = callback else {
                return
            }
            callback(["code": errorCode as AnyObject,
                      "message": errorMessage as AnyObject])
        })
    }
    
    public func leaveRoom(_ callBack: PluginCallBack?) {
        if signalingRoomInfo.roomID.isEmpty  {
            print("[zim] room has leave.")
            guard let callBack = callBack else {
                return
            }
            callBack(["code": -1 as AnyObject,
                      "message": "room has leave" as AnyObject])
            return
        }
        ZegoPluginAdapter.signalingPlugin?.leaveRoom(by: signalingRoomInfo.roomID, callBack: { errorCode, errorMessage in
            if errorCode == 0 {
                self._roomAttributes.removeAll()
                self._usersInRoomAttributes.removeAll()
            }
            
            self.signalingRoomInfo.roomID = ""
            self.signalingRoomInfo.roomName = ""
            
            guard let callBack = callBack else {
                return
            }
            callBack(["code": errorCode as AnyObject,
                      "message": errorMessage as AnyObject])
        })
    }
  
    public func clearRoomInfo (){
      self.signalingRoomInfo.roomID = ""
      self.signalingRoomInfo.roomName = ""
    }
  
    func getUsersInRoomAttributes() -> [ZegoUserInRoomAttributesInfo]? {
        return self._usersInRoomAttributes
    }
    
    public func getRoomProperties() -> [String: String]? {
        return self._roomAttributes
    }
    
    public func setUsersInRoomAttributes(_ key: String, value: String, userIDs: [String], roomID: String, callBack: PluginCallBack?) {
        ZegoPluginAdapter.signalingPlugin?.setUsersInRoomAttributes(with: [key : value], userIDs: userIDs, roomID: roomID, callback: { errorCode, errorMessage, errorUserList, attributesMap, errorKeysMap in
            if errorCode == 0 {
                self._oldUsersInRoomAttributes = self._usersInRoomAttributes
                
                for key in attributesMap.keys {
                    let attribute: ZegoUserInRoomAttributesInfo = ZegoUserInRoomAttributesInfo()
                    attribute.userID = key
                    attribute.attributes = attributesMap[key] ?? [:]
                    
                    if value.isEmpty {
                        self.removeUserInRoomAttributs(attribute, key: key)
                    } else {
                        self.updateUserInRoomAttributs(attribute)
                    }
                    
                    self.updateUserAttributes(key, attribute: attributesMap[key] ?? [:])
                    
                }
            }
            
            guard let callBack = callBack else { return }
            callBack(
                ["code": errorCode as AnyObject,
                 "message": errorMessage as AnyObject
                ])
        })
    }
    
    private func updateUserAttributes(_ userID: String, attribute: [String : String]) {
        let participant: ZegoParticipant? = ZegoUIKitCore.shared.participantDic[userID]
        guard let participant = participant else { return }
        participant.inRoomAttributes = attribute
        
        for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
            delegate.onUserCountOrPropertyChanged?([participant.toUserInfo()])
        }
    }
    
    public func queryUsersInRoomAttributes(_ config: ZegoUsersInRoomAttributesQueryConfig, callBack: PluginCallBack?) {
        self.queryUserInRoomAttributeCallBack = callBack
        if signalingRoomInfo.roomID.isEmpty {
            print("[zim] roomID is empty")
            return
        }
        let tempAttributes: [ZegoUserInRoomAttributesInfo] = []
        let keys: [String] = []
        self.queryUsersInRoomAttributes(signalingRoomInfo.roomID, newNextFlag: config.nextFlag, count: UInt32(config.count), tempAttributes: tempAttributes, keys: keys)
    }
    
    private func queryUsersInRoomAttributes(_ roomID: String, newNextFlag: String, count: UInt32, tempAttributes: [ZegoUserInRoomAttributesInfo], keys:[String]) {
        ZegoPluginAdapter.signalingPlugin?.queryUsersInRoomAttributes(by: roomID, count: count, nextFlag: newNextFlag, callback: { errorCode, errorMessage, nextFlag, attributesMap in
            
            var newTempAttributes: [ZegoUserInRoomAttributesInfo] = tempAttributes
            var newKeys: [String] = keys

            if errorCode == 0 {
                for key in attributesMap.keys {
                    let attribute: ZegoUserInRoomAttributesInfo = ZegoUserInRoomAttributesInfo()
                    attribute.userID = key
                    attribute.attributes = attributesMap[key] ?? [:]
                    newTempAttributes.append(attribute)
                    newKeys.append(key)
                    self.updateUserAttributes(key, attribute: attributesMap[key] ?? [:])
                }
                
                if nextFlag == "" || nextFlag.isEmpty {
                    let callbackParams: [String : AnyObject] = [
                        "code" : errorCode as AnyObject,
                        "message" : errorMessage as AnyObject,
                        "nextFlag" : nextFlag as AnyObject,
                        "infos" : newTempAttributes as AnyObject
                    ]
                    
                    for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
                        delegate.onUsersInRoomAttributesUpdated?(newKeys, oldAttributes: self._oldUsersInRoomAttributes, attributes: newTempAttributes, editor: nil)
                    }
                    
                    guard let queryUserInRoomAttributeCallBack = self.queryUserInRoomAttributeCallBack else { return }
                    queryUserInRoomAttributeCallBack(callbackParams)
                } else {
                    self.queryUsersInRoomAttributes(roomID, newNextFlag: nextFlag, count: count, tempAttributes: newTempAttributes, keys: newKeys)
                }
            }
        })
    }
    
    public func updateRoomProperty(_ key: String, value: String ,isDeleteAfterOwnerLeft: Bool = false, isForce: Bool = false, isUpdateOwner: Bool = false, callback:PluginCallBack?) {
        updateRoomProperty([key: value], 
                           isDeleteAfterOwnerLeft: isDeleteAfterOwnerLeft,
                           isForce: isForce,
                           isUpdateOwner: isUpdateOwner,
                           callback: callback)
    }
    
    public func updateRoomProperty(_ attributes: [String : String] ,isDeleteAfterOwnerLeft: Bool = false, isForce: Bool = false, isUpdateOwner: Bool = false, callback:PluginCallBack?) {
        if signalingRoomInfo.roomID.isEmpty {
            print("[zim] roomID is empty")
            return
        }
        ZegoPluginAdapter.signalingPlugin?.updateRoomProperty(attributes, roomID: signalingRoomInfo.roomID, isForce: isForce, isDeleteAfterOwnerLeft: isDeleteAfterOwnerLeft, isUpdateOwner: isUpdateOwner, callback: { errorCode, errorMessage, errorKeys in
            if errorCode == 0 {
                attributes.forEach { (key, value) in
                    if !errorKeys.contains(key) {
                        self._roomAttributes.updateValue(value, forKey: key)
                    }
                }
            }
            guard let callback = callback else { return }
            callback(
                ["code" : errorCode as AnyObject,
                 "message" : errorMessage as AnyObject
                ]
            )
        })
    }
    
    public func deleteRoomProperties(_ keys:[String], isForce: Bool = false, callBack: PluginCallBack?) {
        if signalingRoomInfo.roomID.isEmpty {
            print("[zim] roomID is empty")
            return
        }
        
        ZegoPluginAdapter.signalingPlugin?.deleteRoomProperties(by: keys, roomID: signalingRoomInfo.roomID, isForce: isForce, callback: { errorCode, errorMessage, errorKeys in
            if errorCode == 0 {
                var temKeys: [String] = keys
                if !errorKeys.isEmpty {
                    temKeys.removeAll { el in
                        errorKeys.contains { k in
                            el == k
                        }
                    }
                }
                for key in keys {
                    self._roomAttributes.removeValue(forKey: key)
                }
            }
            guard let callBack = callBack else { return }
            callBack(
                ["code" : errorCode as AnyObject,
                 "message" : errorMessage as AnyObject,
                 "errorKeys" : errorKeys as AnyObject
                ]
            )
        })
    }
    
    public func beginRoomPropertiesBatchOperation(_ isForce: Bool = false, isDeleteAfterOwnerLeft: Bool = false,isUpdateOwner: Bool = false) {
        if signalingRoomInfo.roomID.isEmpty {
            print("[zim] roomID is empty")
            return
        }
        ZegoPluginAdapter.signalingPlugin?.beginRoomPropertiesBatchOperation(with: signalingRoomInfo.roomID, isDeleteAfterOwnerLeft: isDeleteAfterOwnerLeft, isForce: isForce, isUpdateOwner: isUpdateOwner)
    }
    
    public func endRoomPropertiesBatchOperation(_ callBack: PluginCallBack?) {
        if signalingRoomInfo.roomID.isEmpty {
            print("[zim] roomID is empty")
            return
        }
        ZegoPluginAdapter.signalingPlugin?.endRoomPropertiesBatchOperation(with: signalingRoomInfo.roomID, callback: { errorCode, errorMessage in
            guard let callBack = callBack else { return }
            callBack(
                [
                "code": errorCode as AnyObject,
                "message": errorMessage as AnyObject
                ])
        })
    }
    
    public func queryRoomProperties(_ callBack: PluginCallBack?) {
        if signalingRoomInfo.roomID.isEmpty {
            print("[zim] roomID is empty")
            return
        }
        ZegoPluginAdapter.signalingPlugin?.queryRoomProperties(by: signalingRoomInfo.roomID, callback: { errorCode, errorMessage, properties in
            guard let callBack = callBack else { return }
            callBack(
                ["code": errorCode as AnyObject,
                 "message": errorMessage as AnyObject,
                 "roomAttributes": properties as AnyObject
                ])
        })
    }
    
    public func enableNotifyWhenAppRunningInBackgroundOrQuit(_ enable: Bool,
                                                             isSandboxEnvironment: Bool,
                                                             certificateIndex: ZegoSignalingPluginMultiCertificate = .firstCertificate) {
        ZegoPluginAdapter.signalingPlugin?.enableNotifyWhenAppRunningInBackgroundOrQuit(enable, isSandboxEnvironment: isSandboxEnvironment, certificateIndex: certificateIndex)
    }
    
    public func setRemoteNotificationsDeviceToken(_ deviceToken: Data) {
        ZegoPluginAdapter.signalingPlugin?.setRemoteNotificationsDeviceToken(deviceToken)
    }
    
    public func sendRoomMessage(_ text: String, callback: PluginCallBack?) {
        if signalingRoomInfo.roomID.isEmpty {
            print("[zim] roomID is empty")
            return
        }
        ZegoPluginAdapter.signalingPlugin?.sendRoomMessage(text, roomID: signalingRoomInfo.roomID, callback: { errorCode, errorMessage in
            guard let callback = callback else { return }
            callback(["code": errorCode as AnyObject,
                      "message": errorMessage as AnyObject,
                     ])
        })
    }
    
    public func sendRoomCommand(_ command: String, callback: PluginCallBack?) {
        if signalingRoomInfo.roomID.isEmpty {
            print("[zim] roomID is empty")
            return
        }
        ZegoPluginAdapter.signalingPlugin?.sendRoomCommand(command, roomID: signalingRoomInfo.roomID, callback: { errorCode, errorMessage in
            guard let callback = callback else { return }
            callback(["code": errorCode as AnyObject,
                      "message": errorMessage as AnyObject,
                     ])
        })
    }
    
    
    private func removeUserInRoomAttributs(_ attribute: ZegoUserInRoomAttributesInfo, key: String) {
        
        if !self._usersInRoomAttributes.isEmpty {
            for attri in self._usersInRoomAttributes {
                if attri.userID == attribute.userID {
                    attri.attributes.removeValue(forKey: key)
                }
            }
        }
    }
    
    private func updateUserInRoomAttributs(_ attribute: ZegoUserInRoomAttributesInfo) {
        var isExist: Bool = false
        for attri in self._usersInRoomAttributes {
            if attri.userID == attribute.userID {
                attri.attributes = attribute.attributes
                isExist = true
            }
        }
        
        if !isExist {
            self._usersInRoomAttributes.append(attribute)
        }
    }
}

class ZegoUIKitInvitationService_Help: NSObject {
    

}

public class ZegoUserInRoomAttributesInfo: NSObject {
    public var userID: String?
    public var attributes: [String : String] = [:]
}

public class ZegoUsersInRoomAttributesQueryConfig: NSObject {
    public var nextFlag: String = ""
    public var count: Int = 100
}
