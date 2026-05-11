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

    // MARK: - Fetch All (with Pagination)
    func fetchAll() async throws -> [DayWorkDTO] {
        let query = CKQuery(
            recordType: recordType,
            predicate: NSPredicate(value: true)
        )
        query.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]

        let pageLimit = 100
        var records: [CKRecord] = []

        // 첫 번째 페이지
        let firstResult = try await database.records(
            matching: query,
            resultsLimit: pageLimit
        )
        appendSuccessRecords(from: firstResult.matchResults, to: &records)

        // 다음 페이지 반복
        var cursor = firstResult.queryCursor
        while let currentCursor = cursor {
            let nextResult = try await database.records(
                continuingMatchFrom: currentCursor,
                resultsLimit: pageLimit
            )
            appendSuccessRecords(from: nextResult.matchResults, to: &records)
            cursor = nextResult.queryCursor
        }

        return records.compactMap { DayWorkDTO(from: $0) }
    }

    // MARK: - Private Helper
    private func appendSuccessRecords(
        from matchResults: [(CKRecord.ID, Result<CKRecord, Error>)],
        to records: inout [CKRecord]
    ) {
        for (_, result) in matchResults {
            switch result {
            case .success(let record):
                records.append(record)
            case .failure(let error):
                print("[CloudKit] record fetch failed:", error)
            }
        }
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
