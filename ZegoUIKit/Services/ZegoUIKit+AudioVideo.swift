//
//  UIKitService+AudioVideo.swift
//  ZegoUIKit
//
//  Created by zego on 2022/7/25.
//

import Foundation
import ZegoExpressEngine

extension ZegoUIKit {
    
    public func setAudioVideoResourceMode(_ model: ZegoAudioVideoResourceMode) {
        ZegoUIKitCore.shared.setAudioVideoResourceMode(model)
    }
    
    public func useFrontFacingCamera(isFrontFacing: Bool) {
        ZegoUIKitCore.shared.useFrontFacingCamera(isFrontFacing: isFrontFacing)
    }
    
    public func setAudioOutputToSpeaker(enable: Bool) {
        ZegoUIKitCore.shared.enableSpeaker(enable: enable)
    }
    
    public func setVideoConfig(config: ZegoPresetResolution) {
        let videoPreset = ZegoVideoConfigPreset(rawValue: config.rawValue)!
        let videoConfig = ZegoVideoConfig(preset: videoPreset)
        ZegoUIKitCore.shared.setVideoConfig(videoConfig)
    }
    
    public func getAudioRouteType() -> ZegoUIKitAudioOutputDevice {
        return ZegoUIKitAudioOutputDevice(rawValue: UInt(ZegoUIKitCore.shared.audioOutputDeviceType()!.rawValue))!
    }
    
    public func isMicrophoneOn(_ userID: String) -> Bool {
        return ZegoUIKitCore.shared.isMicDeviceOn(userID)
    }
    
    public func isCameraOn(_ userID: String) -> Bool {
        return ZegoUIKitCore.shared.isCameraDeviceOn(userID)
    }
    
    public func turnMicrophoneOn(_ userID: String, isOn: Bool, mute: Bool = false) {
        ZegoUIKitCore.shared.turnMicDeviceOn(userID, isOn: isOn, mute: mute)
    }
    
    public func turnCameraOn(_ userID: String, isOn: Bool) {
        ZegoUIKitCore.shared.turnCameraDeviceOn(userID, isOn: isOn)
    }
    
    public func startPlayingAllAudioVideo() {
        self.enableAudioVideoPlaying = true
        ZegoUIKitCore.shared.startPlayingAllAudioVideo()
    }
    
    public func stopPlayingAllAudioVideo() {
        self.enableAudioVideoPlaying = false
        ZegoUIKitCore.shared.stopPlayingAllAudioVideo()
    }
    
    public func startPublishingStream(_ streamID: String) {
        ZegoUIKitCore.shared.startPublishStream(streamID)
    }
    
    public func stopPublishingStream() {
        ZegoUIKitCore.shared.stopPublishStream()
    }
    
    public func startPlayMixerStream(streamID: String, renderView: UIView, videoModel: ZegoUIKitVideoFillMode) {
        ZegoUIKitCore.shared.playMixerStream(streamID: streamID, renderView: renderView, videoModel: videoModel)
    }
    
    public func startMixerTask(_ task: ZegoMixerTask, callback: ZegoUIKitCallBack?) {
        ZegoUIKitCore.shared.startMixerTask(task, callback: callback)
    }
    
    public func stopMixerTask(_ task: ZegoMixerTask, callback: ZegoUIKitCallBack?) {
        ZegoUIKitCore.shared.stopMixerTask(task, callback: callback)
    }
    
    public func mutePlayStreamAudio(streamID: String, mute: Bool) {
        ZegoUIKitCore.shared.mutePlayStreamAudio(streamID: streamID, mute: mute)
    }
    
    public func mutePlayStreamVideo(streamID: String, mute: Bool) {
        ZegoUIKitCore.shared.mutePlayStreamVideo(streamID: streamID, mute: mute)
    }
    
    public func startPlayStream(_ streamID: String, renderView: UIView?, videoModel: ZegoUIKitVideoFillMode) {
        ZegoUIKitCore.shared.playStream(streamID: streamID, renderView: renderView, videoModel: videoModel)
    }
    
    public func stopPlayStream(_ streamID: String) {
        ZegoUIKitCore.shared.stopPlayStream(streamID)
    }
    
    public func startPreview(_ renderView: UIView, videoMode: ZegoUIKitVideoFillMode) {
        ZegoUIKitCore.shared.startPreview(renderView, videoMode: videoMode)
    }
    
    public func setLocalVideoView(renderView: UIView, videoMode: ZegoUIKitVideoFillMode) {
        ZegoUIKitCore.shared.setLocalVideoView(renderView: renderView, videoMode: videoMode)
    }
    
    public func setRemoteVideoView(userID: String, renderView: UIView, videoMode: ZegoUIKitVideoFillMode) {
        ZegoUIKitCore.shared.setRemoteVideoView(userID: userID, renderView: renderView, videoMode: videoMode)
    }
    
    public func setRemoteScreenShareView(userID: String, renderView: UIView, videoMode: ZegoUIKitVideoFillMode = .aspectFit) {
        ZegoUIKitCore.shared.setRemoteScreenShareView(userID: userID, renderView: renderView, videoMode: videoMode)
    }
    
    public func enable3A(_ enable: Bool, aecMode: ZegoUIKitZegoAECMode) {
        ZegoUIKitCore.shared.enable3A(enable, aecMode:aecMode)
    }
}
