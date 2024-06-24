//
//  QuitButton.swift
//  ZegoUIKit
//
//  Created by zego on 2022/7/25.
//

import UIKit

public protocol LeaveButtonDelegate: AnyObject {
    func onLeaveButtonClick(_ isLeave: Bool)
}

extension LeaveButtonDelegate {
    func onLeaveButtonClick(_ isLeave: Bool) { }
}

public class ZegoLeaveConfirmDialogInfo: NSObject {
    public var title: String?
    public var message: String?
    public var cancelButtonName: String?
    public var confirmButtonName: String?
    public weak var dialogPresentVC: UIViewController?
}

public class ZegoLeaveButton: UIButton {

    public weak var delegate: LeaveButtonDelegate?
    public var quitConfirmDialogInfo: ZegoLeaveConfirmDialogInfo = ZegoLeaveConfirmDialogInfo()
    public var iconLeave: UIImage = ZegoUIIconSet.iconPhone {
        didSet{
            self.setImage(iconLeave, for: .normal)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setImage(self.iconLeave, for: .normal)
        self.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonClick() {
        if let showDialogVC = self.quitConfirmDialogInfo.dialogPresentVC {
            self.showDialog(showDialogVC)
        } else {
            self.delegate?.onLeaveButtonClick(true)
            ZegoUIKit.shared.leaveRoom()
        }
    }
    
    private func showDialog(_ showDialogVC: UIViewController) {
        var dialogTitle: String = ZegoUIKitTranslationTextConfig.shared.translationText.leaveRoomTextDialogTitle
        if let title = self.quitConfirmDialogInfo.title {
            dialogTitle = title
        }
        var dialogMessage: String = ZegoUIKitTranslationTextConfig.shared.translationText.leaveRoomTextDialogMessage
        if let message = self.quitConfirmDialogInfo.message {
            dialogMessage = message
        }
        var cancelName: String = ZegoUIKitTranslationTextConfig.shared.translationText.cancelDialogMessage
        if let cancelButtonName = self.quitConfirmDialogInfo.cancelButtonName {
            cancelName = cancelButtonName
        }
        var sureName: String = ZegoUIKitTranslationTextConfig.shared.translationText.confirmDialogMessage
        if let confirmButtonName = self.quitConfirmDialogInfo.confirmButtonName {
            sureName = confirmButtonName
        }
        let alterView = UIAlertController.init(title: dialogTitle, message: dialogMessage, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction.init(title: cancelName, style: .cancel) { action in
            self.delegate?.onLeaveButtonClick(false)
        }
        let sureAction: UIAlertAction = UIAlertAction.init(title: sureName, style: .default) { action in
            self.delegate?.onLeaveButtonClick(true)
            ZegoUIKit.shared.leaveRoom()
        }
        alterView.addAction(cancelAction)
        alterView.addAction(sureAction)
        showDialogVC.present(alterView, animated: false, completion: nil)
    }

}
