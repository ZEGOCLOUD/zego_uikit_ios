//
//  ZegoInRoomMessageViewDelegate.swift
//  ZegoUIKit
//
//  Created by Kael Ding on 2024/3/20.
//

import Foundation

@objc public protocol ZegoInRoomMessageViewDelegate: AnyObject {
    @objc optional func onInRoomMessageClick(_ message: ZegoInRoomMessage)
    @objc optional func getInRoomMessageItemView(_ tableView: UITableView, indexPath: IndexPath, message: ZegoInRoomMessage) -> UITableViewCell?
}
