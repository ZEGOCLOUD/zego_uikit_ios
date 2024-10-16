//
//  AudioVideoView.swift
//  ZegoUIKit
//
//  Created by zego on 2022/7/25.
//

import UIKit
import ZegoExpressEngine

public protocol AudioVideoViewDelegate: AnyObject {
    func getForegroundView(_ userInfo: ZegoUIKitUser?) -> ZegoBaseAudioVideoForegroundView?
}

public class ZegoAudioVideoView: UIView {

    public weak var delegate: AudioVideoViewDelegate? {
        didSet {
            if delegate != nil {
                self.getMaskView()
            }
        }
    }
    
    public var userID: String? {
        didSet {
            guard let userID = userID else {
                self.headView.isHidden = true
                return
            }
            if userID == ZegoUIKit.shared.localUserInfo?.userID {
                ZegoUIKit.shared.setLocalVideoView(renderView: self.videoView, videoMode: self.videoFillMode)
            } else {
                ZegoUIKit.shared.setRemoteVideoView(userID: userID, renderView: self.videoView, videoMode: self.videoFillMode)
            }
            if ZegoUIKit.shared.isCameraOn(userID) {
                self.headView.isHidden = true
                self.videoView.isHidden = false
            } else {
                self.headView.isHidden = false
                self.videoView.isHidden = true
            }
            self.setHeadUserName(userID)
            self.avatarUrl = ZegoUIKit.shared.getUser(userID)?.inRoomAttributes["avatar"] as? String
            if delegate != nil {
                self.getMaskView()
            }
        }
    }
    
    var streamIsAvailable: Bool = false {
        didSet {
            self.videoView.isHidden = !streamIsAvailable
        }
    }
    
    public var roomID: String?
    
    var avatarUrl: String? {
        didSet {
            guard let avatarUrl = avatarUrl else { return }
            self.headView.setHeadImageUrl(avatarUrl)
        }
    }
    
    public var audioViewBackgroundImage: UIImage? {
        didSet {
            guard let audioViewBackgroundImage = audioViewBackgroundImage else {
                backgroundImageView.isHidden = true
                return
            }
            backgroundImageView.isHidden = false
            backgroundImageView.image = audioViewBackgroundImage
        }
    }
    
    public var showVoiceWave: Bool?
    
    public var soundWaveColor: UIColor = UIColor.colorWithHexString("#DBDDE3") {
        didSet {
            self.setupLayout()
        }
    }
    
    public var videoFillMode: ZegoUIKitVideoFillMode = .aspectFill {
        didSet {
            guard let userID = self.userID else { return }
            if userID == ZegoUIKit.shared.localUserInfo?.userID {
                ZegoUIKit.shared.setLocalVideoView(renderView: self.videoView, videoMode: self.videoFillMode)
            } else {
                ZegoUIKit.shared.setRemoteVideoView(userID: userID, renderView: self.videoView, videoMode: self.videoFillMode)
            }
        }
    }
    
    public var avatarAlignment: ZegoAvatarAlignment = .center {
        didSet {
            self.setupLayout()
        }
    }
    
    lazy var headView: ZegoAudioVideoHeadView = {
        let view = ZegoAudioVideoHeadView()
        view.isHidden = true
        return view
    }()
    
    
    fileprivate var wave: CALayer?
    
    fileprivate lazy var videoView: UIView = {
        let view: UIView = UIView()
        return view
    }()
    fileprivate var animationLayer: CAShapeLayer?
    fileprivate var animationGroup: CAAnimationGroup?
    fileprivate let radarAnimation = "radarAnimation"
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private var customMaskView: UIView?
    private var userInfo: ZegoUIKitUser? {
        get {
            for user in ZegoUIKit.shared.userList {
                if user.userID == self.userID {
                    return user
                }
            }
            return nil
        }
    }
    
    public var avatarSize: CGSize? {
        didSet {
            guard let _ = avatarSize else { return }
            self.setupLayout()
        }
    }
    
    private let help: AudioVideoView_Help = AudioVideoView_Help()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.help.audioVideoView = self
        ZegoUIKit.shared.addEventHandler(self.help)
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.headView)
        self.addSubview(self.videoView)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.help.audioVideoView = self
        ZegoUIKit.shared.addEventHandler(self.help)
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.headView)
        self.addSubview(self.videoView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayout()
    }
    
    func setupLayout() {
        self.animationLayer?.removeFromSuperlayer()
        self.backgroundImageView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        
        var headY: CGFloat = 0
        if let avatarSize = avatarSize {
            if self.avatarAlignment == .start {
                headY = 0
            } else if self.avatarAlignment == .center {
                headY = (self.bounds.size.height - avatarSize.height) * 0.5
            } else if self.avatarAlignment == .end {
                headY = self.bounds.size.height - avatarSize.height
            }

            self.headView.frame = CGRect(x: (self.frame.size.width - avatarSize.width) / 2, y: headY, width: avatarSize.width, height: avatarSize.height)
        } else {
            let headW: CGFloat = 0.4 * self.frame.size.width
            let headH: CGFloat = 0.4 * self.frame.size.width
            if self.avatarAlignment == .start {
                headY = 0
            } else if self.avatarAlignment == .center {
                headY = (self.bounds.size.height - headH) * 0.5
            } else if self.avatarAlignment == .end {
                headY = self.bounds.size.height - headH
            }

            self.headView.frame = CGRect(x: (self.frame.size.width - headW) / 2, y: headY, width: headW, height: headH)
        }
        var fontSize: CGFloat = 23 * (375 / UIKitScreenWidth)
        if fontSize < 23{
            fontSize = 23
        } else if fontSize > 34 {
            fontSize = 34
        }
        
        self.headView.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        
        self.wave = self.makeRadarAnimation(showRect: self.headView.frame, isRound: true)
        self.layer.insertSublayer(self.wave ?? CALayer(), below: self.headView.layer)

        self.animationLayer?.frame = self.headView.frame
        self.animationLayer?.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.headView.frame.width, height: self.headView.frame.height)).cgPath
        
        self.setVideoViewFrame()
        
        self.customMaskView?.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        
        self.headView.layer.masksToBounds = true
        self.headView.layer.cornerRadius = self.headView.bounds.size.width / 2
    }
    
    func setVideoViewFrame() {
        let lastFrame = self.videoView.frame
        self.videoView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        if let userID = userID,
           videoView.frame.size.width > 0,
           videoView.frame.size.height > 0,
           lastFrame != self.videoView.frame
        {
            if userID == ZegoUIKit.shared.localUserInfo?.userID {
                ZegoUIKit.shared.setLocalVideoView(renderView: self.videoView, videoMode: self.videoFillMode)
            } else {
                ZegoUIKit.shared.setRemoteVideoView(userID: userID, renderView: self.videoView, videoMode: self.videoFillMode)
            }
        }
    }
    
    fileprivate func setHeadUserName(_ userID: String) {
        if let userName = ZegoUIKit.shared.getUser(userID)?.userName {
            self.headView.text = userName
        }
    }
    
    fileprivate func getMaskView() {
        self.customMaskView?.removeFromSuperview()
        self.customMaskView = self.delegate?.getForegroundView(userInfo)
        if let customMaskView = self.customMaskView {
            self.addSubview(customMaskView)
        }
    }
    
    
    fileprivate func makeRadarAnimation(showRect: CGRect, isRound: Bool) -> CALayer {
        // 1. 一个动态波
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = showRect
        // showRect 最大内切圆
        if isRound {
            shapeLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: showRect.width, height: showRect.height)).cgPath
        } else {
            // 矩形
            shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: showRect.width, height: showRect.height), cornerRadius: 10).cgPath
        }
        shapeLayer.fillColor = self.soundWaveColor.cgColor
        // 默认初始颜色透明度
        shapeLayer.opacity = 0.0
        self.animationLayer = shapeLayer

        // 2. 需要重复的动态波，即创建副本
        let replicator = CAReplicatorLayer()
        replicator.frame = shapeLayer.bounds
        replicator.instanceCount = 4
        replicator.instanceDelay = 1.0
        replicator.addSublayer(shapeLayer)

        // 3. 创建动画组
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = NSNumber(floatLiteral: 1.0)  // 开始透明度
        opacityAnimation.toValue = NSNumber(floatLiteral: 0)      // 结束时透明底

        let scaleAnimation = CABasicAnimation(keyPath: "transform")
        if isRound {
            scaleAnimation.fromValue = NSValue.init(caTransform3D: CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 0))      // 缩放起始大小
        } else {
            scaleAnimation.fromValue = NSValue.init(caTransform3D: CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 0))      // 缩放起始大小
        }
        scaleAnimation.toValue = NSValue.init(caTransform3D: CATransform3DScale(CATransform3DIdentity, 1.5, 1.5, 0))      // 缩放结束大小

        let animaGroup = CAAnimationGroup()
        animaGroup.animations = [opacityAnimation, scaleAnimation]
        animaGroup.duration = 2.0       // 动画执行时间
        animaGroup.repeatCount = HUGE   // 最大重复
        animaGroup.autoreverses = false
        self.animationGroup = animaGroup

        return replicator
    }
}

fileprivate class AudioVideoView_Help: NSObject, ZegoUIKitEventHandle {
    
    weak var audioVideoView: ZegoAudioVideoView?
    var isWave: Bool = false

    func onRemoteUserJoin(_ userList: [ZegoUIKitUser]) {
        for user in userList {
            if user.userID == audioVideoView?.userID {
                audioVideoView?.setHeadUserName(user.userID ?? "")
                if let _ = audioVideoView?.delegate {
                    audioVideoView?.getMaskView()
                }
                break
            }
        }
    }
    
    func onAudioVideoUnavailable(_ userList: [ZegoUIKitUser]) {
        for user in userList {
            if self.audioVideoView?.userID != nil && self.audioVideoView?.userID == user.userID {
                self.audioVideoView?.videoView.isHidden = true
                self.audioVideoView?.headView.isHidden = false
            }
        }
    }
    
    func onCameraOn(_ user: ZegoUIKitUser, isOn: Bool) {
        guard let audioVideoView = audioVideoView else {
            return
        }
        if audioVideoView.userID != nil && audioVideoView.userID == user.userID {
            if !isOn {
                audioVideoView.videoView.isHidden = true
                audioVideoView.headView.isHidden = false
                audioVideoView.headView.layer.masksToBounds = true
                audioVideoView.headView.layer.cornerRadius = audioVideoView.headView.frame.size.width / 2
            } else {
                audioVideoView.videoView.isHidden = false
                audioVideoView.headView.isHidden = true
            }
        }
    }
    
    func onMicrophoneOn(_ user: ZegoUIKitUser, isOn: Bool) {
        if self.audioVideoView?.userID != nil && self.audioVideoView?.userID == user.userID {
            guard let audioVideoView = self.audioVideoView else { return }
            if !isOn {
                audioVideoView.animationLayer?.removeAnimation(forKey: audioVideoView.radarAnimation)
                self.isWave = false
            }
        }
    }
    
    func onSoundLevelUpdate(_ userInfo: ZegoUIKitUser, level: Double) {
        if userInfo.userID == self.audioVideoView?.userID {
            guard let audioVideoView = audioVideoView
            else {
                return
            }
            if level > 5 {
                guard let userID = userInfo.userID else { return }
                if !self.isWave && (audioVideoView.showVoiceWave ?? true) && !ZegoUIKit.shared.isCameraOn(userID) {
                    guard let animationGroup = audioVideoView.animationGroup else { return }
                    audioVideoView.animationLayer?.add(animationGroup, forKey: audioVideoView.radarAnimation)
                    self.isWave = true
                }
            } else {
                if isWave {
                    audioVideoView.animationLayer?.removeAnimation(forKey: audioVideoView.radarAnimation)
                    isWave = false
                }
            }
        }
    }
    
    func onUsersInRoomAttributesUpdated(_ updateKeys: [String]?, oldAttributes: [ZegoUserInRoomAttributesInfo]?, attributes: [ZegoUserInRoomAttributesInfo]?, editor: ZegoUIKitUser?) {
        guard let attributes = attributes else { return }
        for  attribute in attributes {
            if attribute.userID == self.audioVideoView?.userID {
                if let avatarUrl = attribute.attributes["avatar"] {
                    self.audioVideoView?.avatarUrl = avatarUrl
                }
            }
        }
    }

}

