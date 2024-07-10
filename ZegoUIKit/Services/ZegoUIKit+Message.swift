//
//  ZegoUIKit+Message.swift
//  ZegoUIKit
//
//  Created by zego on 2022/8/22.
//

import Foundation
import ZegoExpressEngine

public typealias ZegoUIKitSendMessageCallback = (Result<Any, Error>) -> Void
public typealias ZegoSendInRoomCommnadCallback = (_ errorCode: Int32) -> Void
public typealias ZegoIMSendBarrageMessageCallback = (_ errorCode: Int32, _ messageID:String) -> Void

extension ZegoUIKit {
    
    public func getInRoomMessages() -> [ZegoInRoomMessage] {
        return ZegoUIKitCore.shared.getInRoomMessages()
    }
    
    public func sendInRoomMessage(_ message: String) {
        ZegoUIKitCore.shared.sendInRoomMessage(message)
    }
    
    public func resendInRoomMessage(_ message: ZegoInRoomMessage) {
        ZegoUIKitCore.shared.resendInRoomMessage(message)
    }
    
    public func sendInRoomCommand(_ command: String, toUserIDs: [String], callback: ZegoSendInRoomCommnadCallback?) {
        ZegoUIKitCore.shared.sendInRoomCommand(command, toUserIDs: toUserIDs, callback: callback)
    }
    
    public func sendSEI(_ seiString: String) {
        ZegoUIKitCore.shared.sendSEI(seiString)
    }
    
    public func sendBarrageMessage(roomID: String , message: String, callback: ZegoIMSendBarrageMessageCallback?) {
      ZegoUIKitCore.shared.sendBarrageMessage(roomID: roomID, message: message, callback: callback)
    }
}
