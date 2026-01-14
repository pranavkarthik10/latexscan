//
//  GeminiService.swift
//  latexscan
//
//  Created by Pranav Karthik on 2026-01-14.
//

import Foundation

enum GeminiError: LocalizedError {
    case invalidResponse
    case apiError(String)
    case noLatexFound
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from Gemini API"
        case .apiError(let message):
            return "API Error: \(message)"
        case .noLatexFound:
            return "No LaTeX content found in the image"
        }
    }
}

class GeminiService {
    var apiKey: String {
        get {
            UserDefaults.standard.string(forKey: "gemini_api_key") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "gemini_api_key")
        }
    }
    
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent"
    
    func convertImageToLatex(imageData: Data) async throws -> String {
        let base64Image = imageData.base64EncodedString()
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "text": """
                            Analyze this image and extract any mathematical equations, formulas, or expressions.
                            Convert them to LaTeX format.
                            
                            Rules:
                            - Return ONLY the LaTeX code, no explanations
                            - Use standard LaTeX math notation
                            - For inline math, don't wrap in $ symbols
                            - For display/block equations, don't wrap in $$ or \\[ \\]
                            - If there are multiple equations, separate them with newlines
                            - If no math content is found, return "NO_MATH_FOUND"
                            """
                        ],
                        [
                            "inline_data": [
                                "mime_type": "image/png",
                                "data": base64Image
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.1,
                "maxOutputTokens": 2048
            ]
        ]
        
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw GeminiError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw GeminiError.apiError(message)
            }
            throw GeminiError.apiError("HTTP \(httpResponse.statusCode)")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw GeminiError.invalidResponse
        }
        
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText == "NO_MATH_FOUND" {
            throw GeminiError.noLatexFound
        }
        
        return trimmedText
    }
}
