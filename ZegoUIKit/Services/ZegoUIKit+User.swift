//
//  UIKitService+User.swift
//  ZegoUIKit
//
//  Created by zego on 2022/7/25.
//

import Foundation
import ZegoExpressEngine

extension ZegoUIKit {
    
    public func login(_ userID: String, userName: String) {
        ZegoUIKitCore.shared.login(userID, userName: userName)
    }
    
    public func getUser(_ userID: String) -> ZegoUIKitUser? {
        return ZegoUIKitCore.shared.participantDic[userID]?.toUserInfo()
    }
    
    public func getAllUsers() -> [ZegoUIKitUser] {
        return ZegoUIKitCore.shared.getAllUsers()
    }
    
    func getStreamUserList() -> [ZegoUIKitUser] {
        var userList: [ZegoUIKitUser] = []
        for userID in ZegoUIKitCore.shared.streamDic.values {
            userList.append(ZegoUIKitUser.init(userID, ""))
        }
        return userList
    }
    
    func getScreenStreamList() -> [ZegoUIKitUser] {
        var userList: [ZegoUIKitUser] = []
        for userID in ZegoUIKitCore.shared.auxStreamDic.values {
            userList.append(ZegoUIKitUser.init(userID, ""))
        }
        return userList
    }
}
