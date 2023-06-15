//
//  ZegoAVContainerComponent.swift
//  ZegoUIKitExample
//
//  Created by zego on 2022/7/15.
//

import UIKit
import ZegoExpressEngine

public protocol ZegoAudioVideoContainerDelegate: AnyObject {
    func getForegroundView(_ userInfo: ZegoUIKitUser?) -> ZegoBaseAudioVideoForegroundView?
    func sortAudioVideo(_ userList: [ZegoUIKitUser]) -> [ZegoUIKitUser]?
}

extension ZegoAudioVideoContainerDelegate {
    func sortAudioVideo(_ userList: [ZegoUIKitUser]) -> [ZegoUIKitUser]? {
        return userList
    }
}

public class ZegoAudioVideoContainer: NSObject {
    
    public weak var delegate: ZegoAudioVideoContainerDelegate?
    public var view: ZegoAudioVideoContainerView!
    
    private let help: ZegoAudioVideoContainer_Help = ZegoAudioVideoContainer_Help()
    
    public override init() {
        super.init()
        self.view = ZegoAudioVideoContainerView()
        self.help.container = self
    }
    
    public func setLayout(_ mode:ZegoUIKitLayoutMode, config: ZegoLayoutConfig, audioVideoConfig: ZegoAudioVideoViewConfig) {
        switch mode {
        case .pictureInPicture,.gallery:
            self.view.delegate = self.help
            self.view.setLayout(mode, config: config, audioVideoConfig: audioVideoConfig)
        case .invalid:
            fatalError("A valid mode must be set")
        }
    }
    
    public func setLayout(_ layout: ZegoLayout, audioVideoConfig: ZegoAudioVideoViewConfig) {
        guard let config = layout.config else {
            fatalError("Layout config must be set")
        }
        switch layout.mode {
        case .pictureInPicture,.gallery:
            self.view.delegate = self.help
            self.view.setLayout(layout.mode, config: config, audioVideoConfig: audioVideoConfig)
        case .invalid:
            fatalError("A valid mode must be set")
        }
    }
    
    public func reload() {
        self.view.reload()
    }
    
    deinit {
        print("ZegoAudioVideoContainer deinit")
    }
}

fileprivate class ZegoAudioVideoContainer_Help: NSObject, ZegoUIKitEventHandle, ZegoAudioVideoContainerViewDelegate {
    
    weak var container: ZegoAudioVideoContainer?
    
    func getForegroundView(_ userInfo: ZegoUIKitUser?) -> ZegoBaseAudioVideoForegroundView? {
        return self.container?.delegate?.getForegroundView(userInfo)
    }
    
    func sortAudioVideo(_ userList: [ZegoUIKitUser]) -> [ZegoUIKitUser]? {
        return self.container?.delegate?.sortAudioVideo(userList)
    }
}
