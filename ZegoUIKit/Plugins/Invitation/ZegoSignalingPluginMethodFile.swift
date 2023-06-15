//
//  ZegoSignalingPluginMethodFile.swift
//  ZegoUIKitSDK
//
//  Created by zego on 2022/10/12.
//

import Foundation

public enum ZegoPluginMethodName: String {
    case init_method
    case uinit_method
    case login_method
    case logout_method
    case sendInvitation_method
    case cancelInvitation_method
    case refuseInvitation_method
    case acceptInvitation_method
    case onCallInvitationReceived_method
    case onCallInvitationCancelled_method
    case onCallInvitationAccepted_method
    case onCallInvitationRejected_method
    case onCallInvitationTimeout_method
    case onCallInviteesAnsweredTimeout_method
    case onConnectionStateChanged_method
    
    case joinRoom_metnod
    case leaveRoom_metnod
    case getUsersInRoomAttributes_method
    case setUsersInRoomAttributes_method
    case queryUsersInRoomAttributes_method
    case updateRoomProperty_method
    case deleteRoomProperties_method
    case beginRoomPropertiesBatchOperation_method
    case endRoomPropertiesBatchOperation_method
    case queryRoomProperties_method
    case onUsersInRoomAttributesUpdated_method
    case onRoomPropertiesUpdated_method
    case onRoomMemberLeft_method
    case onRoomTextMessageReceive_method
    
    case onEnableNotifyWhenAppRunningInBackgroundOrQuit_method
    case onSetRemoteNotificationsDeviceToken_method
    
}

