//
//  WorkhueAPIError.swift
//  Workhue
//
//  Created by 김서연 on 5/1/26.
//

import Foundation

enum WorkhueAPIError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingFailed
    case unknown
}
