//
//  ZegoScreenSharingView.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2023/3/23.
//

import UIKit

public protocol ZegoScreenSharingViewDelegate: AnyObject {
    func getScreenShareForegroundView(_ userInfo: ZegoUIKitUser?) -> UIView?
}

extension ZegoScreenSharingViewDelegate {
    func getScreenShareForegroundView(_ userInfo: ZegoUIKitUser?) -> UIView? { return nil }
}

public class ZegoScreenSharingView: UIView {
    
    public weak var delegate: ZegoScreenSharingViewDelegate? {
        didSet {
            if delegate != nil {
                self.getMaskView()
            }
        }
    }

    public var userID: String? {
        didSet {
            if let userID = userID {
                ZegoUIKit.shared.setRemoteScreenShareView(userID: userID, renderView: videoView)
                if delegate != nil {
                    self.getMaskView()
                }
            }
        }
    }
    
    public var videoFillMode: ZegoUIKitVideoFillMode = .aspectFit {
        didSet {
            guard let userID = self.userID else { return }
            if userID != ZegoUIKit.shared.localUserInfo?.userID {
                ZegoUIKit.shared.setRemoteScreenShareView(userID: userID, renderView: videoView, videoMode: videoFillMode)
            }
        }
    }
    
    private var customMaskView: UIView?
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    fileprivate lazy var videoView: UIView = {
        let view: UIView = UIView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.videoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        self.backgroundImageView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.videoView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.customMaskView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    fileprivate func getMaskView() {
        self.customMaskView?.removeFromSuperview()
        self.customMaskView = self.delegate?.getScreenShareForegroundView(ZegoUIKit.shared.getUser(userID ?? ""))
        if let customMaskView = self.customMaskView {
            self.addSubview(customMaskView)
        }
    }

}
