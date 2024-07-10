//
//  ZegoUIKitCore+Room.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2023/3/23.
//

import Foundation
import ZegoExpressEngine

extension ZegoUIKitCore: ZegoEventHandler, ZegoCustomVideoRenderHandler {
    
    func onRoomUserUpdate(_ updateType: ZegoUpdateType, userList: [ZegoUser], roomID: String) {
        var users = [ZegoUIKitUser]()
        for user in userList {
            if updateType == .add {
                let participant: ZegoParticipant = self.participantDic[user.userID] ?? ZegoParticipant.init(userID: user.userID, name: user.userName)
                participant.name = user.userName
                participantDic[user.userID] = participant
                users.append(participant.toUserInfo())
                self.roomMemberCount = self.roomMemberCount + self.userList.count
                if self.roomMemberCount >= 500 {
                    isLargeRoom = true
                }
            } else {
                let participant: ZegoParticipant? = self.participantDic[user.userID] ?? nil
                if let participant = participant {
                    self.stopPlayStream(participant.streamID)
                    users.append(participant.toUserInfo())
                }
                participantDic.removeValue(forKey: user.userID)
                self.roomMemberCount = self.roomMemberCount - self.userList.count
            }
        }
        
        for delegate in self.uikitEventDelegates.allObjects {
            if updateType == .add {
                delegate.onRemoteUserJoin?(users)
            } else {
                delegate.onRemoteUserLeave?(users)
                if ZegoUIKit.shared.userList.count == 1 {
                    delegate.onOnlySelfInRoom?(users)
                }
            }
            delegate.onUserCountOrPropertyChanged?(self.userList)
        }
    }
    
    func onRoomStreamUpdate(_ updateType: ZegoUpdateType, streamList: [ZegoStream], extendedData: [AnyHashable : Any]?, roomID: String) {
        var mainStreamList: [ZegoStream] = []
        var auxStreamList: [ZegoStream] = []
        for stream in streamList {
            if stream.streamID.contains("main") {
                mainStreamList.append(stream)
                onRoomMainStreamUpdate(updateType, streamList: mainStreamList, extendedData: extendedData, roomID: roomID);
            } else {
                auxStreamList.append(stream)
                onRoomAuxStreamUpdate(updateType, streamList: auxStreamList, extendedData: extendedData, roomID: roomID);
            }
        }
        if updateType == .add {
            onRoomStreamExtraInfoUpdate(streamList, roomID: roomID)
        }
    }
    
    func onRoomMainStreamUpdate(_ updateType: ZegoUpdateType, streamList: [ZegoStream], extendedData: [AnyHashable : Any]?, roomID: String) {
        var userList = [ZegoUIKitUser]()
        for stream in streamList {
            if updateType == .add {
                self.streamDic[stream.streamID] = stream.user.userID
                var participant: ZegoParticipant? = self.participantDic[stream.user.userID]
                if let participant = participant {
                    participant.streamID = stream.streamID
                    participant.name = stream.user.userName
                    userList.append(participant.toUserInfo())
                } else {
                    participant = ZegoParticipant.init(userID: stream.user.userID, name: stream.user.userName)
                    participant?.streamID = stream.streamID
                    userList.append(participant!.toUserInfo())
                }
                self.playStream(streamID: stream.streamID, videoModel: participant?.videoDisPlayMode ?? .aspectFill)
                self.participantDic[stream.user.userID] = participant
            } else {
                self.stopPlayStream(stream.streamID)
                self.streamDic.removeValue(forKey: stream.streamID)
                let participant = self.participantDic[stream.user.userID]
                participant?.camera = false
                participant?.mic = false
                participant?.streamID = ""
                if let participant = participant {
                    self.participantDic[stream.user.userID] = participant
                    userList.append(participant.toUserInfo())
                    for delegate in self.uikitEventDelegates.allObjects {
                        delegate.onCameraOn?(participant.toUserInfo(), isOn: false)
                        delegate.onMicrophoneOn?(participant.toUserInfo(), isOn: false)
                    }
                }
            }
        }
        
        for delegate in self.uikitEventDelegates.allObjects {
            if updateType == .add {
                delegate.onAudioVideoAvailable?(userList)
            } else {
                delegate.onAudioVideoUnavailable?(userList)
            }
        }
    }
    
    func onRoomAuxStreamUpdate(_ updateType: ZegoUpdateType, streamList: [ZegoStream], extendedData: [AnyHashable : Any]?, roomID: String) {
        var userList = [ZegoUIKitUser]()
        for stream in streamList {
            if updateType == .add {
                self.auxStreamDic[stream.streamID] = stream.user.userID
                if let participant = self.participantDic[stream.user.userID] {
                    participant.auxStreamID = stream.streamID
                    participant.name = stream.user.userName
                    userList.append(participant.toUserInfo())
                    self.participantDic[stream.user.userID] = participant
                    self.playStream(streamID: stream.streamID, videoModel: participant.screenShareDisplayMode)
                } else {
                    let participant = ZegoParticipant(userID: stream.user.userID, name: stream.user.userName)
                    participant.auxStreamID = stream.streamID
                    userList.append(participant.toUserInfo())
                    self.participantDic[stream.user.userID] = participant
                    self.playStream(streamID: stream.streamID, videoModel: participant.screenShareDisplayMode)
                }
            } else {
                self.stopPlayStream(stream.streamID)
                self.streamDic.removeValue(forKey: stream.streamID)
                if let participant = self.participantDic[stream.user.userID] {
                    participant.streamID = ""
                    userList.append(participant.toUserInfo())
                    self.participantDic[stream.user.userID] = participant
                }
            }
        }
        for delegate in self.uikitEventDelegates.allObjects {
            if updateType == .add {
                delegate.onScreenSharingAvailable?(userList)
            } else {
                delegate.onScreenSharingUnavailable?(userList)
            }
        }
    }
    
    func onRoomStreamExtraInfoUpdate(_ streamList: [ZegoStream], roomID: String) {
        for stream in streamList {
          if stream.streamID.hasSuffix("_screensharing") {
            // 屏幕共享流不做处理
          } else {
            let extraInfo = stream.extraInfo.convertStringToDictionary()
            if let extraInfo = extraInfo {
                let participant: ZegoParticipant? = participantDic[stream.user.userID]
                if extraInfo.keys.contains("isCameraOn") {
                    participant?.camera = extraInfo["isCameraOn"] as! Bool
                    for delegate in self.uikitEventDelegates.allObjects {
                        delegate.onCameraOn?(ZegoUIKitUser.init(stream.user.userID, stream.user.userName), isOn: extraInfo["isCameraOn"] as! Bool)
                    }
                }
                if extraInfo.keys.contains("isMicrophoneOn") {
                    participant?.mic = extraInfo["isMicrophoneOn"] as! Bool
                    for delegate in self.uikitEventDelegates.allObjects {
                        delegate.onMicrophoneOn?(ZegoUIKitUser.init(stream.user.userID, stream.user.userName), isOn: extraInfo["isMicrophoneOn"] as! Bool)
                    }
                }
                self.participantDic[stream.user.userID] = participant
            }
          }
        }
    }
    
    func onRoomStateChanged(_ reason: ZegoRoomStateChangedReason, errorCode: Int32, extendedData: [AnyHashable : Any], roomID: String) {
        if reason == .kickOut {
            for delegate in self.uikitEventDelegates.allObjects {
                delegate.onMeRemovedFromRoom?()
            }
        }
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onRoomStateChanged?(ZegoUIKitRoomStateChangedReason(rawValue: reason.rawValue) ?? .logining, errorCode: errorCode, extendedData: extendedData, roomID: roomID)
        }
    }
    
    func onRemoteCameraStateUpdate(_ state: ZegoRemoteDeviceState, streamID: String) {
        for delegate in self.uikitEventDelegates.allObjects {
            if let user = participantDic[streamDic[streamID] ?? ""]?.toUserInfo() {
                guard let userID = user.userID else { return }
                var isStateChange: Bool = false
                let participant: ZegoParticipant? = participantDic[userID]
                guard let participant = participant else { return }
                if state == .open {
                    if !participant.camera {
                        isStateChange = true
                        participant.camera = true
                        delegate.onCameraOn?(user, isOn: true)
                    }
                } else {
                    if participant.camera {
                        isStateChange = true
                        participant.camera = false
                        delegate.onCameraOn?(user, isOn: false)
                    }
                }
                self.participantDic[userID] = participant
                if isStateChange {
//                    self.updateUserListAttribute(participant)
                    delegate.onUserCountOrPropertyChanged?(self.userList)
                }
            }
        }
    }
    
    func onRemoteMicStateUpdate(_ state: ZegoRemoteDeviceState, streamID: String) {
        for delegate in self.uikitEventDelegates.allObjects {
            if let user = participantDic[streamDic[streamID] ?? ""]?.toUserInfo() {
                guard let userID = user.userID else { return }
                var isStateChange: Bool = false
                let participant: ZegoParticipant? = participantDic[userID]
                guard let participant = participant else { return }
                if state == .open {
                    if !participant.mic {
                        isStateChange = true
                        participant.mic = true
                        delegate.onMicrophoneOn?(user, isOn: true)
                    }
                } else {
                    if participant.mic {
                        isStateChange = true
                        participant.mic = false
                        delegate.onMicrophoneOn?(user, isOn: false)
                    }
                }
                self.participantDic[userID] = participant
                if isStateChange {
//                    self.updateUserListAttribute(participant)
                    delegate.onUserCountOrPropertyChanged?(self.userList)
                }
            }
        }
    }
    
    func onAudioRouteChange(_ audioRoute: ZegoAudioRoute) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onAudioOutputDeviceChanged?(ZegoUIKitAudioOutputDevice(rawValue: audioRoute.rawValue) ?? .speaker)
        }
    }
    
    func onRemoteSoundLevelUpdate(_ soundLevels: [String : NSNumber]) {
        for key in soundLevels.keys {
            guard let userID = self.streamDic[key] else { return }
            let user = self.participantDic[userID]?.toUserInfo()
            let value: Double = (soundLevels[key] ?? 0).doubleValue
            guard let user = user else { return }
            for delegate in self.uikitEventDelegates.allObjects {
                delegate.onSoundLevelUpdate?(user, level: value)
            }
        }
    }
    
    func onCapturedSoundLevelUpdate(_ soundLevel: NSNumber) {
        let user = self.localParticipant?.toUserInfo()
        guard let user = user else { return }
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onSoundLevelUpdate?(user, level: soundLevel.doubleValue)
        }
    }
    
    func onRoomExtraInfoUpdate(_ roomExtraInfoList: [ZegoRoomExtraInfo], roomID: String) {
        let oldProperties = self.getRoomProperties()
        var updateKeys: [String] = []
        for info in roomExtraInfoList {
            if info.key == "extra_info" {
                guard let properties: [String: AnyObject] = info.value.convertStringToDictionary() else { continue }
                for key in properties.keys {
                    let oldValue = oldProperties[key] ?? ""
                    if self.roomProperties.keys.contains(key) && self.roomProperties[key] as? String == properties[key] as? String {
                        continue
                    }
                    updateKeys.append(key)
                    let value: String? = properties[key] as? String
                    if let value = value {
                        self.roomProperties[key] = value as AnyObject
                        for delegate in self.uikitEventDelegates.allObjects {
                            delegate.onRoomPropertyUpdated?(key, oldValue: oldValue, newValue: value)
                        }
                    }
                }
            }
        }
        if (updateKeys.count > 0) {
            for delegate in self.uikitEventDelegates.allObjects {
                delegate.onRoomPropertiesFullUpdated?(updateKeys, oldProperties: oldProperties, properties: self.getRoomProperties())
            }
        }
    }

    //MARK: - mesage
    func onIMRecvBroadcastMessage(_ messageList: [ZegoBroadcastMessageInfo], roomID: String) {
        if roomID == self.room?.roomID {
            var newMessageList = [ZegoInRoomMessage]()
            for messageInfo in messageList {
                let sender = ZegoUIKitUser.init(messageInfo.fromUser.userID, messageInfo.fromUser.userName)
                let roomMessage = ZegoInRoomMessage.init(messageInfo.message, messageID: Int64(messageInfo.messageID), sendTime: messageInfo.sendTime, user: sender)
                newMessageList.append(roomMessage)
            }
            self.messageList.append(contentsOf: newMessageList)
            for delegate in self.uikitEventDelegates.allObjects {
                delegate.onInRoomMessageReceived?(newMessageList)
            }
        }
    }

    func onIMRecvBarrageMessage(_ messageList: [ZegoBarrageMessageInfo], roomID: String) {
      var newMessageList: [ZegoUIKitBarrageMessageInfo] = []
      for info in messageList {
        let newInfo = ZegoUIKitBarrageMessageInfo()
        newInfo.message = info.message
        newInfo.messageID = info.messageID
        newInfo.sendTime = info.sendTime
        newInfo.fromUser = ZegoUIKitUser(info.fromUser.userID, info.fromUser.userName)
        newMessageList.append(newInfo)
      }
      for delegate in self.uikitEventDelegates.allObjects {
          delegate.onIMRecvBarrageMessage?(roomID, messageList: newMessageList)
      }
    }
  
    func onIMRecvCustomCommand(_ command: String, from fromUser: ZegoUser, roomID: String) {
        let commandDict: [String : AnyObject] = command.convertStringToDictionary() ?? [:]
        for key in commandDict.keys {
            if key == "zego_remove_user" {
                //remove user
                let removeUserList: [String]? = commandDict[key] as? [String]
                if let removeUserList = removeUserList,
                   removeUserList.contains(where: {$0 == self.localParticipant?.userID})
                {
                    for delegate in self.uikitEventDelegates.allObjects {
                        delegate.onMeRemovedFromRoom?()
                    }
                    self.leaveRoom()
                }
            } else if key == "zego_turn_microphone_on" {
                for delegate in self.uikitEventDelegates.allObjects {
                    delegate.onTurnOnYourMicrophoneRequest?(ZegoUIKitUser.init(fromUser.userID, fromUser.userName))
                }
            } else if key == "zego_turn_microphone_off" {
                self.turnMicDeviceOn(self.localParticipant?.userID ?? "", isOn: false, mute: false)
                
            } else if key == "zego_turn_camera_on" {
                
                for delegate in self.uikitEventDelegates.allObjects {
                    delegate.onTurnOnYourCameraRequest?(ZegoUIKitUser.init(fromUser.userID, fromUser.userName))
                }
            } else if key == "zego_turn_camera_off" {
                
                self.turnCameraDeviceOn(self.localParticipant?.userID ?? "", isOn: false)
            }
        }
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onInRoomCommandReceived?(ZegoUIKitUser.init(fromUser.userID, fromUser.userName), command: command)
        }
    }
    
    func onPlayerRecvSEI(_ data: Data, streamID: String) {
        for delegate in self.uikitEventDelegates.allObjects {
            if let seiString = String(data: data, encoding: .utf8) {
                delegate.onPlayerRecvSEI?(seiString, streamID: streamID)
            }
        }
    }
    
    func onPlayerRecvAudioFirstFrame(_ streamID: String) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onPlayerRecvAudioFirstFrame?(streamID)
        }
    }
    
    func onPlayerRecvVideoFirstFrame(_ streamID: String) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onPlayerRecvVideoFirstFrame?(streamID)
        }
    }
    
    //MARK: - ZegoCustomVideoRenderHandler
    func onRemoteVideoFrameCVPixelBuffer(_ buffer: CVPixelBuffer, param: ZegoVideoFrameParam, streamID: String) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onRemoteVideoFrameCVPixelBuffer?(buffer, param: param, streamID: streamID)
        }
    }
    
    func onCapturedVideoFrameCVPixelBuffer(_ buffer: CVPixelBuffer, param: ZegoVideoFrameParam, flipMode: ZegoVideoFlipMode, channel: ZegoPublishChannel) {
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onCapturedVideoFrameCVPixelBuffer?(buffer, param: param, flipMode: flipMode, channel: channel)
        }
    }
}
