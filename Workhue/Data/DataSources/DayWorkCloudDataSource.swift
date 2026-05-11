//
//  DayWorkCloudDataSource.swift
//  Workhue
//
//  Created by 김서연 on 4/28/26.
//

import CloudKit

final class DayWorkCloudDataSource {
    private let container = CKContainer.default()
    private var database: CKDatabase { container.privateCloudDatabase }
    private let recordType = "DayWork"

    func fetchAll() async throws -> [DayWorkDTO] {
        let query = CKQuery(
            recordType: recordType,
            predicate: NSPredicate(value: true)
        )

        var allRecords: [CKRecord] = []
        var cursor: CKQueryOperation.Cursor? = nil

        // 첫 번째 요청
        let firstResult = try await database.records(
            matching: query,
            resultsLimit: 100
        )
        allRecords += firstResult.matchResults.compactMap { try? $0.1.get() }
        cursor = firstResult.queryCursor

        // cursor가 있는 한 계속 다음 페이지 요청
        while let currentCursor = cursor {
            let nextResult = try await database.records(continuingMatchFrom: currentCursor)
            allRecords += nextResult.matchResults.compactMap { try? $0.1.get() }
            cursor = nextResult.queryCursor
        }

        return allRecords.compactMap { DayWorkDTO(from: $0) }
    }

    func save(_ dto: DayWorkDTO) async throws {
        let query = CKQuery(
            recordType: recordType,
            predicate: NSPredicate(format: "id == %@", dto.id)
        )
        let result = try await database.records(matching: query)
        let existing = result.matchResults.compactMap { try? $0.1.get() }.first
        let record = existing ?? CKRecord(recordType: recordType)
        dto.apply(to: record)
        try await database.save(record)
    }

    func delete(id: String) async throws {
        let query = CKQuery(
            recordType: recordType,
            predicate: NSPredicate(format: "id == %@", id)
        )
        let result = try await database.records(matching: query)
        guard let record = result.matchResults.compactMap({ try? $0.1.get() }).first else { return }
        try await database.deleteRecord(withID: record.recordID)
    }
}
