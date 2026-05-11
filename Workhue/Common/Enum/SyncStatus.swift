//
//  SyncStatus.swift
//  Workhue
//
//  Created by 김서연 on 5/11/26.
//

enum SyncStatus: String, Codable {
    case synced
    case pendingUpload
    case pendingDelete
    case failed
    case conflict
}
