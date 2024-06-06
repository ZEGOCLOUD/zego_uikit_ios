//
//  ZegoLayoutFixedSideBySideConfig.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/9/8.
//

import UIKit

@objcMembers
public class ZegoLayoutGalleryConfig: ZegoLayoutConfig {
    /// Whether to display rounded corners and spacing between Views
    public var addBorderRadiusAndSpacingBetweenView: Bool = true
    public var removeViewWhenAudioVideoUnavailable: Bool = false
    public var showNewScreenSharingViewInFullscreenMode: Bool = true
    public var showScreenSharingFullscreenModeToggleButtonRules: ZegoShowFullscreenModeToggleButtonRules = .showWhenScreenPressed
}
