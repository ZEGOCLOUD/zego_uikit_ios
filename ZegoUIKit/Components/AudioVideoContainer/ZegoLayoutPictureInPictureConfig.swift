//
//  ZegoPitctureInPictureLayoutConfig.swift
//  ZegoUIKit
//
//  Created by zego on 2022/7/29.
//

import UIKit

public class ZegoLayoutPictureInPictureConfig: ZegoLayoutConfig {
    public var isSmallViewDraggable: Bool = false
    public var smallViewBackgroundColor: UIColor = UIColor.colorWithHexString("#333437")
    public var largeViewBackgroundColor: UIColor = UIColor.colorWithHexString("#4A4B4D")
    public var smallViewBackgroundImage: UIImage?
    public var largeViewBackgroundImage: UIImage?
    public var smallViewPostion: ZegoViewPosition = .topRight
    public var switchLargeOrSmallViewByClick: Bool = true
    public var smallViewSize: CGSize = CGSize(width: 95, height: 169)
    public var spacingBetweenSmallViews: CGFloat = 0
    public var removeViewWhenAudioVideoUnavailable: Bool = true
}
