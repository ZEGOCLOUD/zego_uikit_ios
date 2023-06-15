//
//  ZegoPluginEventHandle.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/10/12.
//

import Foundation

@objc public protocol ZegoPluginEventHandle: AnyObject {
    @objc optional func onPluginEvent(_ event: String, data: Dictionary<String,AnyObject>?)
}

