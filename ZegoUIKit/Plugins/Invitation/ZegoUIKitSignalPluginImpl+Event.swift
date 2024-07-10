//
//  ZegoUIKitSignalPluginImpl+Event.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/12/19.
//

import Foundation
import ZegoPluginAdapter

extension ZegoUIKitSignalingPluginImpl: ZegoSignalingPluginEventHandler {
    
    
    public func onConnectionStateChanged(_ state: ZegoSignalingPluginConnectionState) {
        if state == .disconnected {
            self.loginOut()
        }
        for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
            let params: [String: AnyObject] = ["state": state as AnyObject]
            delegate.onSignalingPluginConnectionState?(params)
        }
    }
    
    public func onIMRoomStateChanged(_ state: Int, event: Int, roomID: String) {
      for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
          delegate.onIMRoomStateChanged?(state, event: event, roomID: roomID)
      }
    }
    public func onTokenWillExpire(in second: UInt32) {
        
    }
    
    public func onCallInvitationReceived(_ callID: String, inviterID: String, data: String) {
        let dataDic: Dictionary? = data.convertStringToDictionary()
        let type: Int = dataDic?["type"] as! Int
        let data: String? = dataDic?["data"] as? String
        var newData: [String : AnyObject] = data?.convertStringToDictionary() ?? [:]
        newData["invitationID"] = callID as AnyObject
      
        let inviter: [String : AnyObject] = [
            "id": inviterID as AnyObject,
            "name": dataDic?["inviter_name"] as AnyObject
        ]
        newData.updateValue(inviter as AnyObject, forKey: "inviter")
    
        let user: ZegoUIKitUser = ZegoUIKitUser.init(inviterID, dataDic?["inviter_name"] as? String ?? "")
        let inviteesList: [String] = getInvitees(newData["invitees"] as? [Dictionary<String, AnyObject>] ?? [])
        self.buildInvitationData(callID, inviter: user,invitees: inviteesList, type: type)
        for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
            delegate.onInvitationReceived?(user, type: type, data: newData.jsonString)
        }
    }
    
    func getInvitees(_ invitees: [Dictionary<String, AnyObject>]) -> [String] {
        var inviteesList: [String] = []
        for dict in invitees {
            if let userID = dict["user_id"] as? String {
                inviteesList.append(userID)
            }
        }
        return inviteesList
    }
    
    public func onCallInvitationCancelled(_ callID: String, inviterID: String, data: String) {
        self.invitationDB.removeValue(forKey: callID)
        let inviter: ZegoUIKitUser = ZegoUIKitUser.init(inviterID, "")
//        let dataDic: Dictionary? = data.convertStringToDictionary()
//        let data: String? = dataDic?["data"] as? String
        for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
            delegate.onInvitationCanceled?(inviter, data: data)
        }
    }
    
    public func onCallInvitationAccepted(_ callID: String, inviteeID: String, data: String) {
//        if inviteeID == ZegoUIKit.shared.localUserInfo?.userID {
        self.invitationDB.removeValue(forKey: callID)
        let invitee: ZegoUIKitUser = ZegoUIKitUser.init(inviteeID, "")
//        let dataDic: Dictionary? = data.convertStringToDictionary()
//        let newData: String? = dataDic?["data"] as? String
      
        // invitationID 抛到业务层：停止响铃场景需要
        let invitation: [String : AnyObject] = [
              "invitationID": callID as AnyObject,
        ]
        var dataString:String = data
        //FIXME: The web side accepts the invitation if data is "{}", the subsequent object transfer will be problematic
        if dataString == "{}" || dataString == "" {
          dataString = invitation.jsonString
        } else {
          var dataDic: Dictionary = data.convertStringToDictionary()!
          dataDic.updateValue(callID as AnyObject, forKey: "invitationID")
          dataString = dataDic.jsonString
        }
      
        for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
            delegate.onInvitationAccepted?(invitee, data: dataString)
        }
    }
    
    public func onCallInvitationRejected(_ callID: String, inviteeID: String, data: String) {
        let invitationData: InvitationData? = self.invitationDB[callID]
        if let invitationData = invitationData {
            let dataDic: Dictionary? = data.convertStringToDictionary()
            let user: ZegoUIKitUser = ZegoUIKitUser.init(inviteeID, dataDic?["inviter_name"] as? String ?? "")
            if let invitees = invitationData.invitees {
                for invitationUser in invitees {
                    if invitationUser.user?.userID == user.userID {
                        invitationUser.state = .refuse
                    }
                }
            }
            self.clearCall(callID)
            let invitee: ZegoUIKitUser = ZegoUIKitUser.init(inviteeID, "")
//            let newData: String? = dataDic?["data"] as? String
            for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
                delegate.onInvitationRefused?(invitee, data: data)
            }
        }
    }
    
    public func onCallInvitationTimeout(_ callID: String) {
        let invitationData: InvitationData? = self.invitationDB[callID]
        let userID:String = invitationData?.inviter?.userID ?? ""
        // 接受的时候invitationDB已经被删除了
//        else { return }
        var user = ZegoUIKitUser()
        if userID.count > 0 {
            user = ZegoUIKitUser.init(userID, "")
        }
        let data: String = ["invitationID": callID as AnyObject].jsonString
        for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
            delegate.onInvitationTimeout?(user, data: data)
        }
        self.invitationDB.removeValue(forKey: callID)
    }
    
    public func onCallInviteesAnsweredTimeout(_ callID: String, invitees: [String]) {
        var userList = [ZegoUIKitUser]()
        for userID in invitees {
            let user = ZegoUIKitUser.init(userID, "")
            userList.append(user)
        }
        let data: String = ["invitationID": callID as AnyObject].jsonString
        
        for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
            delegate.onInvitationResponseTimeout?(userList, data: data)
        }
        
        let invitationData: InvitationData? = self.invitationDB[callID]
        guard let invitationData = invitationData,
              let invitationInvitees = invitationData.invitees
        else { return }
        for user in invitationInvitees {
            for userID in invitees {
                if userID == user.user?.userID {
                    user.state = .timeout
                }
            }
        }
        self.clearCall(callID)
        
    }
    
    private func getIndexFromUsersInRoomAttributes(userID: String) -> Int? {
        let usersInRoomAttributes: [ZegoUserInRoomAttributesInfo] = self.getUsersInRoomAttributes() ?? []
        let  index: Int? = usersInRoomAttributes.firstIndex(where: { $0.userID == userID })
        return index
    }
    
    private func updateCoreUserAndNofityChanges(_ attributesMap: [String : [String : String]]) ->Bool {
        
        var infos: [AnyObject] = []
        var index = 0
        for userID in attributesMap.keys {
            let attribute: [String : String] = attributesMap[userID] ?? [:]
            var attributesInfo: [String : AnyObject] = [:]
            attributesInfo["userID"] = userID as AnyObject
            attributesInfo["attributes"] = attribute as AnyObject
            infos.append(attributesInfo as AnyObject)
            index = index + 1
        }
        
        var shouldNotifyChange: Bool = false
        if !infos.isEmpty {
            for info in infos {
                let attributes: [String : String]? = info["attributes"] as? [String : String]
                let userID: String? = info["userID"] as? String
                if let userID = userID, let attributes = attributes {
                    if ZegoUIKitCore.shared.userList.contains(where: { $0.userID == userID }) {
                        let oldAttributes: [String : String]? =  ZegoUIKit.shared.getUser(userID)?.inRoomAttributes
                        if let oldAttributes = oldAttributes, !oldAttributes.isEmpty {
                            
                            for (newKey, newValue) in attributes {
                                var isUpdate: Bool = false
                                for (oldKey, oldValue) in oldAttributes {
                                    if oldKey == newKey, newValue != oldValue {
                                        shouldNotifyChange = true
                                        isUpdate = true
                                        ZegoUIKitCore.shared.participantDic[userID]?.inRoomAttributes.updateValue(newValue, forKey: oldKey)
                                    }
                                }
                                
                                if !isUpdate {
                                    isUpdate = true
                                    shouldNotifyChange = true
                                    ZegoUIKitCore.shared.participantDic[userID]?.inRoomAttributes.updateValue(newValue, forKey: newKey)
                                }
                            }
                        } else {
                            shouldNotifyChange = true
                            ZegoUIKitCore.shared.participantDic[userID]?.inRoomAttributes = attributes
                        }
                    }
                }
                
            }
        }
        
        return shouldNotifyChange
        
    }
    
    public func onRoomPropertiesUpdated(_ properties: [[String : String]], actions: [UInt], roomID: String) {
        let oldRoomAttributes: [String : String] = self._roomAttributes
        var updateKeys: [String] = []
        
        var index = 0
        for propertie in properties {
            var isSet: Bool = true
            if actions.count > index {
                isSet = (actions[index] == 0)
            }
            for (key, value) in propertie {
                if !updateKeys.contains(key) {
                    updateKeys.append(key)
                }
                if isSet {
                    let oldValue: String = oldRoomAttributes[key] ?? ""
                    self._roomAttributes.updateValue(value, forKey: key)
                    for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
                        delegate.onSignalPluginRoomPropertyUpdated?(key, oldValue: oldValue, newValue: value)
                    }
                } else {
                    let oldValue: String = oldRoomAttributes[key] ?? ""
                    self._roomAttributes.removeValue(forKey: key)
                    for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
                        delegate.onSignalPluginRoomPropertyUpdated?(key, oldValue: oldValue, newValue: "")
                    }
                }
            }
            index = index + 1
        }
        
    }
    
    public func onUsersInRoomAttributesUpdated(_ attributesMap: [String : [String : String]], editor: String, roomID: String) {
        var oldUsersInRoomAttributes = self._usersInRoomAttributes
        var editUser: ZegoUIKitUser? = ZegoUIKit.shared.getUser(editor)
        if editUser?.userID == ZegoUIKit.shared.localUserInfo?.userID {
            oldUsersInRoomAttributes = self._oldUsersInRoomAttributes
        }
        var updateKeys: [String] = []
        for userID in attributesMap.keys {
            let usersInRoomIndex: Int? = self.getIndexFromUsersInRoomAttributes(userID: userID)
            let attribute: [String : String] = attributesMap[userID] ?? [:]
            for (key, value) in attribute {
                if(!updateKeys.contains(key)) {
                    updateKeys.append(key)
                }
                if let usersInRoomIndex = usersInRoomIndex {
                    self._usersInRoomAttributes[usersInRoomIndex].attributes.updateValue(value, forKey: key)
                } else {
                    let userInRoomInfo: ZegoUserInRoomAttributesInfo = ZegoUserInRoomAttributesInfo()
                    userInRoomInfo.userID = userID
                    userInRoomInfo.attributes.updateValue(value, forKey: key)
                    self._usersInRoomAttributes.append(userInRoomInfo)
                }
            }
        }
        
        //update core userInfo
        let isNotifyChange = self.updateCoreUserAndNofityChanges(attributesMap)
        
        editUser = ZegoUIKit.shared.getUser(editor)
        
        for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
            delegate.onUsersInRoomAttributesUpdated?(updateKeys, oldAttributes: oldUsersInRoomAttributes, attributes: self._usersInRoomAttributes, editor: editUser)
            if isNotifyChange {
                delegate.onUserCountOrPropertyChanged?(ZegoUIKitCore.shared.getAllUsers())
            }
        }
    }
    
    public func onRoomPropertiesUpdated(_ setProperties: [[String : String]], deleteProperties: [[String : String]], roomID: String) {
        let oldRoomAttributes: [String : String] = self._roomAttributes
        var updateKeys: [String] = []
        var oldProperties : [String : String] = [:]
        var newProperties : [String : String] = [:]
      
        for propertie in setProperties {
            for (key, value) in propertie {
                if !updateKeys.contains(key) {
                    updateKeys.append(key)
                }
                let oldValue: String = oldRoomAttributes[key] ?? ""
                oldProperties[key] = oldValue
                newProperties[key] = value
                self._roomAttributes.updateValue(value, forKey: key)
                for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
                    delegate.onSignalPluginRoomPropertyUpdated?(key, oldValue: oldValue, newValue: value)
                }
            }
            
        }
        
        for propertie in deleteProperties {
            for (key, _) in propertie {
                if !updateKeys.contains(key) {
                    updateKeys.append(key)
                }
                let oldValue: String = oldRoomAttributes[key] ?? ""
                oldProperties[key] = oldValue
                newProperties[key] = ""
                self._roomAttributes.removeValue(forKey: key)
                for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
                    delegate.onSignalPluginRoomPropertyUpdated?(key, oldValue: oldValue, newValue: "")
                }
            }
        }
        
        for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
            delegate.onSignalPluginRoomPropertyFullUpdated?(updateKeys, oldProperties: oldProperties, properties: newProperties)
        }
    }
    
    
    public func onRoomMemberLeft(_ userIDList: [String], roomID: String) {
        let oldusersInRoomAttributes = self._usersInRoomAttributes
        for userID in userIDList {
            self._usersInRoomAttributes.removeAll(where: { el in
                el.userID == userID
            })
        }
        for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
            delegate.onUsersInRoomAttributesUpdated?(nil, oldAttributes: oldusersInRoomAttributes, attributes: self._usersInRoomAttributes, editor: nil)
            delegate.onRoomMemberLeft?(userIDList, roomID: roomID)
        }
    }
    
    public func onRoomMemberJoined(_ userIDList: [String], roomID: String) {
        
        
    }
    
    public func onInRoomTextMessageReceived(_ messages: [ZegoSignalingInRoomTextMessage], roomID: String) {
        for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
            delegate.onInRoomTextMessageReceived?(messages, roomID: roomID)
        }

    }
    
    public func onInRoomCommandMessageReceived(_ messages: [ZegoSignalingInRoomCommandMessage], roomID: String) {
        for delegate in ZegoUIKitCore.shared.uikitEventDelegates.allObjects {
            delegate.onInRoomCommandMessageReceived?(messages, roomID: roomID)
        }
    }
    
   
}
