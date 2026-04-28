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
        let result = try await database.records(matching: query)
        return result.matchResults.compactMap { _, result in
            try? result.get()
        }.compactMap {
            DayWorkDTO(from: $0)
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
