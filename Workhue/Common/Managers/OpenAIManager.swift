//
//  OpenAIManager.swift
//  Workhue
//
//  Created by 김서연 on 4/29/26.
//

import Foundation

final class OpenAIManager {
    static let shared = OpenAIManager()
    private init() {}

    private var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["OPENAI_API_KEY"] as? String
        else {
            fatalError("Config.plist에 OPENAI_API_KEY가 없어요")
        }
        return key
    }

    func analyzeEmotion(from text: String) async throws -> WorkColor {
        let colorList = WorkColor.analyzableColors
            .map { "\($0.rawValue) (\($0.description))" }
            .joined(separator: "\n")

        let prompt = """
        다음 회고 텍스트를 읽고 감정을 분석해서 아래 색상 중 하나의 rawValue만 반환해줘.
        반드시 색상 rawValue만 반환하고 다른 텍스트는 절대 포함하지 마.

        색상 목록:
        \(colorList)

        회고: \(text)
        """

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 20
        ]

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        let colorName = response.choices.first?.message.content
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? "SteelBlue"
        return WorkColor(rawValue: colorName) ?? .steelBlue
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message
    }

    struct Message: Codable {
        let content: String
    }
}
