//
//  ZegoMemberList.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/9/13.
//

import UIKit

@objc public protocol ZegoMemberListDelegate: AnyObject {
    @objc optional func getMemberListItemView(_ tableView: UITableView, indexPath: IndexPath, userInfo: ZegoUIKitUser) -> UITableViewCell?
    @objc optional func getMemberListItemHeight(_ userInfo: ZegoUIKitUser) -> CGFloat
    @objc optional func getMemberListHeaderHeight(_ tableView: UITableView, section: Int) -> CGFloat
    @objc optional func getMemberListViewForHeaderInSection(_ tableView: UITableView, section: Int) -> UIView?
    @objc optional func sortUserList(_ userList: [ZegoUIKitUser]) -> [ZegoUIKitUser]
}

public class ZegoMemberList: UIView {
    
    public weak var delegate: ZegoMemberListDelegate?
    public var showMicrophoneState: Bool = true
    public var showCameraState: Bool = true
    
    let help = ZegoMemberList_Help()
    fileprivate let ZegoMemberListCellIdentifier: String = "ZegoUIkitMemberListCell"

    var userList: [ZegoUIKitUser] = []
    
    public lazy var tableView: UITableView = {
        let memberListView = UITableView(frame: CGRect.zero, style: .grouped)
        memberListView.backgroundColor = UIColor.colorWithHexString("#222222",alpha: 0.8)
        memberListView.delegate = self.help
        memberListView.dataSource = self.help
        memberListView.register(ZegoMemberListCell.self, forCellReuseIdentifier: ZegoMemberListCellIdentifier)
        return memberListView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.help.memberList = self
        self.addSubview(self.tableView)
        self.getUserList()
        ZegoUIKit.shared.addEventHandler(self.help)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.zgu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    @objc public func registerCell(_ cellClass: AnyClass?, forCellReuseIdentifier: String) {
        self.tableView.register(cellClass, forCellReuseIdentifier: forCellReuseIdentifier)
    }
    
    @objc public func registerNibCell(_ nib: UINib?, forCellReuseIdentifier: String) {
        self.tableView.register(nib, forCellReuseIdentifier: forCellReuseIdentifier)
    }
    
    @objc public func reloadData() {
        self.userList = self.delegate?.sortUserList?(self.userList) ?? self.userList
        self.tableView.reloadData()
    }
    
    func getUserList() {
        var index: Int = 0
        self.userList.removeAll()
        let sortUserList: [ZegoUIKitUser]? = self.delegate?.sortUserList?(ZegoUIKit.shared.getAllUsers())
        if let sortUserList = sortUserList {
            self.userList = sortUserList
        } else {
            for user in ZegoUIKit.shared.getAllUsers() {
                if index == 0 {
                    self.userList.append(user)
                } else {
                    if user.userID == ZegoUIKit.shared.localUserInfo?.userID {
                        self.userList.insert(user, at: 0)
                    } else {
                        self.userList.insert(user, at: 1)
                    }
                }
                index = index + 1
            }
        }
        self.tableView.reloadData()
    }
    
}

class ZegoMemberList_Help: NSObject, UITableViewDelegate, UITableViewDataSource, ZegoUIKitEventHandle {
    
    weak var memberList: ZegoMemberList?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberList?.userList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userInfo: ZegoUIKitUser? = self.memberList?.userList[indexPath.row]
        guard let userInfo = userInfo else {
            return UITableViewCell()
        }
        
        let cell = self.memberList?.delegate?.getMemberListItemView?(tableView, indexPath: indexPath, userInfo: userInfo)
        guard let cell = cell else {
            let normalCell: ZegoMemberListCell = tableView.dequeueReusableCell(withIdentifier: self.memberList?.ZegoMemberListCellIdentifier ?? "") as! ZegoMemberListCell
            normalCell.showCameraState = self.memberList?.showCameraState ?? true
            normalCell.showMicrophoneState = self.memberList?.showMicrophoneState ?? true
            normalCell.userInfo = userInfo
            normalCell.backgroundColor = UIColor.clear
            return normalCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.memberList?.delegate?.getMemberListViewForHeaderInSection?(tableView, section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.memberList?.delegate?.getMemberListHeaderHeight?(tableView, section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let userInfo: ZegoUIKitUser? = self.memberList?.userList[indexPath.row]
        guard let userInfo = userInfo else {
            return 40
        }
        return self.memberList?.delegate?.getMemberListItemHeight?(userInfo) ?? 54
    }
    
    //MARK: - ZegoUIKitEventHandle
    func onUserCountOrPropertyChanged(_ userList: [ZegoUIKitUser]?) {
        self.memberList?.userList.removeAll()
        guard let userList = userList else {
            return
        }
        let sortUserList: [ZegoUIKitUser]? = self.memberList?.delegate?.sortUserList?(userList)
        if let sortUserList = sortUserList {
            self.memberList?.userList = sortUserList
        } else {
            var index: Int = 0
            for user in userList {
                if index == 0 {
                    self.memberList?.userList.append(user)
                } else {
                    if user.userID == ZegoUIKit.shared.localUserInfo?.userID {
                        self.memberList?.userList.insert(user, at: 0)
                    } else {
                        self.memberList?.userList.insert(user, at: 1)
                    }
                }
                index = index + 1
            }
        }
        self.memberList?.tableView.reloadData()
    }
}
