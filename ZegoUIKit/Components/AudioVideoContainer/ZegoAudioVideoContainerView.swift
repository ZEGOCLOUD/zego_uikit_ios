//
//  ZegoAudioVideoContainerView.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/9/8.
//

import UIKit

protocol ZegoAudioVideoContainerViewDelegate: AnyObject {
    func getForegroundView(_ userInfo: ZegoUIKitUser?) -> ZegoBaseAudioVideoForegroundView?
    func sortAudioVideo(_ userList: [ZegoUIKitUser]) -> [ZegoUIKitUser]?
}

extension ZegoAudioVideoContainerViewDelegate {
    func sortAudioVideo(_ userList: [ZegoUIKitUser]) -> [ZegoUIKitUser]? {
        return userList
    }
}

public class ZegoAudioVideoContainerView: UIView {
    
    weak var delegate: ZegoAudioVideoContainerViewDelegate?
    var displayView: UIView?
    let help: ZegoAudioVideoContainerView_Help = ZegoAudioVideoContainerView_Help()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.help.containerView = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func reload() {
        if self.displayView is ZegoPipLayoutView {
            (self.displayView as! ZegoPipLayoutView).reload()
        }
    }
    
    deinit {
        print("ZegoAudioVideoContainerView deinit")
    }
    
    func setLayout(_ mode:ZegoUIKitLayoutMode, config: ZegoLayoutConfig, audioVideoConfig: ZegoAudioVideoViewConfig) {
        switch mode {
        case .pictureInPicture:
            self.displayView = ZegoPipLayoutView()
            let pipView: ZegoPipLayoutView = self.displayView as! ZegoPipLayoutView
            pipView.delegate = self.help
            pipView.pInPLayout(config, audioVideoConfig: audioVideoConfig)
            self.addSubview(pipView)
            pipView.zgu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
        case .gallery:
            self.displayView = ZegoGroupCallLayoutView()
            let groupCallView: ZegoGroupCallLayoutView = self.displayView as! ZegoGroupCallLayoutView
            groupCallView.fixedSideBySideLayout(config, audioVideoViewConfig: audioVideoConfig)
            self.addSubview(groupCallView)
            groupCallView.delegate = self.help
            groupCallView.zgu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
        case .invalid:
            break
        }
    }
}

class ZegoAudioVideoContainerView_Help: NSObject, ZegoPipLayoutViewDelegate,ZegoGroupCallLayoutViewDelegate {
    
    weak var containerView: ZegoAudioVideoContainerView?
    
    func getForegroundView(_ userInfo: ZegoUIKitUser?) -> ZegoBaseAudioVideoForegroundView? {
        return self.containerView?.delegate?.getForegroundView(userInfo)
    }
    
    func sortAudioVideo(_ userList: [ZegoUIKitUser]) -> [ZegoUIKitUser]? {
        return self.containerView?.delegate?.sortAudioVideo(userList)
    }
}
