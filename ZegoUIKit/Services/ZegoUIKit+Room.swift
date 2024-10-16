//
//  UIKitService+Room.swift
//  ZegoUIKit
//
//  Created by zego on 2022/7/25.
//

import Foundation
import ZegoExpressEngine

extension ZegoUIKit {
    
  public func joinRoom(_ userID: String, userName: String, roomID: String, markAsLargeRoom: Bool = false, callBack: @escaping (Int) -> Void) {
      ZegoUIKitCore.shared.joinRoom(userID, userName: userName, roomID: roomID, markAsLargeRoom: markAsLargeRoom,callBack: callBack)
    }
    
    public func leaveRoom() {
        ZegoUIKitCore.shared.leaveRoom()
    }
    
    public func setRoomProperty(_ key: String, value: String, callback: ZegoUIKitCallBack?) {
        ZegoUIKitCore.shared.setRoomProperty(key, value: value, callback: callback)
    }
    
    public func setRoomScenario(_ scenario: UInt) {
        ZegoUIKitCore.shared.setRoomScenario(scenario)
    }
    
    public func getRoomProperties() -> [String : String] {
        return ZegoUIKitCore.shared.getRoomProperties()
    }
    
    public func updateRoomProperties(_ roomProperties: [String : String], callback: ZegoUIKitCallBack?) {
        ZegoUIKitCore.shared.updateRoomProperties(roomProperties, callback: callback)
    }
    
    public func removeUserFromRoom(_ userIDs: [String]) {
        ZegoUIKitCore.shared.removeUserFromRoom(userIDs)
    }
}
