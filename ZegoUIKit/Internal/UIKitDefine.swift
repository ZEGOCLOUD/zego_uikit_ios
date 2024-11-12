//
//  UIKitDefine.swift
//  ZegoUIKit
//
//  Created by zego on 2022/9/6.
//

import Foundation
import UIKit

let UIKitScreenHeight = UIScreen.main.bounds.size.height
let UIKitScreenWidth = UIScreen.main.bounds.size.width

func UIKitAdaptLandscapeWidth(_ x: CGFloat) -> CGFloat {
    return x * (UIKitScreenWidth / 375.0)
}

func UIKitAdaptLandscapeHeight(_ x: CGFloat) -> CGFloat {
    return x * (UIKitScreenHeight / 818.0)
}
