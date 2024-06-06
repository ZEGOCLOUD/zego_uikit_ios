//
//  ZegoTranslationText.swift
//  ZegoUIKit
//
//  Created by zego on 2024/4/24.
//

import UIKit

@objc public enum ZegoUIKitLanguage : UInt32 {
  case ENGLISH
  case CHS
}

public class ZegoUIKitTranslationTextConfig : NSObject {
    public static let shared = ZegoUIKitTranslationTextConfig() // 使用静态常量来保存单例实例
    public var translationText : ZegoUIKitTranslationText = ZegoUIKitTranslationText(language: .ENGLISH)
  
    private override init() {} // 私有化初始化方法，防止外部创建实例
}

public class ZegoUIKitTranslationText: NSObject {
  var language :ZegoUIKitLanguage  = .ENGLISH
  public var leaveRoomTextDialogTitle: String = "Leave the room"
  public var leaveRoomTextDialogMessage: String = "Are you sure to leave room?"
  public var cancelDialogMessage: String = "Cancel"
  public var confirmDialogMessage: String = "Confirm"
  public var enterRoomDialogMessage: String = "enter the room"
  public var quitRoomDialogMessage: String = "quit the room"
  public var leftRoomDialogMessage: String = "left the room"
  public var joinedRoomDialogMessage: String = "joined the room"
  public var enteredRoomDialogMessage: String = "entered the room"
  public var textFieldPlaceholderMessage: String = "Say something..."
  public var morePersonLiveOtherTitle: String = "%d others"
  public var userIdentityYou: String = "(You)"
  
  public init(language:ZegoUIKitLanguage) {
    super.init()
    self.language = language
    if language == .CHS {
      leaveRoomTextDialogTitle = "离开房间"
      leaveRoomTextDialogMessage = "您确定要离开房间吗?"
      cancelDialogMessage = "取消"
      confirmDialogMessage = "确认"
      enterRoomDialogMessage = "进入房间"
      quitRoomDialogMessage = "退出房间"
      leftRoomDialogMessage = "已离开房间"
      joinedRoomDialogMessage = "已加入房间"
      enteredRoomDialogMessage = "已进入房间"
      textFieldPlaceholderMessage = "说点什么..."
      morePersonLiveOtherTitle = "其他%d人"
      userIdentityYou = "(您)"
    }
  }
  public func getLanguage() -> ZegoUIKitLanguage {
    return self.language
  }
}
