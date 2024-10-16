//
//  ZegoPipLayoutView.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/9/8.
//

import UIKit

protocol ZegoPipLayoutViewDelegate: AnyObject {
    func getForegroundView(_ userInfo: ZegoUIKitUser?) -> ZegoBaseAudioVideoForegroundView?
    func sortAudioVideo(_ userList: [ZegoUIKitUser]) -> [ZegoUIKitUser]?
}

extension ZegoPipLayoutViewDelegate {
    func sortAudioVideo(_ userList: [ZegoUIKitUser]) -> [ZegoUIKitUser]? { return userList }
}

class ZegoPipLayoutView: UIView {
    
    weak var delegate: ZegoPipLayoutViewDelegate?
    
    var config: ZegoLayoutPictureInPictureConfig = ZegoLayoutPictureInPictureConfig()
    var audioVideoConfig: ZegoAudioVideoViewConfig = ZegoAudioVideoViewConfig()
    var showSelfViewWithVideoOnly: Bool = false
    var videoList: [ZegoAudioVideoView]!
    var globalAudioVideoUserList: [ZegoUIKitUser]!
    
    private let limitMargin: CGFloat = 12.0
    private let topPadding: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
    private let bottomPadding: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    
    fileprivate let help: ZegoPipLayoutView_Help = ZegoPipLayoutView_Help()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.videoList = []
        self.globalAudioVideoUserList = []
        ZegoUIKit.shared.addEventHandler(self.help)
        self.help.pipView = self
        self.help.onAudioVideoAvailable(ZegoUIKit.shared.getStreamUserList())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateLayout()
    }
    
    private func updateLayout() {
        var index = 0
        for audioVideoView in self.videoList {
            self.layoutAudioVideoView(index, viewNum: self.videoList.count, audioVideoView: audioVideoView)
            index = index + 1
        }
    }
    
    func pInPLayout(_ config: ZegoLayoutConfig, audioVideoConfig: ZegoAudioVideoViewConfig) {
        if config is ZegoLayoutPictureInPictureConfig {
            let pInPConfig = config as! ZegoLayoutPictureInPictureConfig
            self.config = pInPConfig
            self.audioVideoConfig = audioVideoConfig
        }
    }
    
    func reload() {
        self.updateAudioVideoView()
    }
    
    @objc func tapClick(gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        self.exchangeBigViewWithSmallView(view.tag)
    }
    
    @objc func dragViewDidDrag(gesture: UIPanGestureRecognizer) {
        guard let smallVideoView = gesture.view else {
            return
        }
        // 移动状态
        let moveState = gesture.state
        switch moveState {
        case .changed:
            // 移动过程中,获取移动轨迹,重置center坐标点
            let point = gesture.translation(in: smallVideoView.superview)
            smallVideoView.center = CGPoint(x: smallVideoView.center.x + point.x, y: smallVideoView.center.y + point.y)
            break
        case .ended:
            // 移动结束后,相关逻辑处理,重置center坐标点
            let point = gesture.translation(in: smallVideoView.superview)
            let newPoint = CGPoint(x: smallVideoView.center.x + point.x, y: smallVideoView.center.y + point.y)
            
            // 自动吸边动画
            UIView.animate(withDuration: 0.1) {
                smallVideoView.center = self.resetPosition(point: newPoint, smallVideoView: smallVideoView)
            }
            break
        default: break
        }
        // 重置 panGesture
        gesture.setTranslation(.zero, in: smallVideoView.superview!)

    }
    
    func exchangeBigViewWithSmallView(_ smallViewIndex: Int) {
        if self.globalAudioVideoUserList.count <= smallViewIndex,
           smallViewIndex == 0
        { return }
        self.swapAudioVideoView(smallViewIndex)
        self.createOrUpdateAudioVideoView()
    }
    
    func swapAudioVideoView(_ index: Int) {
        var tempUserList: [ZegoUIKitUser] = []
        var currentIndex = 0
        var firstUser: ZegoUIKitUser?
        var selectUser: ZegoUIKitUser?
        for user in self.globalAudioVideoUserList {
            if currentIndex == 0 {
                firstUser = self.globalAudioVideoUserList[0]
            } else if currentIndex == index {
                selectUser = self.globalAudioVideoUserList[index]
            } else {
                tempUserList.append(user)
            }
            currentIndex = currentIndex + 1
        }
        guard let firstUser = firstUser,
              let selectUser = selectUser
        else {
            return
        }
        if tempUserList.count > 0 {
            tempUserList.insert(selectUser, at: 0)
        } else {
            tempUserList.append(selectUser)
        }
        if tempUserList.count > index {
            tempUserList.insert(firstUser, at: index)
        } else {
            tempUserList.append(firstUser)
        }
        self.globalAudioVideoUserList = tempUserList
    }
    
    // MARK: - 更新中心点位置
    private func resetPosition(point: CGPoint, smallVideoView: UIView) -> CGPoint {
        var newPoint = point
        // 靠左吸边
        if point.x <= smallVideoView.superview!.frame.size.width / 2 {
            // x轴偏右移2个单位(预留可点击区域)
            if point.x <= smallVideoView.frame.size.width / 2 {
                newPoint.x = (smallVideoView.frame.size.width / 2) + limitMargin
            }
            // y轴偏下移10个单位(预留可点击区域)
            if point.y <= topPadding + 20 {
                newPoint.y = topPadding + 80
            }
            // y轴偏上移10个单位(预留可点击区域)
            if point.y >= smallVideoView.superview!.frame.height - (smallVideoView.frame.height / 2) - bottomPadding - 20 {
                newPoint.y = smallVideoView.superview!.frame.height - (smallVideoView.frame.height / 2) - bottomPadding - 60
            }
            return newPoint
        } else {
            // x轴偏左移2个单位(预留可点击区域)
            if point.x >= (smallVideoView.superview!.frame.width / 2) {
                newPoint.x = smallVideoView.superview!.frame.width - (smallVideoView.frame.size.width / 2) - 12
            }
            // y轴偏下移10个单位(预留可点击区域)
            if point.y < topPadding + 20 {
                newPoint.y = topPadding + 80
            }
            // y轴偏上移10个单位(预留可点击区域)
            if point.y >= smallVideoView.superview!.frame.height - (smallVideoView.frame.height / 2) - bottomPadding - 20 {
                newPoint.y = smallVideoView.superview!.frame.height - (smallVideoView.frame.height / 2) - bottomPadding - 60
            }
            return newPoint
        }
    }
    
    fileprivate func updateAudioVideoView() {
        if let delegate = delegate,
           let audioVideoUserList = delegate.sortAudioVideo(self.globalAudioVideoUserList)
        {
            self.globalAudioVideoUserList = audioVideoUserList
        }
        self.createOrUpdateAudioVideoView()
    }
    
    private func createOrUpdateAudioVideoView() {
        var index: Int = 0
        for user in globalAudioVideoUserList {
            if index > 3 {
                // most display 4 video view
                break
            }
            var audioVideoView: ZegoAudioVideoView!
            if index < self.videoList.count {
                audioVideoView = self.videoList[index]
                removeDeforeAddGesturer(audioVideoView)
            } else {
                audioVideoView = ZegoAudioVideoView()
                self.videoList.append(audioVideoView)
            }
            audioVideoView.userID = user.userID
            
            if audioVideoConfig.useVideoViewAspectFill && audioVideoView.videoFillMode != .aspectFill {
                audioVideoView.videoFillMode = .aspectFill
            } else if !audioVideoConfig.useVideoViewAspectFill && audioVideoView.videoFillMode != .aspectFit {
                audioVideoView.videoFillMode = .aspectFit
            }
            audioVideoView.avatarSize = audioVideoConfig.avatarSize
            audioVideoView.avatarAlignment = audioVideoConfig.avatarAlignment
            audioVideoView.delegate = self.help
            audioVideoView.showVoiceWave = audioVideoConfig.showSoundWavesInAudioMode
            audioVideoView.tag = index
            if index == 0 {
                //first is big view
                audioVideoView.backgroundColor = self.config.largeViewBackgroundColor
                audioVideoView.layer.masksToBounds = true
                audioVideoView.layer.cornerRadius = 0
                audioVideoView.layer.borderColor = UIColor.colorWithHexString("#A4A4A4").cgColor
                audioVideoView.layer.borderWidth = 0
                if (self.config.largeViewBackgroundImage != nil) {
                    audioVideoView.audioViewBackgroundImage = self.config.largeViewBackgroundImage
                }
            } else {
                // is small view
                audioVideoView.backgroundColor = self.config.smallViewBackgroundColor
                audioVideoView.layer.masksToBounds = true
                audioVideoView.layer.cornerRadius = 9.0
                audioVideoView.layer.borderColor = UIColor.colorWithHexString("#A4A4A4").cgColor
                audioVideoView.layer.borderWidth = 0.5
                if (self.config.smallViewBackgroundImage != nil) {
                    audioVideoView.audioViewBackgroundImage = self.config.smallViewBackgroundImage
                }
                if self.config.isSmallViewDraggable {
                    let dragGesture = UIPanGestureRecognizer(target: self, action:#selector(dragViewDidDrag(gesture:)))
                    audioVideoView.addGestureRecognizer(dragGesture)
                }
                if self.config.switchLargeOrSmallViewByClick {
                    let tapGesture = UITapGestureRecognizer(target: self, action:#selector(tapClick(gesture:)))
                    audioVideoView.addGestureRecognizer(tapGesture)
                }
            }
            self.layoutAudioVideoView(index, viewNum: (self.videoList.count) > 4 ? 4 : globalAudioVideoUserList.count,audioVideoView: audioVideoView)
            self.addSubview(audioVideoView)
            index = index + 1
        }
    }
    
    func removeDeforeAddGesturer(_ view: ZegoAudioVideoView) {
        let gestureArr: [UIGestureRecognizer]? = view.gestureRecognizers
        guard let gestureArr = gestureArr else { return }
        for gesture in gestureArr {
            if gesture.isKind(of: UITapGestureRecognizer.self) {
                view.removeGestureRecognizer(gesture)
            }
        }
    }
    
    func getOldAudioVideoView(_ user: ZegoUIKitUser) -> ZegoAudioVideoView? {
        var oldAudioVideoView: ZegoAudioVideoView?
        for audioVideoView in self.videoList {
            if audioVideoView.userID == user.userID {
                oldAudioVideoView = audioVideoView
                break
            }
        }
        return oldAudioVideoView
    }
    
    func layoutAudioVideoView(_ index: Int, viewNum: Int, audioVideoView: ZegoAudioVideoView) {
        if index == 0 {
            //big view
            audioVideoView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        } else {
            // small view
            let topMargin: CGFloat = 70
            let bottomMargin: CGFloat = 100
            let floadIndex: CGFloat = CGFloat(index)
            let floatViewNum: CGFloat = CGFloat(viewNum)
            switch self.config.smallViewPosition {
            case .topRight:
                let audioVideoViewY: CGFloat = topMargin + (self.config.smallViewSize.height * (floadIndex - 1)) + (self.config.spacingBetweenSmallViews * (floadIndex - 1))
                let audioVideoViewX: CGFloat = self.bounds.size.width - 12 - self.config.smallViewSize.width
                audioVideoView.frame = CGRect.init(x: audioVideoViewX, y: audioVideoViewY, width: self.config.smallViewSize.width, height: self.config.smallViewSize.height)
            case .topLeft:
                let audioVideoViewY: CGFloat = topMargin + (self.config.smallViewSize.height * (floadIndex - 1)) + (self.config.spacingBetweenSmallViews * (floadIndex - 1))
                audioVideoView.frame = CGRect.init(x: 12, y: audioVideoViewY, width: self.config.smallViewSize.width, height: self.config.smallViewSize.height)
            case .bottomLeft:
                let audioVideoViewY: CGFloat = self.bounds.size.height - (bottomMargin + (self.config.smallViewSize.height * (floadIndex + 1)) + (self.config.spacingBetweenSmallViews * floadIndex))
                audioVideoView.frame = CGRect.init(x: 12, y: audioVideoViewY, width: self.config.smallViewSize.width, height: self.config.smallViewSize.height)
            case .bottomRight:
                let audioVideoViewY: CGFloat = self.bounds.size.height - (bottomMargin + (self.config.smallViewSize.height * (floatViewNum - floadIndex)) + (self.config.spacingBetweenSmallViews * (floatViewNum - floadIndex - 1)))
                let audioVideoViewX: CGFloat = self.bounds.size.width - 12 - self.config.smallViewSize.width
                audioVideoView.frame = CGRect.init(x: audioVideoViewX, y: audioVideoViewY, width: self.config.smallViewSize.width, height: self.config.smallViewSize.height)
            }
        }
    }
    
    deinit {
        print("ZegoPipLayoutView deinit")
    }
}

class ZegoPipLayoutView_Help: NSObject,AudioVideoViewDelegate,ZegoUIKitEventHandle {
    weak var pipView: ZegoPipLayoutView?
    
    func getForegroundView(_ userInfo: ZegoUIKitUser?) -> ZegoBaseAudioVideoForegroundView? {
        return self.pipView?.delegate?.getForegroundView(userInfo)
    }
    
    func onAudioVideoAvailable(_ userList: [ZegoUIKitUser]) {
        guard let pipView = pipView else { return }
        var needUpdate: Bool = false
        for user in userList {
            let isExit: Bool = self.newAddAudioVideo(user)
            if !isExit {
                needUpdate = true
            }
        }
        if needUpdate {
            pipView.updateAudioVideoView()
        }
    }
    
    func onAudioVideoUnavailable(_ userList: [ZegoUIKitUser]) {
        guard let pipView = pipView else { return }
        if pipView.config.removeViewWhenAudioVideoUnavailable {
            for user in userList {
                self.removeAudioVideo(user)
            }
            pipView.updateAudioVideoView()
        }
    }
    
    func onRemoteUserLeave(_ userList: [ZegoUIKitUser]) {
        guard let pipView = pipView else { return }
        if !pipView.config.removeViewWhenAudioVideoUnavailable {
            for user in userList {
                self.removeAudioVideo(user)
            }
            pipView.updateAudioVideoView()
        }
    }
    
    private func getVideoView(_ userID: String) -> ZegoAudioVideoView? {
        guard let pipView = pipView else { return nil}
        for videoView in pipView.videoList {
            if videoView.userID == userID {
                return videoView
            }
        }
        return nil
    }
    
    private func newAddAudioVideo(_ user: ZegoUIKitUser) -> Bool {
        guard let pipView = pipView else { return false }
        var isExit: Bool = false
        for oldUser in pipView.globalAudioVideoUserList {
            if user.userID == oldUser.userID {
                isExit = true
                break
            }
        }
        if !isExit {
            pipView.globalAudioVideoUserList.append(user)
        }
        return isExit
    }
    
    private func removeAudioVideo(_ user: ZegoUIKitUser) {
        guard let pipView = pipView else { return }
        var index: Int = 0
        for oldUser in pipView.globalAudioVideoUserList {
            if user.userID == oldUser.userID {
                pipView.globalAudioVideoUserList.remove(at: index)
                self.removeAudioVideoView(user.userID)
                break
            }
            index = index + 1
        }
    }
    
    func removeAudioVideoView(_ userID: String?) {
        guard let pipView = pipView,
              let userID = userID
        else { return }
        var index: Int = 0
        for audioVideoView in pipView.videoList {
            if userID == audioVideoView.userID {
                audioVideoView.removeFromSuperview()
                pipView.videoList.remove(at: index)
            }
            index = index + 1
        }
    }
}
