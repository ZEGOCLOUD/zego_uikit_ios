//
//  LiveAudioMessageModelBuilder.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/16.
//

import UIKit

let hostWidth: CGFloat = 33.0
class MessageModel: NSObject {
    var content: String?
    var attributedContent: NSAttributedString?
    var messageWidth: CGFloat = 0
    var messageHeight: CGFloat = 0
    
}

class MessageModelBuilder: NSObject {
    
    static var _messageViewWidth: CGFloat?
    static var messageViewWidth: CGFloat? {
        set {
            _messageViewWidth = newValue
        }
        get {
            return _messageViewWidth
        }
    }
    
    static func buildModel(with user: ZegoUIKitUser?, message: String) -> MessageModel {
        let isHost: Bool = false
        let attributedStr: NSMutableAttributedString = NSMutableAttributedString()
        
        let nameAttributes = getNameAttributes(isHost: isHost)
        let nameStr: NSAttributedString = NSAttributedString(string: user?.userName ?? "", attributes: nameAttributes)
    
        
        let contentAttributes = getContentAttributes(isHost: isHost)
        let content: String = " " + message
        let contentStr: NSAttributedString = NSAttributedString(string: content, attributes: contentAttributes)
        
        attributedStr.append(nameStr)
        attributedStr.append(contentStr)
        
        let labelWidth = (messageViewWidth ?? 0) - 10 * 2
        var size = attributedStr.boundingRect(with: CGSize.init(width: labelWidth, height: CGFloat(MAXFLOAT)), options:[NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], context: nil).size
        
        if size.height <= 16 {
            size.width += isHost ? hostWidth : 0
        }
        
        let model:MessageModel = MessageModel()
        model.content = content
        model.attributedContent = attributedStr
        model.messageWidth = size.width + 1.0
        model.messageHeight = size.height
        return model
    }
    
    static func buildLeftMessageModel(user: ZegoUIKitUser) -> MessageModel {
        let message = String(format: ZegoUIKitTranslationTextConfig.shared.translationText.leftRoomDialogMessage)
        return buildModel(with: user, message: message)
    }
    
    static func buildJoinMessageModel(user: ZegoUIKitUser) -> MessageModel {
        let message = String(format: ZegoUIKitTranslationTextConfig.shared.translationText.joinedRoomDialogMessage)
        return buildModel(with: user, message: message)
    }
        
    private static func getNameAttributes(isHost: Bool) -> [NSAttributedString.Key : Any] {
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.paragraphSpacing = 0
        paragraphStyle.minimumLineHeight = 16.0
        paragraphStyle.firstLineHeadIndent = isHost ? hostWidth : 0
        paragraphStyle.lineBreakMode = .byCharWrapping
        return [.font : UIFont.systemFont(ofSize: 13.0, weight: .medium),
                .paragraphStyle : paragraphStyle,
                .foregroundColor : UIColor.colorWithHexString("8BE7FF")]
    }
    
    private static func getContentAttributes(isHost: Bool) -> [NSAttributedString.Key : Any] {
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.paragraphSpacing = 0
        paragraphStyle.minimumLineHeight = 16.0
        paragraphStyle.firstLineHeadIndent = isHost ? hostWidth : 0
        paragraphStyle.lineBreakMode = .byCharWrapping
        return [.font : UIFont.systemFont(ofSize: 13.0),
                .paragraphStyle : paragraphStyle,
                .foregroundColor : UIColor.white]
    }
    
    private static func _buildLeftOrJoinMessageModel(message: String) -> MessageModel {
        let model: MessageModel = MessageModel()
        model.content = message
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 0
        paragraphStyle.minimumLineHeight = 16.0
        
        let attributes: [NSAttributedString.Key : Any] = [.font : UIFont.systemFont(ofSize: 13.0, weight: .medium),
                                                          .paragraphStyle : paragraphStyle,
                                                          .foregroundColor : UIColor.colorWithHexString("8BE7FF")]
        let attributedStr: NSAttributedString = NSAttributedString(string: message, attributes: attributes)
        
        let labelWidth = (messageViewWidth ?? 0) - 10 * 2
        let size = attributedStr.boundingRect(with: CGSize.init(width: labelWidth, height: CGFloat(MAXFLOAT)), options: [NSStringDrawingOptions.usesLineFragmentOrigin], context: nil).size
        
        model.attributedContent = attributedStr
        model.messageWidth = size.width + 1.0
        model.messageHeight = size.height
        return model
    }
    
}
