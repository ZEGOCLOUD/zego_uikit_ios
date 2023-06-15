//
//  ZegoInRoomMessage.swift
//  ZegoUIKit
//
//  Created by zego on 2022/8/22.
//

import UIKit

@objcMembers
open class ZegoInRoomMessage: NSObject {
    public var message: String?
    public var messageID: Int64 = 0
    public var sendTime: UInt64 = 0
    public var user: ZegoUIKitUser?
    public var state: ZegoInRoomMessageState = .idle
    
    public init(_ message: String, messageID: Int64, sendTime: UInt64, user: ZegoUIKitUser) {
        self.message = message
        self.messageID = messageID
        self.sendTime = sendTime
        self.user = user
    }
}
