//
//  UIKitService.swift
//  ZegoUIKit
//
//  Created by zego on 2022/7/25.
//

import UIKit
import ZegoExpressEngine
import ZegoPluginAdapter

public typealias ZegoUIKitCallBack = (_ data: Dictionary<String, AnyObject>?) -> ()

@objcMembers
public class ZegoUIKit: NSObject {
    
    /// @return UIKitService singleton instance
    public static let shared = ZegoUIKit()
    
    public var localUserInfo: ZegoUIKitUser? {
        get {
            let user: ZegoUIKitUser? = ZegoUIKitCore.shared.localParticipant?.toUserInfo()
            return user
        }
    }
    
    public var userList: [ZegoUIKitUser] {
        get {
            var users = [ZegoUIKitUser]()
            for participant in ZegoUIKitCore.shared.participantDic.values {
                users.append(participant.toUserInfo())
            }
            return users
        }
    }
    
    public var streamList: [String] {
        get {
            return Array(ZegoUIKitCore.shared.streamDic.keys)
        }
    }
    
    public var room: ZegoUIKitRoom? {
        get {
            return ZegoUIKitCore.shared.room
        }
    }
    
    public var enableAudioVideoPlaying: Bool = true
    
    private override init() {
        super.init()
    }

    public func initWithAppID(appID: UInt32, appSign: String) {
        ZegoUIKitCore.shared.initWithAppID(appID: appID, appSign: appSign)
    }
    
    public func uninit() {
        ZegoUIKitCore.shared.uninit()
    }
    
    public func getVersion() -> String {
        return "1.0.0"
    }
    
    public func addEventHandler(_ eventHandle: ZegoUIKitEventHandle?) {
        ZegoUIKitCore.shared.addEventHandler(eventHandle)
    }
    
    public func removeEventHandler(_ eventHandle: ZegoUIKitEventHandle?) {
        ZegoUIKitCore.shared.removeEventHandler(eventHandle)
    }
    
    public static func getSignalingPlugin() -> ZegoUIKitSignalingPluginImpl {
        return ZegoUIKitSignalingPluginImpl.shared
    }
    
    public func callExperimentalAPI(params: String) {
        ZegoUIKitCore.shared.callExperimentalAPI(params: params)
    }
    
    public func enableCustomVideoRender(enable: Bool) {
        ZegoUIKitCore.shared.enableCustomVideoRender(enable: enable)
    }
}
