import Foundation

public struct Nomination: Codable, Hashable {
    public let title: String
    public let year: Int
    public let reason: String
}

public final class AnthropicClient {
    private let apiKey: String
    private let model: String
    private let session: URLSession
    private let baseURL = URL(string: "https://api.anthropic.com/v1")!

    public init(apiKey: String, model: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.model = model
        self.session = session
    }

    public func nominate(
        mood: MoodSelection,
        familySafe: Bool,
        page: Int,
        excludeTitles: [String]
    ) async throws -> [Nomination] {
        let vibeLine = mood.vibe.map { "Vibe: \($0.rawValue)\n" } ?? ""
        let decadeLine = mood.decade.map { "Decade: \($0.rawValue)\n" } ?? ""
        let pageLine = page > 1 ? "Give less obvious, deeper-cut suggestions (page \(page)).\n" : ""
        let excludeLine = excludeTitles.isEmpty ? "" : "\nDo NOT suggest any of these movies (already shown): \(excludeTitles.joined(separator: ", "))\n"

        let userMessage = """
        You are a movie expert. The user wants to watch something tonight.
        Audience: \(mood.audience.rawValue)
        \(vibeLine)Genre: \(mood.genre.rawValue)
        \(decadeLine)Family safe: \(familySafe ? "yes" : "no") - only suggest age-appropriate movies for this setting
        \(excludeLine)
        Nominate 30 real movies that perfectly match this mood, ranked best-first.
        \(pageLine)Prioritize variety - different decades, tones, and styles.
        IMPORTANT: Include at least 8 recent films from 2022-2026 if they fit the mood.
        For each, write one sentence explaining why it fits the mood.
        Return JSON only: [{ "title": string, "year": number, "reason": string }]
        """

        let payload = AnthropicMessagesRequest(
            model: model,
            maxTokens: 4000,
            system: "You are a movie recommendation assistant. Be warm, concise, and human.",
            messages: [.init(role: "user", content: userMessage)]
        )

        let data = try JSONEncoder().encode(payload)
        var request = URLRequest(url: baseURL.appendingPathComponent("messages"))
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        let (responseData, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(AnthropicMessagesResponse.self, from: responseData)
        let text = decoded.content.first(where: { $0.type == "text" })?.text ?? ""
        return try parseNominationJSON(text)
    }

    private func parseNominationJSON(_ text: String) throws -> [Nomination] {
        let stripped = text
            .replacingOccurrences(of: "```json\n", with: "")
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let extracted = try extractFirstJSONArray(from: stripped)
        let sanitized = extracted
            .replacingOccurrences(of: ",\\s*([}\\]])", with: "$1", options: .regularExpression)
            .replacingOccurrences(of: "}\\s*{", with: "},{", options: .regularExpression)
        return try JSONDecoder().decode([Nomination].self, from: Data(sanitized.utf8))
    }

    private func extractFirstJSONArray(from text: String) throws -> String {
        guard let start = text.firstIndex(of: "[") else {
            throw NSError(domain: "AnthropicClient", code: 1, userInfo: [NSLocalizedDescriptionKey: "No JSON array in Claude response"])
        }

        var depth = 0
        var inString = false
        var escaping = false

        var index = start
        while index < text.endIndex {
            let char = text[index]

            if escaping {
                escaping = false
                index = text.index(after: index)
                continue
            }

            if char == "\\" {
                escaping = true
                index = text.index(after: index)
                continue
            }

            if char == "\"" {
                inString.toggle()
                index = text.index(after: index)
                continue
            }

            if !inString {
                if char == "[" {
                    depth += 1
                } else if char == "]" {
                    depth -= 1
                    if depth == 0 {
                        return String(text[start...index])
                    }
                }
            }

            index = text.index(after: index)
        }

        throw NSError(domain: "AnthropicClient", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unterminated JSON array in Claude response"])
    }
}

private struct AnthropicMessagesRequest: Encodable {
    struct Message: Encodable {
        let role: String
        let content: String
    }

    let model: String
    let maxTokens: Int
    let system: String
    let messages: [Message]

    private enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case system
        case messages
    }
}

private struct AnthropicMessagesResponse: Decodable {
    struct ContentBlock: Decodable {
        let type: String
        let text: String?
    }

    let content: [ContentBlock]
}
