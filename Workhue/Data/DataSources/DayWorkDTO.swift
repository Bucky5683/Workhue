//
//  DayWorkDTO.swift
//  Workhue
//
//  Created by 김서연 on 4/28/26.
//

import Foundation
import CloudKit

struct DayWorkDTO: Codable {
    let id: String
    let date: Date
    let status: String
    let startTime: Date?
    let endTime: Date?
    var remembrance: String?
    var checkList: [WorkCheckListDTO]
    var workColor: String?
    var customHex: String?
}

struct WorkCheckListDTO: Codable {
    let id: String
    let content: String
    let isDone: Bool

    init(from model: WorkCheckList) {
        self.id = model.id
        self.content = model.content
        self.isDone = model.isDone
    }

    func toModel() -> WorkCheckList {
        WorkCheckList(id: id, content: content, isDone: isDone)
    }
}

// MARK: - DayWorkModel → DTO
extension DayWorkDTO {
    init(from model: DayWorkModel) {
        self.id = model.id
        self.date = model.date
        self.status = model.status.rawValue
        self.startTime = model.startTime
        self.endTime = model.endTime
        self.remembrance = model.remembrance
        self.checkList = model.checkList.map { WorkCheckListDTO(from: $0) }
        self.workColor = model.workColor?.rawValue
        self.customHex = model.customHex
    }
}

// MARK: - CKRecord → DTO
extension DayWorkDTO {
    init?(from record: CKRecord) {
        guard
            let id = record["id"] as? String,
            let date = record["date"] as? Date,
            let statusRaw = record["status"] as? String
        else { return nil }

        self.id = id
        self.date = date
        self.status = statusRaw
        self.startTime = record["startTime"] as? Date
        self.endTime = record["endTime"] as? Date
        self.remembrance = record["remembrance"] as? String
        self.workColor = record["workColor"] as? String
        self.customHex = record["customHex"] as? String

        if let str = record["checkList"] as? String,
           let data = str.data(using: .utf8),
           let list = try? JSONDecoder().decode([WorkCheckListDTO].self, from: data) {
            self.checkList = list
        } else {
            self.checkList = []
        }
    }

    func apply(to record: CKRecord) {
        record["id"] = id
        record["date"] = date
        record["status"] = status
        record["startTime"] = startTime
        record["endTime"] = endTime
        record["remembrance"] = remembrance
        record["workColor"] = workColor
        record["customHex"] = customHex  // 추가

        if let data = try? JSONEncoder().encode(checkList),
           let str = String(data: data, encoding: .utf8) {
            record["checkList"] = str
        }
    }
}

// MARK: - DTO → DayWorkModel
extension DayWorkDTO {
    func toModel() -> DayWorkModel? {
        guard let status = WorkStatus(rawValue: self.status) else { return nil }
        return DayWorkModel(
            id: id,
            date: date,
            status: status,
            startTime: startTime,
            endTime: endTime,
            workColor: workColor.flatMap { WorkColor(rawValue: $0) },
            customHex: customHex,
            remembrance: remembrance,
            checkList: checkList.map { $0.toModel() }
        )
    }
}
