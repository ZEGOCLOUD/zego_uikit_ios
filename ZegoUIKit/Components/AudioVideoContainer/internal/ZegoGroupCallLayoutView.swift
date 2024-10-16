//
//  ZegoGroupCallLayoutView.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/9/8.
//

import UIKit

protocol ZegoGroupCallLayoutViewDelegate: AnyObject {
    func getForegroundView(_ userInfo: ZegoUIKitUser?) -> ZegoBaseAudioVideoForegroundView?
}

class ZegoGroupCallLayoutView: UIView {
    
    weak var delegate: ZegoGroupCallLayoutViewDelegate?
    
    var config: ZegoLayoutGalleryConfig? {
        didSet {
            if let config = config,
               !config.addBorderRadiusAndSpacingBetweenView
            {
                self.itemSpace = 1
                self.margin = 0
            }
        }
    }
    var audioVideoViewConfig: ZegoAudioVideoViewConfig?
    
    var users: [ZegoUIKitUser] = []
    var screenSharingList: [ZegoUIKitUser] = []
    var userViewArray: [ZegoGroupCallUserView] = []
    
    var itemSpace: CGFloat = 5
    var margin: CGFloat = 5
    
    var fullScreenSharingView: ZegoScreenSharingView?
    
    lazy var userHeadView: ZegoGroupCallUserView = {
        let view: ZegoGroupCallUserView = ZegoGroupCallUserView()
        view.type = 1
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if let config = config,
           config.removeViewWhenAudioVideoUnavailable
        {
            users.append(contentsOf: ZegoUIKit.shared.getStreamUserList())
        } else {
            var index = 0
            for user in ZegoUIKit.shared.getAllUsers() {
                if index == 0  {
                    users.append(user)
                } else if index == 1 {
                    users.append(user)
                } else {
                    users.insert(user, at: 1)
                }
                index = index + 1
            }
        }
        screenSharingList.append(contentsOf: ZegoUIKit.shared.getScreenStreamList())
        ZegoUIKit.shared.addEventHandler(self)
        self.addSubview(self.userHeadView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateLayout()
        fullScreenSharingView?.zgu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    func fixedSideBySideLayout(_ config: ZegoLayoutConfig, audioVideoViewConfig: ZegoAudioVideoViewConfig) {
        if config is ZegoLayoutGalleryConfig {
            self.config = config as? ZegoLayoutGalleryConfig
            self.audioVideoViewConfig = audioVideoViewConfig
            self.updateLayout()
            self.normalFullScreenSharingView(screenSharingList.first?.userID ?? "")
        }
    }
    
    func updateLayout() {
        self.removeAllViewFromSuperView()
        var index = 0
        self.userHeadView.userList.removeAll()
        if let _ = fullScreenSharingView {
            return
        }
        for user in screenSharingList {
            if screenSharingList.count > 8 && index >= 7 {
                let itemFrame: CGRect = self.getItemFrame(7)
                self.userHeadView.userList.append(user)
                self.userHeadView.frame = itemFrame
                self.addBoardRadius(self.userHeadView)
                self.addSubview(self.userHeadView)
                self.userHeadView.updateUserView()
            } else if ((screenSharingList.count + users.count) == 1) {
                let itemFrame: CGRect = self.getItemFrame(index)
                if let view = self.findExistView(user.userID, type: 2) {
                    view.frame = itemFrame
                    view.delegate = self
                    view.userList.removeAll()
                    view.userList.append(user)
                    self.addSubview(view)
                    view.updateUserView()
                } else {
                    let newView: ZegoGroupCallUserView = ZegoGroupCallUserView()
                    newView.delegate = self
                    newView.frame = itemFrame
                    newView.type = 2
                    newView.screenSharingView.videoFillMode = .aspectFit
                    self.userViewArray.append(newView)
                    newView.userList.append(user)
                    self.addSubview(newView)
                    newView.updateUserView()
                }
            } else {
                let itemFrame: CGRect = self.getItemFrame(index)
                if let view = self.findExistView(user.userID, type: 2) {
                    view.frame = itemFrame
                    view.delegate = self
                    view.userList.removeAll()
                    view.userList.append(user)
                    self.addSubview(view)
                    view.updateUserView()
                    self.addBoardRadius(view)
                } else {
                    let newView: ZegoGroupCallUserView = ZegoGroupCallUserView()
                    newView.delegate = self
                    newView.frame = itemFrame
                    newView.type = 2
                    newView.screenSharingView.videoFillMode = .aspectFit
                    self.userViewArray.append(newView)
                    newView.userList.append(user)
                    self.addSubview(newView)
                    newView.updateUserView()
                    self.addBoardRadius(newView)
                }
            }
            index = index + 1
        }
        
        for user in self.users {
            if (self.users.count + screenSharingList.count) > 8 && index >= 7 {
                let itemFrame: CGRect = self.getItemFrame(7)
                self.userHeadView.userList.append(user)
                self.userHeadView.frame = itemFrame
                self.addBoardRadius(self.userHeadView)
                self.addSubview(self.userHeadView)
                self.userHeadView.updateUserView()
            } else if (self.users.count + screenSharingList.count) == 1 {
                let itemFrame: CGRect = self.getItemFrame(index)
                if let view = self.findExistView(user.userID, type: 0) {
                    view.frame = itemFrame
                    view.delegate = self
                    view.userList.removeAll()
                    view.userList.append(user)
                    self.addSubview(view)
                    view.updateUserView()
                } else {
                    let newView: ZegoGroupCallUserView = ZegoGroupCallUserView()
                    newView.delegate = self
                    newView.frame = itemFrame
                    newView.audioVideoView.showVoiceWave = self.audioVideoViewConfig?.showSoundWavesInAudioMode ?? true
                    if let useVideoViewAspectFill = self.audioVideoViewConfig?.useVideoViewAspectFill {
                        newView.audioVideoView.videoFillMode = useVideoViewAspectFill ? .aspectFill:.aspectFit
                    } else {
                        newView.audioVideoView.videoFillMode = .aspectFill
                    }
                    newView.audioVideoView.avatarAlignment = self.audioVideoViewConfig?.avatarAlignment ?? .center
                    newView.audioVideoView.avatarSize = self.audioVideoViewConfig?.avatarSize
                    self.userViewArray.append(newView)
                    newView.userList.append(user)
                    self.addSubview(newView)
                    newView.updateUserView()
                }
            } else {
                let itemFrame: CGRect = self.getItemFrame(index)
                if let view = self.findExistView(user.userID, type: 0) {
                    view.frame = itemFrame
                    view.delegate = self
                    view.userList.removeAll()
                    view.userList.append(user)
                    self.addSubview(view)
                    view.updateUserView()
                    self.addBoardRadius(view)
                } else {
                    let newView: ZegoGroupCallUserView = ZegoGroupCallUserView()
                    newView.delegate = self
                    newView.frame = itemFrame
                    newView.audioVideoView.showVoiceWave = self.audioVideoViewConfig?.showSoundWavesInAudioMode ?? true
                    if let useVideoViewAspectFill = self.audioVideoViewConfig?.useVideoViewAspectFill {
                        newView.audioVideoView.videoFillMode = useVideoViewAspectFill ? .aspectFill:.aspectFit
                    } else {
                        newView.audioVideoView.videoFillMode = .aspectFill
                    }
                    newView.audioVideoView.avatarAlignment = self.audioVideoViewConfig?.avatarAlignment ?? .center
                    newView.audioVideoView.avatarSize = self.audioVideoViewConfig?.avatarSize
                    self.userViewArray.append(newView)
                    newView.userList.append(user)
                    self.addSubview(newView)
                    newView.updateUserView()
                    self.addBoardRadius(newView)
                }
            }
            index = index + 1
        }
        if let fullScreenSharingView = fullScreenSharingView {
            self.bringSubviewToFront(fullScreenSharingView)
        }
    }
    
    private func getItemFrame(_ index: Int) -> CGRect {
        let line: Int = index / 2
        var lineNum: Double = ceil(CGFloat(Double(screenSharingList.count + self.users.count) * 0.5))
        if lineNum > 4 {
            lineNum = 4
        }
        if (screenSharingList.count + self.users.count) == 1 {
            return CGRect(x: margin, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        } else if (self.users.count + screenSharingList.count) == 2 {
            let isFirst: Int = (index % 2)
            let itemWidth: CGFloat = self.frame.size.width - (margin * 2)
            let itemHeight: CGFloat = (self.frame.size.height - margin) * 0.5
            let orignY: CGFloat = (margin * CGFloat(isFirst)) + (itemHeight * CGFloat(isFirst))
            return CGRect(x: margin, y: orignY, width: itemWidth, height: itemHeight)
        } else {
            let isFirst: Int = (index % 2)
            let itemWidth: CGFloat = (self.frame.size.width - (margin * 2)) * 0.5 - itemSpace
            let itemHeight: CGFloat = (self.frame.size.height - (itemSpace * CGFloat((line)))) / CGFloat(lineNum)
            let orignX: CGFloat = margin + (CGFloat(isFirst) * itemWidth) + CGFloat(itemSpace * CGFloat(isFirst))
            let orignY: CGFloat = (itemSpace * CGFloat(line)) + (itemHeight * CGFloat(line))
            return CGRect(x: orignX, y: orignY, width: itemWidth, height: itemHeight)
        }
    }
    
    private func addBoardRadius(_ view: UIView) {
        if let config = config,
           config.addBorderRadiusAndSpacingBetweenView
        {
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 6
        }
    }
    
    func removeAllViewFromSuperView() {
        for view in self.userViewArray {
            view.removeFromSuperview()
        }
        self.userHeadView.removeFromSuperview()
    }
    
    func findExistView(_ userID: String?, type: UInt) -> ZegoGroupCallUserView? {
        guard let userID = userID else { return nil }
        for view in self.userViewArray {
            let user = view.userList.first
            if user?.userID == userID && view.type == type {
                return view
            }
        }
        return nil
    }
    
    func normalFullScreenSharingView(_ userID: String = "") {
        if config?.showNewScreenSharingViewInFullscreenMode ?? true {
            if (fullScreenSharingView == nil &&  userID.count > 0) {
                fullScreenSharingView = ZegoScreenSharingView()
                fullScreenSharingView?.userID = userID
                fullScreenSharingView?.delegate = self
                self.addSubview(fullScreenSharingView!)
                self.bringSubviewToFront(fullScreenSharingView!)
            }
        }
    }
    
}

extension ZegoGroupCallLayoutView: ZegoUIKitEventHandle, ZegoGroupCallUserViewDelegate, ZegoScreenSharingViewDelegate, ZegoScreenSharingForegroundViewDelegate {
    
//    func onRemoteUserJoin(_ userList: [ZegoUIKitUser]) {
//        for user in userList {
//            self.users.insert(user, at: 1)
//        }
//        self.updateLayout()
//    }
//
//    func onRemoteUserLeave(_ userList: [ZegoUIKitUser]) {
//        for user in userList {
//            self.users = self.users.filter{$0.userID != user.userID}
//        }
//        self.updateLayout()
//    }
    
    func onUserCountOrPropertyChanged(_ userList: [ZegoUIKitUser]?) {
        if let config = config,
           config.removeViewWhenAudioVideoUnavailable
        {
            return
        }
        guard let userList = userList else {
            return
        }
        userListUpdate(userList)
    }
    
    
    func onAudioVideoAvailable(_ userList: [ZegoUIKitUser]) {
        if (config?.removeViewWhenAudioVideoUnavailable ?? false) {
            userStreamListUpdate(userList, isAdd: true)
        }
    }
    
    func onAudioVideoUnavailable(_ userList: [ZegoUIKitUser]) {
        if (config?.removeViewWhenAudioVideoUnavailable ?? false) {
            userStreamListUpdate(userList, isAdd: false)
        }
    }
    
    func onScreenSharingAvailable(_ userList: [ZegoUIKitUser]) {
        if screenSharingList.count > 0 {
            screenSharingList.insert(contentsOf: userList, at: 0)
        } else {
            screenSharingList.append(contentsOf: userList)
        }
        self.normalFullScreenSharingView(userList.first?.userID ?? "")
        self.updateLayout()
    }
    
    func onScreenSharingUnavailable(_ userList: [ZegoUIKitUser]) {
        for user in userList {
            screenSharingList.removeAll(where: {
                $0.userID == user.userID
            })
        }
        self.updateLayout()
    }
    
    private func userListUpdate(_ userList: [ZegoUIKitUser]) {
        var newUserList: [ZegoUIKitUser] = []
        var index: Int = 0
        for user in userList {
            if index == 0 {
                newUserList.append(user)
            } else {
                if user.userID == ZegoUIKit.shared.localUserInfo?.userID {
                    newUserList.insert(user, at: 0)
                } else {
                    newUserList.insert(user, at: 1)
                }
            }
            index = index + 1
        }
        if !self.isSameUserList(newUserList) {
            self.users.removeAll()
            self.users.append(contentsOf: newUserList)
            // user change
            self.updateLayout()
        }
    }
    
    private func userStreamListUpdate(_ userList: [ZegoUIKitUser], isAdd: Bool) {
        if isAdd {
            for user in userList {
                if self.users.contains(where: {$0.userID == user.userID}) {
                    break
                }
                if self.users.count > 0 {
                    if user.userID == ZegoUIKit.shared.localUserInfo?.userID {
                        self.users.insert(user, at: 0)
                    } else {
                        self.users.insert(user, at: 1)
                    }
                } else {
                    self.users.append(user)
                }
            }
        } else {
            for user in userList {
                self.users.removeAll(where: {
                    $0.userID == user.userID
                })
            }
        }
        self.updateLayout()
        
    }
    
    
    func isSameUserList(_ userList: [ZegoUIKitUser]) -> Bool {
        var isSame: Bool = true
        if userList.count == self.users.count {
            var index: Int = 0
            for user in self.users {
                let oldUser: ZegoUIKitUser = self.users[index]
                if user.userID != oldUser.userID {
                    isSame = false
                    break
                }
                index = index + 1
            }
        } else {
            isSame = false
        }
        return isSame
    }
    
    func getForegroundView(_ userInfo: ZegoUIKitUser?) -> ZegoBaseAudioVideoForegroundView? {
        return self.delegate?.getForegroundView(userInfo)
    }
    
    func fullScreenClick(_ userID: String) {
        if let fullScreenSharingView = fullScreenSharingView,
           fullScreenSharingView.userID == userID
        {
            fullScreenSharingView.removeFromSuperview()
            self.fullScreenSharingView = nil
        } else {
            fullScreenSharingView?.removeFromSuperview()
            fullScreenSharingView = ZegoScreenSharingView()
            fullScreenSharingView?.userID = userID
            fullScreenSharingView?.delegate = self
            self.addSubview(fullScreenSharingView!)
        }
    }
    
    func getScreenShareForegroundView(_ userInfo: ZegoUIKitUser?) -> UIView? {
        let view: ZegoScreenSharingForegroundView = ZegoScreenSharingForegroundView()
        if let userInfo = userInfo,
           let userID = userInfo.userID
        {
            view.userID = userID
        }
        view.isFullScreen = true
        view.delegate = self
        return view
    }
    
    @objc func unfullScreenClick() {
        fullScreenSharingView?.removeFromSuperview()
        fullScreenSharingView = nil
        updateLayout()
    }
    
    func onScreenSharingForegroundViewButtonClick(userID: String) {
        fullScreenSharingView?.removeFromSuperview()
        fullScreenSharingView = nil
        updateLayout()
    }
}

protocol ZegoGroupCallUserViewDelegate: AnyObject {
    func getForegroundView(_ userInfo: ZegoUIKitUser?) -> ZegoBaseAudioVideoForegroundView?
    func fullScreenClick(_ userID: String)
}

class ZegoGroupCallUserView: UIView {
    
    var type: UInt = 0 {
        didSet {
            if type == 1 {
                self.audioVideoView.isHidden = true
                self.screenSharingView.isHidden = true
                self.userHeadView.isHidden = false
            } else if type == 2 {
                self.audioVideoView.isHidden = true
                self.screenSharingView.isHidden = false
                self.userHeadView.isHidden = true
            } else {
                self.audioVideoView.isHidden = false
                self.screenSharingView.isHidden = true
                self.userHeadView.isHidden = true
            }
        }
    }
    weak var delegate: ZegoGroupCallUserViewDelegate?
    
    var userList: [ZegoUIKitUser] = []
    
    lazy var screenSharingView: ZegoScreenSharingView = {
        let view = ZegoScreenSharingView()
        view.backgroundColor = UIColor.colorWithHexString("#333437")
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    lazy var audioVideoView: ZegoAudioVideoView = {
        let view = ZegoAudioVideoView()
        view.backgroundColor = UIColor.colorWithHexString("#333437")
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    lazy var userHeadView: ZegoGroupCallUserHeadView = {
        let view = ZegoGroupCallUserHeadView()
        view.backgroundColor = UIColor.colorWithHexString("#333437")
        view.isHidden = true
        return view
    }()
    
    var fullScreenButton: UIButton?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.userHeadView)
        self.addSubview(self.audioVideoView)
        self.addSubview(self.screenSharingView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayout()
    }
    
    func updateUserView() {
        if self.type == 0 {
            self.audioVideoView.isHidden = false
            self.audioVideoView.userID = userList.first?.userID
        } else if type == 1 {
            self.userHeadView.isHidden = false
            self.userHeadView.userList = self.userList
            self.userHeadView.updateView()
        } else if type == 2 {
            if let userInfo = userList.first,
               let userID = userInfo.userID
            {
                fullScreenButton?.tag = Int(userID) ?? 0
            }
            self.screenSharingView.isHidden = false
            self.screenSharingView.userID = userList.first?.userID
        }
    }
    
    func setupLayout() {
        self.audioVideoView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.userHeadView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.screenSharingView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
}

extension ZegoGroupCallUserView: AudioVideoViewDelegate, ZegoScreenSharingViewDelegate, ZegoScreenSharingForegroundViewDelegate {
    func getForegroundView(_ userInfo: ZegoUIKitUser?) -> ZegoBaseAudioVideoForegroundView? {
        return self.delegate?.getForegroundView(userInfo)
    }
    
    func getScreenShareForegroundView(_ userInfo: ZegoUIKitUser?) -> UIView? {
        let view: ZegoScreenSharingForegroundView = ZegoScreenSharingForegroundView()
        if let userInfo = userInfo,
           let userID = userInfo.userID
        {
            view.userID = userID
        }
        view.isFullScreen = false
        view.delegate = self
        return view
    }
    
    @objc func fullScreenClick(_ sender: UIButton) {
        delegate?.fullScreenClick("\(sender.tag)")
    }
    
    func onScreenSharingForegroundViewButtonClick(userID: String) {
        delegate?.fullScreenClick(userID)
    }
}

class ZegoGroupCallUserHeadView: UIView {
    
    var userList: [ZegoUIKitUser] = []
    
    lazy var firstUserHead: UILabel = {
        let userHead = UILabel()
        userHead.textAlignment = .center
        userHead.textColor = UIColor.colorWithHexString("#222222")
        userHead.backgroundColor = UIColor.colorWithHexString("#DBDDE3")
        userHead.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        userHead.layer.masksToBounds = true
        return userHead
    }()
    
    lazy var secondUserHead: UILabel = {
        let userHead = UILabel()
        userHead.textAlignment = .center
        userHead.textColor = UIColor.colorWithHexString("#222222")
        userHead.backgroundColor = UIColor.colorWithHexString("#DBDDE3")
        userHead.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        userHead.layer.masksToBounds = true
        return userHead
    }()
    
    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.colorWithHexString("#FFFFFF")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.firstUserHead)
        self.addSubview(self.secondUserHead)
        self.addSubview(self.numberLabel)
        self.updateView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayout()
    }
    
    func setupLayout() {
        if self.bounds.size.width > 0 {
            let width = self.frame.size.width / 3
            let height = width
            self.firstUserHead.layer.cornerRadius = width * 0.5
            self.secondUserHead.layer.cornerRadius = width * 0.5
            let originX: CGFloat = (self.frame.size.width - ((width * 2) - 14)) * 0.5
            let originY: CGFloat = (self.frame.size.height - height - 8 - 20) * 0.5
            self.firstUserHead.frame = CGRect(x: originX, y: originY, width: width, height: height)
            self.secondUserHead.frame = CGRect(x: self.firstUserHead.frame.maxX - 14, y: originY, width: width, height: height)
            self.numberLabel.frame = CGRect(x: 10, y: self.firstUserHead.frame.maxY + 8, width: self.frame.size.width - 20, height: 17)
        }
    }
    
    func updateView() {
        var index: Int = 0
        for user in userList {
            guard let userName = user.userName else {
                index = index + 1
                continue
            }
            let firstStr: String = String(userName[userName.startIndex])
            if index == 0 {
                self.firstUserHead.text = firstStr
                index = index + 1
            } else if index == 1 {
                self.secondUserHead.text = firstStr
                break
            }
        }
        self.numberLabel.text = String(format: ZegoUIKitTranslationTextConfig.shared.translationText.morePersonLiveOtherTitle, self.userList.count)
    }
}

protocol ZegoScreenSharingForegroundViewDelegate: AnyObject {
    func onScreenSharingForegroundViewButtonClick(userID: String)
}

class ZegoScreenSharingForegroundView: UIView {
    
    var userID: String?
    var isFullScreen: Bool = false {
        didSet {
            if isFullScreen {
                fullScreenButton.setImage(ZegoUIIconSet.iconFullScreenSelect, for: .normal)
            } else {
                fullScreenButton.setImage(ZegoUIIconSet.iconFullScreenNomal, for: .normal)
            }
        }
    }
    
    lazy var fullScreenButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(ZegoUIIconSet.iconFullScreenNomal, for: .normal)
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: ZegoScreenSharingForegroundViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(fullScreenButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fullScreenButton.zgu_constraint(equalTo: self,right: 20, top: 80)
        fullScreenButton.zgu_constraint(width: 40, height: 40)
    }
    
    @objc func buttonClick() {
        if let userID = userID {
            delegate?.onScreenSharingForegroundViewButtonClick(userID: userID)
        }
    }
    
}
