//
//  ZegoUIKitCore+Message.swift
//  ZegoUIKit
//
//  Created by zego on 2022/8/22.
//

import Foundation
import ZegoExpressEngine

extension ZegoUIKitCore {
    
    func getInRoomMessages() -> [ZegoInRoomMessage] {
        return self.messageList
    }
    
    func sendInRoomMessage(_ message: String) {
        guard let roomID = self.room?.roomID else { return }
        self.localMessageId = self.localMessageId - 1
        let roomMessage: ZegoInRoomMessage = ZegoInRoomMessage(message, messageID: self.localMessageId, sendTime: self.getTimeStamp(), user: self.localParticipant?.toUserInfo() ?? ZegoUIKitUser())
        roomMessage.state = .idle
        self.messageList.append(roomMessage)
        for delegate in self.uikitEventDelegates.allObjects {
            delegate.onInRoomMessageSendingStateChanged?(roomMessage)
        }
        
        ZegoExpressEngine.shared().sendBroadcastMessage(message, roomID: roomID) { errorCode, messageID in
            if errorCode == 0 {
                roomMessage.state = .success
            } else {
                roomMessage.state = .failed
            }
            for delegate in self.uikitEventDelegates.allObjects {
                delegate.onInRoomMessageSendingStateChanged?(roomMessage)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if roomMessage.state == .idle {
                roomMessage.state = .sending
                for delegate in self.uikitEventDelegates.allObjects {
                    delegate.onInRoomMessageSendingStateChanged?(roomMessage)
                }
            }
        }
    }
    
    func resendInRoomMessage(_ message: ZegoInRoomMessage) {
        guard let messageContent = message.message else { return }
        self.messageList.removeAll(where: {$0.messageID == message.messageID})
        self.sendInRoomMessage(messageContent)
    }
    
    func sendInRoomCommand(_ command: String, toUserIDs: [String], callback: ZegoSendInRoomCommnadCallback?) {
        guard let roomID = room?.roomID else { return }
        var userList: [ZegoUser] = []
        for userID in toUserIDs {
            let user = ZegoUser.init(userID: userID, userName: "")
            userList.append(user)
        }
        ZegoExpressEngine.shared().sendCustomCommand(command, toUserList: userList, roomID: roomID) { errorCode in
            guard let callback = callback else { return }
            callback(errorCode)
        }
    }
    
  
    public func sendBarrageMessage(roomID: String , message: String, callback: ZegoIMSendBarrageMessageCallback?) {
      ZegoExpressEngine.shared().sendBarrageMessage(message, roomID: roomID) { errorCode, messageID in
        guard let callback = callback else { return }
        callback(errorCode,messageID)
      }
    }
  
    func getTimeStamp() -> UInt64 {
        let timeInterval: TimeInterval = Date().timeIntervalSince1970
        let timeStamp = UInt64(timeInterval)
        return timeStamp
    }
}
