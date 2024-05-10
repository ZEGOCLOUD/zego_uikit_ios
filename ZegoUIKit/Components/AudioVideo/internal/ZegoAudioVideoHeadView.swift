//
//  ZegoAudioVideoHeadView.swift
//  Pods-ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2023/2/3.
//

import UIKit

class ZegoAudioVideoHeadView: UIView {
    
    var font: UIFont? {
        didSet {
            guard let font = font else { return }
            self.headLabel.font = font
        }
    }
    
    var text: String? {
        didSet {
            guard let text = text else { return }
            if text.count > 0 {
                let firstStr: String = String(text[text.startIndex])
                self.headLabel.text = firstStr
            }
        }
    }
    
    var lastUrl: String?

    lazy var headLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textAlignment = .center
        label.textColor = UIColor.colorWithHexString("#222222")
        label.backgroundColor = UIColor.colorWithHexString("#DBDDE3")
        return label
    }()
    
    lazy var headImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.headLabel)
        self.addSubview(self.headImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.headLabel.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.headLabel.layer.masksToBounds = true
        self.headLabel.layer.cornerRadius = self.frame.size.width * 0.5
        self.headImageView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.headImageView.layer.masksToBounds = true
        self.headImageView.layer.cornerRadius = self.frame.size.width * 0.5
    }
    
    func setHeadImageUrl(_ url: String) {
        if let imageUrl: URL = URL(string: url) {
            if !UIApplication.shared.canOpenURL(imageUrl){
                //invalid url
                return
            }
            if (lastUrl == url) { return }
            self.lastUrl = url
            self.headImageView.downloadedFrom(url: imageUrl)
        }
    }
    
    func setHeadLabelText(_ text: String) {
        self.headLabel.text = text
    }

}
