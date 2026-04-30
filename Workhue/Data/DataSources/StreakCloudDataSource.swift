//
//  StreakCloudDataSource.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import Foundation
import CloudKit

struct StreakCloudDataSource {

    private let container = CKContainer.default()
    private var db: CKDatabase { container.privateCloudDatabase }
    private let recordType = "StreakInfo"
    private let recordID   = CKRecord.ID(recordName: "userStreakInfo")

    // MARK: - 해금 색상
    func saveUnlockedColors(_ colors: [WorkColor]) async throws {
        let record = (try? await db.record(for: recordID)) ?? CKRecord(recordType: recordType, recordID: recordID)
        record["unlockedColors"] = colors.map { $0.rawValue } as CKRecordValue
        try await db.save(record)
    }

    func loadUnlockedColors() async throws -> [WorkColor] {
        guard let record = try? await db.record(for: recordID),
              let rawValues = record["unlockedColors"] as? [String]
        else { return [] }
        return rawValues.compactMap { WorkColor(rawValue: $0) }
    }

    // MARK: - new! 뱃지
    func setHasNew(_ value: Bool) async throws {
        let record = (try? await db.record(for: recordID)) ?? CKRecord(recordType: recordType, recordID: recordID)
        record["hasNewUnlock"] = value ? 1 : 0
        try await db.save(record)
    }

    func hasNewUnlock() async throws -> Bool {
        guard let record = try? await db.record(for: recordID) else { return false }
        return (record["hasNewUnlock"] as? Int) == 1
    }
    
    // MARK: - 커스텀 hex 리스트
    func saveCustomHexList(_ hexList: [String]) async throws {
        let record = (try? await db.record(for: recordID)) ?? CKRecord(recordType: recordType, recordID: recordID)
        record["customHexList"] = hexList as CKRecordValue
        try await db.save(record)
    }

    func loadCustomHexList() async throws -> [String] {
        guard let record = try? await db.record(for: recordID),
              let hexList = record["customHexList"] as? [String]
        else { return [] }
        return hexList
    }

    func addCustomHex(_ hex: String) async throws {
        var list = (try? await loadCustomHexList()) ?? []
        if !list.contains(hex.uppercased()) {
            list.append(hex.uppercased())
            try await saveCustomHexList(list)
        }
    }
}
