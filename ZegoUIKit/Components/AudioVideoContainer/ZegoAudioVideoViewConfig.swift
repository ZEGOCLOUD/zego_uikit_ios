//
//  ZegoAudioVideoViewConfig.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/9/5.
//

import UIKit

public class ZegoAudioVideoViewConfig: NSObject {
    /// Whether to display the sound waves around the profile picture in voice mode
    public var showSoundWavesInAudioMode: Bool = true
    /// Default true, normal black edge mode (otherwise landscape is ugly)
    public var useVideoViewAspectFill: Bool = true
    public var avatarAlignment: ZegoAvatarAlignment = .center
    public var avatarSize: CGSize?
}
