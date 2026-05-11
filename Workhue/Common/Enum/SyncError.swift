//
//  SyncError.swift
//  Workhue
//
//  Created by 김서연 on 5/11/26.
//

enum SyncError: Error {
    case serverRecordIsNewer
    case iCloudAccountUnavailable
}
