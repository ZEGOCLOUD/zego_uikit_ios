//
//  ZegoUIKitTextView.swift
//  ZegoUIKit
//
//  Created by zego on 2022/8/22.
//

import UIKit

protocol ZegoUIKitTextViewDelegate: AnyObject {
    func onTextViewHeightDidChange(_ height: CGFloat)
}

class ZegoUIKitTextView: UITextView {
    
    var maxHeight: CGFloat = 60//定义最大高度
    weak var textViewDelegate: ZegoUIKitTextViewDelegate?
  
    lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.text = ZegoUIKitTranslationTextConfig.shared.translationText.textFieldPlaceholderMessage
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.colorWithHexString("#FFFFFF", alpha: 0.2)
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.tintColor = UIColor.colorWithHexString("#A653FF")
        self.textColor = UIColor.colorWithHexString("#FFFFFF", alpha: 0.8)
        self.addSubview(self.placeHolderLabel)
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.placeHolderLabel.frame = CGRect.init(x: 12, y: 9.5, width: self.frame.size.width - 24, height: self.frame.size.height - 19)
    }
    
}

extension ZegoUIKitTextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.placeHolderLabel.isHidden = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let frame = textView.frame
        let constrainSize = CGSize(width: frame.size.width,height: CGFloat(MAXFLOAT))
        var size = textView.sizeThatFits(constrainSize)
        if size.height >= maxHeight{
            size.height = maxHeight
            textView.isScrollEnabled = true
        }else{
            textView.isScrollEnabled = false
        }
        self.textViewDelegate?.onTextViewHeightDidChange(size.height)
        //重新设置textview的高度
        textView.frame = CGRect.init(x: textView.frame.origin.x, y: textView.frame.origin.y, width: textView.frame.size.width, height: size.height)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.placeHolderLabel.isHidden = textView.text.count > 0
    }

}
