//
//  AnalyticsManager.swift
//  Workhue
//
//  Created by 김서연 on 4/25/26.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    private init() {}
    
    func logScreen(_ screenID: ScreenID) {
        // Firebase Analytics
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenID.rawValue
        ])
    }
}
