//
//  ZegoCloseSeatButton.swift
//  ZegoUIKit
//
//  Created by zegomjf on 2024/5/16.
//

import UIKit

public protocol CloseSeatButtonDelegate: AnyObject {
    func onCloseSeatButtonClick(_ lock: Bool)
}

extension CloseSeatButtonDelegate {
    func onCloseSeatButtonClick(_ lock: Bool) { }
}

public class ZegoCloseSeatButton: UIButton {

  public var isLock: Bool = true {
      didSet {
          self.isSelected = isLock
          ZegoUIKit.shared.setRoomProperty("lockseat", value: isLock ? "1" : "0", callback: nil)
      }
  }
  public weak var delegate: CloseSeatButtonDelegate?
  
  public var iconLockSeat: UIImage = ZegoUIIconSet.iconSeatLock {
      didSet {
          self.setImage(iconLockSeat, for: .selected)
      }
  }
  public var unLockSeat: UIImage = ZegoUIIconSet.iconSeatUnLock {
      didSet {
          self.setImage(unLockSeat, for: .normal)
      }
  }

  override init(frame: CGRect) {
      super.init(frame: frame)
      self.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
      self.setImage(self.unLockSeat, for: .normal)
      self.setImage(self.iconLockSeat, for: .selected)
  }
  
  required public init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  @objc func buttonClick() {
      self.isLock = !self.isLock
      self.delegate?.onCloseSeatButtonClick(self.isLock)
  }

}

