//
//  WorkhueAPIClient.swift
//  Workhue
//
//  Created by 김서연 on 5/1/26.
//

import Foundation

protocol WorkhueAPIClientProtocol {
    func analyzeEmotion(remembrance: String) async throws -> String
}

final class WorkhueAPIClient: WorkhueAPIClientProtocol {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func analyzeEmotion(remembrance: String) async throws -> String {
        let url = AppConfig.baseAPIURL
            .appendingPathComponent("v1/ai/analyze-emotion")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            ColorSuggestionRequestDTO(remembrance: remembrance)
        )

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WorkhueAPIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        default:
            throw WorkhueAPIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let dto = try JSONDecoder().decode(ColorSuggestionResponseDTO.self, from: data)
            return dto.colorRawValue
        } catch {
            throw WorkhueAPIError.decodingFailed
        }
    }
}
