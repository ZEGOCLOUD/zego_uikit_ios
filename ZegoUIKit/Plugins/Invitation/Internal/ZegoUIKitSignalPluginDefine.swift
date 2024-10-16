//
//  ZegoUIKitSignalDefine.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/12/19.
//

import Foundation

enum InvitationState: Int {
    case error
    case accept
    case waiting
    case refuse
    case cancel
    case timeout
}

class ZegoInvitationUser: NSObject {
    var user: ZegoUIKitUser?
    var state: InvitationState = .error
    
    init(_ user: ZegoUIKitUser, state: InvitationState) {
        super.init()
        self.user = user
        self.state = state
    }
}

class InvitationData: NSObject {
    var invitationID: String?
    var inviter: ZegoUIKitUser?
    var invitees: [ZegoInvitationUser]?
    var type: Int = 0
    var inviteesDict: [String : String] = [:]
    
    init(_ invitationID: String, inviter: ZegoUIKitUser, invitees: [ZegoInvitationUser], type: Int) {
        super.init()
        self.invitationID = invitationID
        self.invitees = invitees
        self.inviter = inviter
        self.type = type
        for user in invitees {
            guard let userID = user.user?.userID else { continue }
            self.inviteesDict[userID] = invitationID
        }
    }
}
