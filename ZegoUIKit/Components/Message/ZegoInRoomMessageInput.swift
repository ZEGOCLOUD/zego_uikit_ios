//
//  ZegoInRoomMessageInput.swift
//  ZegoUIKit
//
//  Created by zego on 2022/8/22.
//

import UIKit

@objc public protocol ZegoInRoomMessageInputDelegate: AnyObject {
    func onSubmit()
}

public class ZegoInRoomMessageInput: UIView {
    
    @objc public weak var delegate: ZegoInRoomMessageInputDelegate?
    
    @objc public var placeHolder: String? {
        didSet {
            self.inputTextView.placeHolderLabel.text = placeHolder
        }
    }
    
    @objc public var iconSend: UIImage? = ZegoUIIconSet.iconMessageSendDisable {
        didSet {
            self.sendButton.setImage(iconSend, for: .normal)
        }
    }
    
    @objc public var enable: Bool = true {
        didSet {
            self.inputTextView.isEditable = enable
        }
    }
    
    @objc public var minHeight: CGFloat = 55
    fileprivate var lastOffsetY: CGFloat = 0
    
    lazy var inputTextView: ZegoUIKitTextView = {
        let textView = ZegoUIKitTextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textContainerInset = UIEdgeInsets.init(top: 17.5, left: 12, bottom: 17.5, right: 12)
        textView.textViewDelegate = self
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 8
        return textView
    }()
    
    lazy var sendButton: UIButton = {
        let button: UIButton = UIButton()
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        return button
    }()
    

    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.inputTextView)
        self.addSubview(self.sendButton)
        self.backgroundColor = UIColor.colorWithHexString("#242736")
        self.inputTextView.backgroundColor = UIColor.colorWithHexString("#FFFFFF", alpha: 0.1)
        self.sendButton.setImage(self.iconSend, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.setupUI()
    }
    
    @objc public func startEdit() {
        self.inputTextView.becomeFirstResponder()
    }
    
    func setupUI() {
        self.sendButton.frame = CGRect.init(x: self.frame.size.width - UIKitAdaptLandscapeWidth(29) - UIKitAdaptLandscapeWidth(10), y: (self.frame.size.height - UIKitAdaptLandscapeHeight(29)) * 0.5, width: UIKitAdaptLandscapeHeight(29), height: UIKitAdaptLandscapeHeight(29))
        self.inputTextView.frame = CGRect.init(x: UIKitAdaptLandscapeWidth(15), y: UIKitAdaptLandscapeHeight(7.5), width: self.frame.size.width - UIKitAdaptLandscapeWidth(15) - UIKitAdaptLandscapeHeight(34) - UIKitAdaptLandscapeWidth(15) - UIKitAdaptLandscapeWidth(9), height: self.frame.size.height - UIKitAdaptLandscapeHeight(7.5) * 2)
    }
    
    @objc func buttonClick() {
        if self.inputTextView.text.count == 0{
            self.inputTextView.endEditing(true)
            return
        }
        ZegoUIKit.shared.sendInRoomMessage(self.inputTextView.text)
        self.delegate?.onSubmit()
        self.lastOffsetY = 0
        self.inputTextView.text = ""
        self.inputTextView.endEditing(true)
        self.iconSend = ZegoUIIconSet.iconMessageSendDisable
    }
}

extension ZegoInRoomMessageInput: ZegoUIKitTextViewDelegate {
    func onTextViewHeightDidChange(_ height: CGFloat) {
        let viewHeight: CGFloat = height + UIKitAdaptLandscapeHeight(7.5) * 2 < self.minHeight ? self.minHeight : height + UIKitAdaptLandscapeHeight(7.5) * 2
        let offsetY: CGFloat = viewHeight - self.minHeight
        if lastOffsetY == offsetY {
            self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: viewHeight)
        } else {
            let newOffsetY: CGFloat = lastOffsetY - offsetY
            self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y + newOffsetY, width: self.frame.size.width, height: viewHeight)
        }
        self.lastOffsetY = offsetY
        if self.inputTextView.text.count > 0 {
            self.iconSend = ZegoUIIconSet.iconMessageSend
        } else {
            self.iconSend = ZegoUIIconSet.iconMessageSendDisable
        }
    }
}
