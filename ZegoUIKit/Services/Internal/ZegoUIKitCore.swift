//
//  ZegoUIKitCore.swift
//  ZegoUIKitExample
//
//  Created by zego on 2022/7/15.
//

import UIKit
import ZegoExpressEngine

internal class ZegoParticipant: NSObject {
    let userID: String
    var name: String = ""
    var streamID: String = ""
    var auxStreamID: String = ""
    var renderView: UIView = UIView()
    var screenShareView: UIView = UIView()
    var camera: Bool = false
    var mic: Bool = false
    var muteMode: Bool = false
    var network: ZegoStreamQualityLevel = .excellent
    var videoDisPlayMode: ZegoUIKitVideoFillMode = .aspectFill
    var screenShareDisplayMode: ZegoUIKitVideoFillMode = .aspectFit
    var inRoomAttributes: [String : String] = [:]
    
    init(userID: String, name: String = "") {
        self.userID = userID
        self.name = name
        super.init()
    }
    
    func toUserInfo() -> ZegoUIKitUser {
        let user: ZegoUIKitUser = ZegoUIKitUser(userID, name, camera, mic)
        user.inRoomAttributes = inRoomAttributes
        return user
    }
    
}

internal class ZegoUIKitCore: NSObject {
    
    static let shared = ZegoUIKitCore()
    
    // key is UserID, value is participant model
    var participantDic: Dictionary<String, ZegoParticipant> = Dictionary()
    var streamDic: Dictionary<String, String> = Dictionary()
    var auxStreamDic: Dictionary<String, String> = Dictionary()
    var localParticipant: ZegoParticipant?
    var room: ZegoUIKitRoom?
    var messageList: [ZegoInRoomMessage] = [ZegoInRoomMessage]()
    
    var userList: [ZegoUIKitUser] {
        get {
            var users: [ZegoUIKitUser] = []
            for (_, value) in participantDic {
                users.append(value.toUserInfo())
            }
            return users
        }
    }
    
    var localMessageId: Int64 = 0;
    var roomProperties: [String : AnyObject] = [:]
    var roomMemberCount: Int = 0
    var isLargeRoom: Bool = false
    var markAsLargeRoom: Bool = false
    var resourceModel: ZegoAudioVideoResourceMode = .default
    var muteMode: Bool = false
    
    let uikitEventDelegates = ThreadSafeHashTable<ZegoUIKitEventHandle>()
    
    override init() {
        super.init()
    }
}

extension ZegoUIKitCore {
    func addEventHandler(_ eventHandle: ZegoUIKitEventHandle?) {
        self.uikitEventDelegates.add(eventHandle)
    }
    
    func removeEventHandler(_ eventHandle: ZegoUIKitEventHandle?) {
        uikitEventDelegates.remove(eventHandle)
    }
    
    func initWithAppID(appID: UInt32, appSign: String) {
        let profile = ZegoEngineProfile()
        profile.appID = appID
        profile.appSign = appSign
        profile.scenario = .general
        let config: ZegoEngineConfig = ZegoEngineConfig()
        config.advancedConfig = ["notify_remote_device_unknown_status": "true", "notify_remote_device_init_status":"true"]
        ZegoExpressEngine.setEngineConfig(config)
        ZegoExpressEngine.createEngine(with: profile, eventHandler: self)
        resourceModel = .default
    }
    
    func uninit() {
        ZegoExpressEngine.destroy(nil)
    }
  
    func setRoomScenario(_ rawValue:UInt){
        let scenario = ZegoScenario(rawValue: rawValue) ?? .general 
        ZegoExpressEngine.shared().setRoomScenario(scenario)
    }
    
    func login(_ userID: String, userName: String) {
        if self.localParticipant == nil {
            self.localParticipant = ZegoParticipant(userID: userID, name: userName)
        }
    }
    
    func callExperimentalAPI(params: String) {
        ZegoExpressEngine.shared().callExperimentalAPI(params)
    }
    
    func enableCustomVideoRender(enable: Bool) {
        let renderConfig: ZegoCustomVideoRenderConfig = ZegoCustomVideoRenderConfig()
        renderConfig.bufferType = .cvPixelBuffer
        renderConfig.frameFormatSeries = .RGB
        renderConfig.enableEngineRender = true
        ZegoExpressEngine.shared().enableCustomVideoRender(enable, config: renderConfig)
        ZegoExpressEngine.shared().setCustomVideoRenderHandler(self)
    }
    
    //MARK -- room 相关
    func joinRoom(_ userID: String, userName: String, roomID: String, markAsLargeRoom: Bool, callBack: @escaping (Int) -> Void) {
        self.markAsLargeRoom = markAsLargeRoom
        self.localParticipant = nil
        self.participantDic.removeAll()
        self.streamDic.removeAll()
        self.room = ZegoUIKitRoom.init(roomID)
        let user: ZegoUser = ZegoUser()
        user.userID = userID
        user.userName = userName
        
        let participant: ZegoParticipant = self.localParticipant ?? ZegoParticipant(userID: user.userID, name: user.userName)
        participant.streamID = generateStreamID(userID: participant.userID, roomID: roomID)
        self.participantDic[participant.userID] = participant
        self.localParticipant = participant
        
        let config: ZegoRoomConfig = ZegoRoomConfig()
        config.isUserStatusNotify = true
        ZegoExpressEngine.shared().loginRoom(roomID, user: user, config: config) { code, info in
            print("login code:\(code)")
          callBack(Int(code))
        }
        
        // monitor sound level
        ZegoExpressEngine.shared().startSoundLevelMonitor(1000)
    }
    
    func leaveRoom() {
        self.room = nil
        self.roomProperties.removeAll()
        self.participantDic.removeAll()
        self.streamDic.removeAll()
        self.auxStreamDic.removeAll()
        self.messageList.removeAll()
        ZegoExpressEngine.shared().stopSoundLevelMonitor()
        ZegoExpressEngine.shared().stopPreview()
        ZegoExpressEngine.shared().stopPublishingStream()
        ZegoExpressEngine.shared().logoutRoom { errorCode, dict in
            print("logout room errorCode: %d",errorCode)
        }
    }
    
    //MARK: --
    func useFrontFacingCamera(isFrontFacing: Bool) {
        ZegoExpressEngine.shared().useFrontCamera(isFrontFacing)
    }
    
    func enableSpeaker(enable: Bool) {
        ZegoExpressEngine.shared().setAudioRouteToSpeaker(enable)
    }
    
    func audioOutputDeviceType() -> ZegoAudioRoute? {
        return ZegoExpressEngine.shared().getAudioRouteType()
    }
    
    func isMicDeviceOn(_ userID: String) -> Bool {
        if self.isMySelf(userID) {
            return self.localParticipant?.mic ?? false
        } else {
            guard let participant = self.participantDic[userID] else { return false }
            return participant.mic
        }
    }
    
    func isCameraDeviceOn(_ userID: String) -> Bool {
        if self.isMySelf(userID) {
            return self.localParticipant?.camera ?? false
        } else {
            guard let participant = self.participantDic[userID] else { return false }
            return participant.camera
        }
    }
    
    func turnMicDeviceOn(_ userID: String, isOn: Bool, mute: Bool) {
        muteMode = mute
        if self.isMySelf(userID) {
            self.localParticipant?.mic = isOn
            ZegoExpressEngine.shared().muteMicrophone(!isOn)
            
            let extraInfo: [String : AnyObject] = ["isCameraOn" : self.localParticipant?.camera as AnyObject, "isMicrophoneOn" : isOn as AnyObject]
            ZegoExpressEngine.shared().setStreamExtraInfo(extraInfo.jsonString)
            
            if isOn {
                self.startPublishStream()
                if mute {
                    ZegoExpressEngine.shared().mutePublishStreamAudio(!isOn)
                }
            } else {
                if !(self.localParticipant?.camera ?? false) {
                    if mute {
                        self.startPublishStream()
                        ZegoExpressEngine.shared().mutePublishStreamAudio(mute)
                    } else {
                        self.stopPublishStream()
                    }
                }
            }
            for delegate in self.uikitEventDelegates.allObjects {
                guard let localParticipant = self.localParticipant else { return }
                delegate.onMicrophoneOn?(localParticipant.toUserInfo(), isOn: isOn)
            }
        } else {
            let isLargeRoom: Bool = self.isLargeRoom || markAsLargeRoom
            if isOn {
                let command: String = ["zego_turn_microphone_on": [userID] as AnyObject].jsonString
                self.sendInRoomCommand(command, toUserIDs: isLargeRoom ? [] : [userID], callback: nil)
            } else {
                let command: String = ["zego_turn_microphone_off": [userID] as AnyObject].jsonString
                self.sendInRoomCommand(command, toUserIDs: isLargeRoom ? [] : [userID], callback: nil)
            }
        }
    }
    
    func turnCameraDeviceOn(_ userID: String, isOn: Bool) {
        if self.isMySelf(userID) {
            self.localParticipant?.camera = isOn
            ZegoExpressEngine.shared().enableCamera(isOn)
            
            let extraInfo: [String : AnyObject] = ["isCameraOn" : isOn as AnyObject, "isMicrophoneOn" : self.localParticipant?.mic as AnyObject]
            ZegoExpressEngine.shared().setStreamExtraInfo(extraInfo.jsonString)
            
            if isOn {
                self.startPublishStream()
                if muteMode {
                    ZegoExpressEngine.shared().mutePublishStreamVideo(!isOn)
                }
                if let rendView = self.localParticipant?.renderView {
                    ZegoExpressEngine.shared().startPreview(generateCanvas(rendView: rendView, videoMode: self.localParticipant?.videoDisPlayMode ?? .aspectFill))
                }
            } else {
                if !(self.localParticipant?.mic ?? false) {
                    if muteMode {
                        self.startPublishStream()
                        ZegoExpressEngine.shared().mutePublishStreamVideo(muteMode)
                    } else {
                        self.stopPublishStream()
                    }
                }
                ZegoExpressEngine.shared().stopPreview()
            }
            for delegate in self.uikitEventDelegates.allObjects {
                guard let localParticipant = self.localParticipant else { return }
                delegate.onCameraOn?(localParticipant.toUserInfo(), isOn: isOn)
            }
        } else {
            let isLargeRoom: Bool = self.isLargeRoom || markAsLargeRoom
            if isOn {
                let command: String = ["zego_turn_camera_on": userID as AnyObject].jsonString
                self.sendInRoomCommand(command, toUserIDs: isLargeRoom ? [] : [userID], callback: nil)
            } else {
                let command: String = ["zego_turn_camera_off": userID as AnyObject].jsonString
                self.sendInRoomCommand(command, toUserIDs: isLargeRoom ? [] : [userID], callback: nil)
            }
        }
    }
    
    func setAudioConfig(_ config: ZegoAudioConfig) {
        ZegoExpressEngine.shared().setAudioConfig(config)
    }
    
    func setVideoConfig(_ config: ZegoVideoConfig) {
        ZegoExpressEngine.shared().setVideoConfig(config)
    }
    
    func startPreview(_ renderView: UIView, videoMode: ZegoUIKitVideoFillMode) {
        ZegoExpressEngine.shared().startPreview(generateCanvas(rendView: renderView, videoMode: videoMode))
    }
  
  func enable3A(_ enable: Bool, aecMode: ZegoUIKitZegoAECMode) {
       ZegoExpressEngine.shared().enableAGC(enable);
       ZegoExpressEngine.shared().enableAEC(enable);
       ZegoExpressEngine.shared().enableANS(enable);
       if (enable) {
           ZegoExpressEngine.shared().setANSMode(ZegoANSMode.aggressive);
       }
  }
    
    func setLocalVideoView(renderView: UIView, videoMode: ZegoUIKitVideoFillMode) {
        //        guard let roomID = self.room?.roomID else {
        //            print("Error: [setVideoView] You need to join the room first and then set the videoView")
        //            return
        //        }
        guard let userID = self.localParticipant?.userID else {
            print("Error: [setVideoView] please login room pre")
            return
        }
        
        let participant = participantDic[userID] ?? ZegoParticipant(userID: userID)
        if let roomID = self.room?.roomID {
            participant.streamID = generateStreamID(userID: userID, roomID: roomID)
            self.streamDic[participant.streamID] = participant.userID
        }
        participant.renderView = renderView
        participant.videoDisPlayMode = videoMode
        self.participantDic[userID] = participant
        ZegoExpressEngine.shared().startPreview(generateCanvas(rendView: renderView, videoMode: videoMode))
    }
    
    func setRemoteVideoView(userID: String, renderView: UIView, videoMode: ZegoUIKitVideoFillMode) {
        guard let roomID = self.room?.roomID else {
            print("Error: [setVideoView] You need to join the room first and then set the videoView")
            return
        }
        guard let _ = ZegoUIKit.shared.localUserInfo?.userID else {
            print("Error: [setVideoView] userID is empty, please enter a right userID")
            return
        }
        guard let participant = self.participantDic[userID] else { return }
        participant.streamID = generateStreamID(userID: userID, roomID: roomID)
        participant.renderView = renderView
        participant.videoDisPlayMode = videoMode
        self.participantDic[userID] = participant
        self.streamDic[participant.streamID] = participant.userID
        self.playStream(streamID: participant.streamID, videoModel: videoMode)
    }
    
    func setRemoteScreenShareView(userID: String, renderView: UIView, videoMode: ZegoUIKitVideoFillMode) {
        guard let roomID = self.room?.roomID else {
            print("Error: [setVideoView] You need to join the room first and then set the videoView")
            return
        }
        guard let _ = ZegoUIKit.shared.localUserInfo?.userID else {
            print("Error: [setVideoView] userID is empty, please enter a right userID")
            return
        }
        let participant = self.participantDic[userID] ?? ZegoParticipant(userID: userID)
        participant.auxStreamID = generateAuxStreamID(userID: userID, roomID: roomID)
        participant.screenShareView = renderView
        participant.screenShareDisplayMode = videoMode
        self.participantDic[userID] = participant
        self.auxStreamDic[participant.auxStreamID] = participant.userID
        self.playStream(streamID: participant.auxStreamID, videoModel: videoMode)
    }
    
    func getAllUsers() -> [ZegoUIKitUser] {
        return self.userList
    }
    
    func startPlayingAllAudioVideo() {
        ZegoExpressEngine.shared().muteAllPlayStreamAudio(false)
        ZegoExpressEngine.shared().muteAllPlayStreamVideo(false)
        
    }
    
    func stopPlayingAllAudioVideo() {
        ZegoExpressEngine.shared().muteAllPlayStreamAudio(true)
        ZegoExpressEngine.shared().muteAllPlayStreamVideo(true)
    }
    
    public func setRoomProperty(_ key: String, value: String, callback: ZegoUIKitCallBack?) {
        guard let roomID = self.room?.roomID else { return }
        if self.roomProperties.keys.contains(key) && self.roomProperties[key] as? String == value {
            return
        }
        let oldValue: String = roomProperties.keys.contains(key) ? roomProperties[key] as? String ?? "" : ""
        let oldProperties = self.getRoomProperties();
        roomProperties[key] = value as AnyObject
        let extraInfo: String = roomProperties.jsonString
        ZegoExpressEngine.shared().setRoomExtraInfo(extraInfo, forKey: "extra_info", roomID: roomID) { errorCode in
            if let callback = callback {
                let dict: [String: AnyObject] = ["code": errorCode as AnyObject]
                callback(dict)
            }
            if errorCode == 0 {
                for delegate in self.uikitEventDelegates.allObjects {
                    delegate.onRoomPropertyUpdated?(key, oldValue: oldValue, newValue: value)
                    delegate.onRoomPropertiesFullUpdated?([key], oldProperties: oldProperties, properties: self.getRoomProperties())
                }
            } else {
                if self.roomProperties.keys.contains(key) {
                    self.roomProperties[key] = oldValue as AnyObject
                }
                print("setRoomProperties failed: %d",errorCode)
            }
        }
    }
    
    func getRoomProperties() -> [String: String] {
        var newRoomProperties: [String: String] = [:]
        for key in self.roomProperties.keys {
            let value: String? = self.roomProperties[key] as? String
            guard let value = value else { continue }
            newRoomProperties[key] = value
        }
        return newRoomProperties
    }
    
    func updateRoomProperties(_ newProperties: [String : String], callback: ZegoUIKitCallBack?) {
        guard let roomID = self.room?.roomID else { return }
        let oldProperties: [String : String] = self.getRoomProperties()
        let oldProperties1 = self.roomProperties
        var updateKeys:[String] = []
        for key in newProperties.keys {
            let value: String? = newProperties[key]
            guard let value = value else { continue }
            if roomProperties.keys.contains(key) && roomProperties[key] as! String == value {
                continue
            }
            updateKeys.append(key)
            roomProperties[key] = value as AnyObject
        }
        let extraInfo: String = roomProperties.jsonString
        ZegoExpressEngine.shared().setRoomExtraInfo(extraInfo, forKey: "extra_info", roomID: roomID) { errorCode in
            if let callback = callback {
                let dict: [String: AnyObject] = ["code" : errorCode as AnyObject]
                callback(dict)
            }
            if errorCode == 0 {
                for key in updateKeys {
                    let oldValue: String = oldProperties[key] ?? ""
                    let newValue: String = self.roomProperties[key] as? String ?? ""
                    for delegate in self.uikitEventDelegates.allObjects {
                        delegate.onRoomPropertyUpdated?(key, oldValue: oldValue, newValue: newValue)
                    }
                }
                for delegate in self.uikitEventDelegates.allObjects {
                    delegate.onRoomPropertiesFullUpdated?(updateKeys, oldProperties: oldProperties, properties: self.getRoomProperties())
                }
                
            } else {
                self.roomProperties = oldProperties1
                print("setRoomProperties failed: %d",errorCode)
            }
        }
    }
    
    func playStream(streamID: String, renderView: UIView?, videoModel: ZegoUIKitVideoFillMode) {
        let playConfig: ZegoPlayerConfig = ZegoPlayerConfig()
        playConfig.resourceMode = ZegoStreamResourceMode(rawValue: resourceModel.rawValue) ?? .default
        if let renderView = renderView {
            ZegoExpressEngine.shared().startPlayingStream(streamID, canvas: generateCanvas(rendView: renderView, videoMode: videoModel), config: playConfig)
        } else {
            ZegoExpressEngine.shared().startPlayingStream(streamID, config: playConfig)
        }
    }
    
    func playStream(streamID: String, videoModel: ZegoUIKitVideoFillMode) {
        if streamID.contains("main") {
            playMainStream(streamID: streamID, videoModel: videoModel)
        } else {
            playAuxStream(streamID: streamID, videoModel: videoModel)
        }
    }
    
    func playMainStream(streamID: String, videoModel: ZegoUIKitVideoFillMode) {
        if let userID = streamDic[streamID] {
            let participant: ZegoParticipant? = self.participantDic[userID]
            let playConfig: ZegoPlayerConfig = ZegoPlayerConfig()
            playConfig.resourceMode = ZegoStreamResourceMode(rawValue: resourceModel.rawValue) ?? .default
            if let renderView = participant?.renderView {
                ZegoExpressEngine.shared().startPlayingStream(streamID, canvas: generateCanvas(rendView: renderView, videoMode: videoModel), config: playConfig)
            } else {
                ZegoExpressEngine.shared().startPlayingStream(streamID, config: playConfig)
            }
        }
    }
    
    func playAuxStream(streamID: String, videoModel: ZegoUIKitVideoFillMode) {
        if let userID = auxStreamDic[streamID] {
            let participant: ZegoParticipant? = self.participantDic[userID]
            let playConfig: ZegoPlayerConfig = ZegoPlayerConfig()
            playConfig.resourceMode = ZegoStreamResourceMode(rawValue: resourceModel.rawValue) ?? .default
            if let screenShareView = participant?.screenShareView {
                ZegoExpressEngine.shared().startPlayingStream(streamID, canvas: generateCanvas(rendView: screenShareView, videoMode: videoModel), config: playConfig)
            }
        }
    }
    
    func playMixerStream(streamID: String, renderView: UIView, videoModel: ZegoUIKitVideoFillMode) {
        let playConfig: ZegoPlayerConfig = ZegoPlayerConfig()
        playConfig.resourceMode = ZegoStreamResourceMode(rawValue: resourceModel.rawValue) ?? .default
        ZegoExpressEngine.shared().startPlayingStream(streamID, canvas: generateCanvas(rendView: renderView, videoMode: videoModel), config: playConfig)
    }
    
    private func generateCanvas(rendView: UIView?, videoMode: ZegoUIKitVideoFillMode) -> ZegoCanvas? {
        guard let rendView = rendView else {
            return nil
        }

        let canvas = ZegoCanvas(view: rendView)
        canvas.viewMode = ZegoViewMode(rawValue: videoMode.rawValue) ?? .aspectFill
        return canvas
    }
    
    private func generateStreamID(userID: String, roomID: String) -> String {
        if (userID.count == 0) {
            print("Error: [generateStreamID] userID is empty, please enter a right userID")
        }
        if (roomID.count == 0) {
            print("Error: [generateStreamID] roomID is empty, please enter a right roomID")
        }
        
        // The streamID can use any character.
        // For the convenience of query, roomID + UserID + suffix is used here.
        let streamID = String(format: "%@_%@_main", roomID,userID)
        return streamID
    }
    
    private func generateAuxStreamID(userID: String, roomID: String) -> String {
        if (userID.count == 0) {
            print("Error: [generateStreamID] userID is empty, please enter a right userID")
        }
        if (roomID.count == 0) {
            print("Error: [generateStreamID] roomID is empty, please enter a right roomID")
        }
        
        // The streamID can use any character.
        // For the convenience of query, roomID + UserID + suffix is used here.
        let streamID = String(format: "%@_%@_screensharing", roomID,userID)
        return streamID
    }
    
    
    func startPublishStream(_ streamID: String? = nil) {
        print("startPublishStream:\(streamID ?? "")")
        if let streamID = streamID {
            self.localParticipant?.streamID = streamID
            ZegoExpressEngine.shared().startPublishingStream(streamID)
        } else {
            guard let streamID = self.localParticipant?.streamID else { return }
            ZegoExpressEngine.shared().startPublishingStream(streamID)
        }
        for delegate in self.uikitEventDelegates.allObjects {
            guard let userInfo = self.localParticipant?.toUserInfo() else { return }
            delegate.onAudioVideoAvailable?([userInfo])
        }
    }
    
    func stopPublishStream() {
        guard let streamID = self.localParticipant?.streamID else { return }
        streamDic.removeValue(forKey: streamID)
        ZegoExpressEngine.shared().stopPublishingStream()
        ZegoExpressEngine.shared().stopPreview()
        for delegate in self.uikitEventDelegates.allObjects {
            guard let localParticipant = self.localParticipant else { return }
            delegate.onAudioVideoUnavailable?([localParticipant.toUserInfo()])
        }
    }
    
    private func isMySelf(_ userID: String) -> Bool {
        return userID == ZegoUIKit.shared.localUserInfo?.userID
    }
    
//    fileprivate func updateUserListAttribute(_ participant: ZegoParticipant) {
//        var index: Int = 0
//        for user in self.userList {
//            if user.userID == participant.userID {
//                self.userList[index] = participant.toUserInfo()
//                break
//            }
//            index = index + 1
//        }
//    }
//
    func stopPlayStream(_ streamID: String) {
        ZegoExpressEngine.shared().stopPlayingStream(streamID)
    }
  
    func removeUserFromRoom(_ userIDs: [String]) {
        if (isLargeRoom || markAsLargeRoom) {
            let command: String = ["zego_remove_user": userIDs as AnyObject].jsonString
            ZegoUIKitCore.shared.sendInRoomCommand(command, toUserIDs: [], callback: nil)
        } else {
            let command: String = ["zego_remove_user": userIDs as AnyObject].jsonString
            ZegoUIKitCore.shared.sendInRoomCommand(command, toUserIDs: userIDs, callback: nil)
        }
    }
    
    func setAudioVideoResourceMode(_ model: ZegoAudioVideoResourceMode) {
        resourceModel = model
    }
    
    func sendSEI(_ seiString: String) {
        if let data = seiString.data(using: .utf8) {
            ZegoExpressEngine.shared().sendSEI(data)
        } else {
            print("sendSEI:failed to convert string to data")
        }
    }
    
    public func startMixerTask(_ task: ZegoMixerTask, callback: ZegoUIKitCallBack?) {
        ZegoExpressEngine.shared().start(task) { errorCode, info in
            guard let callback = callback else { return }
            callback(["code": errorCode as AnyObject])
        }
    }

    public func stopMixerTask(_ task: ZegoMixerTask, callback: ZegoUIKitCallBack?) {
        ZegoExpressEngine.shared().stop(task) { errorCode in
            
        }
    }
    
    public func mutePlayStreamAudio(streamID: String, mute: Bool) {
        ZegoExpressEngine.shared().mutePlayStreamAudio(mute, streamID: streamID)
    }
    
    public func mutePlayStreamVideo(streamID: String, mute: Bool) {
        ZegoExpressEngine.shared().mutePlayStreamVideo(mute, streamID: streamID)
    }
    
}
