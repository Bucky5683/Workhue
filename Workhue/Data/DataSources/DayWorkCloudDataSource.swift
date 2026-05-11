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

    func fetch(dateKey: String) async throws -> DayWorkDTO? {
        let recordID = recordID(for: dateKey)
        do {
            let record = try await database.record(for: recordID)
            return DayWorkDTO(from: record)
        } catch let error as CKError where error.code == .unknownItem {
            return nil
        }
    }
    
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
    
    private func recordID(for dateKey: String) -> CKRecord.ID {
        CKRecord.ID(recordName: "daywork_\(dateKey)")
    }

    func save(_ dto: DayWorkDTO) async throws -> String? {
        let recordID = recordID(for: dto.dateKey)
        let existingRecord: CKRecord

        do {
            existingRecord = try await database.record(for: recordID)
        } catch let error as CKError where error.code == .unknownItem {
            existingRecord = CKRecord(recordType: recordType, recordID: recordID)
        } catch {
            throw error  // ✅ 네트워크/권한 오류는 rethrow
        }

        // ✅ 서버가 더 최신이면 업로드 금지
        if let serverDTO = DayWorkDTO(from: existingRecord),
           serverDTO.updatedAt > dto.updatedAt {
            throw SyncError.serverRecordIsNewer
        }

        dto.apply(to: existingRecord)
        let saved = try await database.save(existingRecord)
        return saved.recordChangeTag
    }

    func delete(dateKey: String) async throws {
        let recordID = recordID(for: dateKey)
        do {
            try await database.deleteRecord(withID: recordID)
        } catch let error as CKError where error.code == .unknownItem {
            return  // ✅ 이미 없으면 성공으로 처리
        } catch {
            throw error
        }
    }
}
