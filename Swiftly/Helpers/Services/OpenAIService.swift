import FirebaseFunctions
import Foundation

class OpenAIService {
    private let functions = Functions.functions()

    func chatCompletion(messages: [[String: Any]]) async throws -> [String: String] {
        let data = ["messages": messages]
        let result = try await functions.httpsCallable("openai-api/chat").call(data)

        guard let response = result.data as? [String: Any],
              let choices = response["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String,
              let role = message["role"] as? String
        else {
            throw NSError(
                domain: "OpenAIService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Invalid response format"]
            )
        }

        return [
            "role": role,
            "content": content,
        ]
    }

    func onboardingCompletion(onboardingData: String) async throws -> [String: Any] {
        let data = ["onboardingData": onboardingData]
        let result = try await functions.httpsCallable("openai-api/onboarding").call(data)

        guard let response = result.data as? [String: Any],
              let choices = response["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String
        else {
            throw NSError(
                domain: "OpenAIService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Invalid response format"]
            )
        }
        
        // Parse the content string which contains the JSON
        guard let contentData = content.data(using: .utf8),
              let jsonResponse = try? JSONSerialization.jsonObject(with: contentData) as? [String: Any]
        else {
            throw NSError(
                domain: "OpenAIService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Invalid JSON content format"]
            )
        }

        return jsonResponse
    }

    func analyzeImage(base64Image: String) async throws -> [String: Any] {
        let data = ["image": base64Image]

        let result = try await functions.httpsCallable("openai-api/vision").call(data)

        guard let response = result.data as? [String: Any],
              let choices = response["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String
        else {
            throw NSError(
                domain: "OpenAIService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Invalid response format"]
            )
        }

        // Parse the content string which contains the JSON
        guard let contentData = content.data(using: .utf8),
              let jsonResponse = try? JSONSerialization.jsonObject(with: contentData) as? [String: Any]
        else {
            throw NSError(
                domain: "OpenAIService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Invalid JSON content format"]
            )
        }

        return jsonResponse
    }
}
