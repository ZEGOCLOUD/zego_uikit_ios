//
//  UIKitEnum.swift
//  ZegoUIKitExample
//
//  Created by zego on 2022/7/14.
//

import Foundation
import ZegoExpressEngine

@objc public enum ZegoUIKitVideoFillMode: UInt {
    /// The proportional scaling up, there may be black borders
    case aspectFit = 0
    /// The proportional zoom fills the entire View and may be partially cut
    case aspectFill = 1
    /// Fill the entire view, the image may be stretched
    case scaleToFill = 2
}

@objc public enum ZegoUIKitZegoAECMode: UInt {
    /// Soft ANS. In most instances, the sound quality will not be damaged, but some noise will remain.
    case soft = 0
    /// Medium ANS. It may damage some sound quality, but it has a good noise reduction effect.
    case medium = 1
    /// Aggressive ANS. It may significantly impair the sound quality, but it has a good noise reduction effect.
    case aggressive = 2
    /// AI mode ANS. It will cause great damage to music, so it can not be used for noise suppression of sound sources that need to collect background sound. Please contact ZEGO technical support before use.
    case ai = 3
    /// Balanced AI mode ANS. It will cause great damage to music, so it can not be used for noise suppression of sound sources that need to collect background sound. Please contact ZEGO technical support before use.
    case aiBalanced = 4
    /// Low latency AI mode ANS. It will cause great damage to music, so it can not be used for noise suppression of sound sources that need to collect background sound. Please contact ZEGO technical support before use.
    case aiLowLatency = 5
}


@objc public enum ZegoUIKitLayoutMode: UInt {
    /// Picture within picture
    case pictureInPicture = 0
    ///Side by side mode
    case gallery = 1
    case invalid
}

@objc public enum ZegoViewPosition: Int {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

@objc public enum ZegoUIKitRoomStateChangedReason: UInt {
    /// Logging in to the room. When calling [loginRoom] to log in to the room or [switchRoom] to switch to the target room, it will enter this state, indicating that it is requesting to connect to the server. The application interface is usually displayed through this state.
    case logining = 0
    /// Log in to the room successfully. When the room is successfully logged in or switched, it will enter this state, indicating that the login to the room has been successful, and users can normally receive callback notifications of other users in the room and all stream information additions and deletions.
    case logined = 1
    /// Failed to log in to the room. When the login or switch room fails, it will enter this state, indicating that the login or switch room has failed, for example, AppID or Token is incorrect, etc.
    case loginFailed = 2
    /// The room connection is temporarily interrupted. If the interruption occurs due to poor network quality, the SDK will retry internally.
    case reconnecting = 3
    /// The room is successfully reconnected. If there is an interruption due to poor network quality, the SDK will retry internally, and enter this state after successful reconnection.
    case reconnected = 4
    /// The room fails to reconnect. If there is an interruption due to poor network quality, the SDK will retry internally, and enter this state after the reconnection fails.
    case reconnectFailed = 5
    /// Kicked out of the room by the server. For example, if you log in to the room with the same user name in other places, and the local end is kicked out of the room, it will enter this state.
    case kickOut = 6
    /// Logout of the room is successful. It is in this state by default before logging into the room. When calling [logoutRoom] to log out of the room successfully or [switchRoom] to log out of the current room successfully, it will enter this state.
    case logout = 7
    /// Failed to log out of the room. Enter this state when calling [logoutRoom] fails to log out of the room or [switchRoom] fails to log out of the current room internally.
    case logoutFailed = 8
}

/// Audio route
@objc public enum ZegoUIKitAudioOutputDevice: UInt {
    /// Speaker
    case speaker = 0
    /// Headphone
    case headphone = 1
    /// Bluetooth device
    case bluetooth = 2
    /// Receiver
    case earSpeaker = 3
    /// External USB audio device
    case externalUSB = 4
    /// Apple AirPlay
    case airPlay = 5
}

@objc public enum ZegoInRoomMessageState: Int {
    case idle
    case sending
    case success
    case failed
}

@objc public enum ZegoAvatarAlignment: Int {
    case center
    case start
    case end
}

@objc public enum ZegoAudioVideoResourceMode: UInt {
    case `default`
    case CDNOnly
    case L3Only
    case RTCOnly
    case CDNPlus
}

@objc public enum ZegoShowFullscreenModeToggleButtonRules: UInt {
    case showWhenScreenPressed
    case alwaysShow
    case alwaysHide
}


@objc public enum ZegoPresetResolution : UInt {
  case PRESET_180P = 0
  case PRESET_270P
  case PRESET_360P
  case PRESET_540P
  case PRESET_720P
  case PRESET_1080P
}

enum ZegoUIIconSetType: String, Hashable {
    case icon_camera_normal
    case icon_camera_off
    case icon_mic_normal
    case icon_mic_off
    case icon_speaker_normal
    case icon_speaker_off
    case icon_iphone
    case icon_more
    case icon_camera_flip
    case icon_bluetooth
    case icon_mic_status_wave
    case icon_mic_status_off
    case icon_mic_status_nomal
    case icon_wifi
    case icon_camera_status_nomal
    case icon_camera_status_off
    
    case icon_camera_normal_2
    case icon_camera_off_2
    
    case icon_camera_overturn_2
    
    case camera_normal_2
    case camera_off_2
    
    case call_accept_icon
    case call_accept_selected_icon
    case call_accept_loading
    case call_decline_icon
    case call_decline_selected_icon
    case call_video_icon
    case call_video_selected_icon
    case call_hand_up_icon
    case call_hand_up_selected_icon
    
    case user_phone_icon
    case user_video_icon
    
    case message_send_button_disabled
    case message_send_button
    
    case top_close
    
    case icon_member_mic
    case icon_member_mic_off
    case icon_member_mic_nor
    case icon_member_mic_wave
    case icon_member_camera
    case icon_member_camera_off
    
    case icon_message_normal
    case message_loading
    case icon_message_fail
    
    case full_screen_nomal
    case full_screen_select
  
    case lock_seat
    case un_lock_seat
    // MARK: - Image handling
    
//    private static let bundle = Bundle(identifier: "im.zego.uikit")
    
    func load() -> UIImage {
        let image = UIImage.resource.loadImage(name: self.rawValue, frameworkName: "ZegoUIKit", bundleName: "ZegoUIKit") ?? UIImage()
        return image
    }
}
