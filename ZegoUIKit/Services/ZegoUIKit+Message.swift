//
//  ZegoUIKit+Message.swift
//  ZegoUIKit
//
//  Created by zego on 2022/8/22.
//

import Foundation
import ZegoExpressEngine

public typealias ZegoUIKitSendMessageCallback = (_ errorCode: Int32) -> Void
public typealias ZegoSendInRoomCommandCallback = (_ errorCode: Int32) -> Void
public typealias ZegoIMSendBarrageMessageCallback = (_ errorCode: Int32, _ messageID:String) -> Void

extension ZegoUIKit {
    
    public func getInRoomMessages() -> [ZegoInRoomMessage] {
        return ZegoUIKitCore.shared.getInRoomMessages()
    }
    
    public func sendInRoomMessage(_ message: String,callback:ZegoUIKitSendMessageCallback?) {
        ZegoUIKitCore.shared.sendInRoomMessage(message,callback: callback)
    }
    
    public func resendInRoomMessage(_ message: ZegoInRoomMessage) {
        ZegoUIKitCore.shared.resendInRoomMessage(message)
    }
    
    public func sendInRoomCommand(command: String, toUserIDs: [String], callback: ZegoSendInRoomCommandCallback?) {
        ZegoUIKitCore.shared.sendInRoomCommand(command, toUserIDs: toUserIDs, callback: callback)
    }
    
    public func sendSEI(_ seiString: String) {
        ZegoUIKitCore.shared.sendSEI(seiString)
    }
    
    public func sendBarrageMessage(roomID: String , message: String, callback: ZegoIMSendBarrageMessageCallback?) {
      ZegoUIKitCore.shared.sendBarrageMessage(roomID: roomID, message: message, callback: callback)
    }
}
