//
//  DayWorkLocalDataSource.swift
//  Workhue
//
//  Created by 김서연 on 4/28/26.
//

import Foundation

final class DayWorkLocalDataSource {
    private let defaults = UserDefaults.standard
    private let key = "dayWorkList"

    func fetchAll() -> [DayWorkDTO] {
        guard
            let data = defaults.data(forKey: key),
            let list = try? JSONDecoder().decode([DayWorkDTO].self, from: data)
        else { return [] }
        return list
    }

    func save(_ dto: DayWorkDTO) {
        var list = fetchAll()
        if let idx = list.firstIndex(where: { $0.id == dto.id }) {
            list[idx] = dto
        } else {
            list.append(dto)
        }
        if let data = try? JSONEncoder().encode(list) {
            defaults.set(data, forKey: key)
        }
    }

    func delete(id: String) {
        var list = fetchAll()
        list.removeAll { $0.id == id }
        if let data = try? JSONEncoder().encode(list) {
            defaults.set(data, forKey: key)
        }
    }
}
