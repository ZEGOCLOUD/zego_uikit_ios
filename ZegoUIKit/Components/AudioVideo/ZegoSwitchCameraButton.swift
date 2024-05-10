//
//  SwitchCameraFacingButton.swift
//  ZegoUIKit
//
//  Created by zego on 2022/7/25.
//

import UIKit

public protocol ZegoSwitchCameraButtonDelegate: AnyObject {
    func onSwitchCameraButtonClick(_ isFrontFacing: Bool)
}

extension ZegoSwitchCameraButtonDelegate {
    func onSwitchCameraButtonClick(_ isFrontFacing: Bool) { }
}

public class ZegoSwitchCameraButton: UIButton {
    
    public weak var delegate: ZegoSwitchCameraButtonDelegate?

    public var iconFrontFacingCamera: UIImage? {
        didSet {
            self.setImage(iconFrontFacingCamera, for: .normal)
        }
    }
    
    public var iconBackFacingCamera: UIImage? {
        didSet {
            self.setImage(iconBackFacingCamera, for: .selected)
        }
    }
    
    public var isFrontFacing: Bool = true {
        didSet {
            if isFrontFacing {
                self.isSelected = false
                ZegoUIKit.shared.useFrontFacingCamera(isFrontFacing: true)
            } else {
                self.isSelected = true
                ZegoUIKit.shared.useFrontFacingCamera(isFrontFacing: false)
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.isFrontFacing = true
        self.setImage(ZegoUIIconSet.iconCameraFlip, for: .normal)
        self.setImage(ZegoUIIconSet.iconCameraFlip, for: .selected)
        self.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isFrontFacing = true
        self.setImage(ZegoUIIconSet.iconCameraFlip, for: .normal)
        self.setImage(ZegoUIIconSet.iconCameraFlip, for: .selected)
        self.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
    }
    
    @objc func buttonClick(sender: UIButton) {
        self.isFrontFacing = !self.isFrontFacing
        self.delegate?.onSwitchCameraButtonClick(self.isFrontFacing)
    }

}
