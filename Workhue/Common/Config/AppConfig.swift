//
//  AppConfig.swift
//  Workhue
//
//  Created by 김서연 on 5/1/26.
//

import Foundation

enum AppConfig {
    static var baseAPIURL: URL {
        guard
            let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path),
            let urlString = dict["BASE_API_URL"] as? String,
            let url = URL(string: urlString)
        else {
            fatalError("Config.plist에 BASE_API_URL이 없어요")
        }
        return url
    }
}
