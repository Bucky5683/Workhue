//
//  AnalyticsManager.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import Foundation
import OSLog

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    private let logger = Logger(subsystem: "com.seoyeon.Workhue", category: "Analytics")
    private init() {}

    func logScreen(_ screenID: ScreenID) {
        logger.info("screen_view: \(screenID.rawValue)")
    }
}
