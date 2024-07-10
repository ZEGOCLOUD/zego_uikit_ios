//
//  ZegoUIKitBarrageMessageInfo.swift
//  ZegoUIKit
//
//  Created by zegom on 2024/6/26.
//

import UIKit

@objcMembers
public class ZegoUIKitBarrageMessageInfo: NSObject {
  public var message: String?
  public var messageID: String?
  public var sendTime: CUnsignedLongLong?
  public var fromUser: ZegoUIKitUser?
  
}
