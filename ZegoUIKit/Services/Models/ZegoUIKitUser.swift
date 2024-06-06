//
//  UserInfo.swift
//  ZegoUIKitExample
//
//  Created by zego on 2022/7/14.
//

import UIKit

@objcMembers
public class ZegoUIKitUser: NSObject, Codable {
    
    public var userID: String?
    public var userName: String?
    public var isCameraOn: Bool = false
    public var isMicrophoneOn: Bool = false
    public var inRoomAttributes: [String : String] = [:]
    
    override init() {
        super.init()
    }
    
    public init(_ userID: String, _ userName: String, _ isCameraOn: Bool = false, _ isMicrophoneOn: Bool = false) {
        super.init()
        self.userID = userID
        self.userName = userName
        self.isCameraOn = isCameraOn
        self.isMicrophoneOn = isMicrophoneOn
    }
}
