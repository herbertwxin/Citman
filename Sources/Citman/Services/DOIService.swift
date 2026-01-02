import Foundation

struct DOIService {
    enum DOIError: Error {
        case invalidURL
        case networkError(Error)
        case invalidResponse
    }
    
    struct SearchResult: Decodable, Identifiable {
        let id: String // This maps to the DOI in CrossRef response
        let title: [String]?
        let author: [Author]?
        
        struct Author: Decodable {
            let family: String?
            let given: String?
        }
        
        var displayTitle: String { title?.first ?? "Unknown Title" }
        var displayAuthor: String {
            guard let first = author?.first else { return "" }
            return "\(first.given ?? "") \(first.family ?? "")"
        }
    }

    /// Fetches the raw BibTeX string for a specific DOI
    static func fetchBibTeX(for doi: String) async throws -> String {
        let cleanedDOI = doi.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "https://doi.org/", with: "")
            .replacingOccurrences(of: "doi:", with: "")
        
        guard let url = URL(string: "https://doi.org/" + mechanismEncoded(cleanedDOI)) else {
            throw DOIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/x-bibtex", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw DOIError.invalidResponse
        }
        
        guard let fetchString = String(data: data, encoding: .utf8) else {
             throw DOIError.invalidResponse
        }
        return fetchString
    }
    
    /// Searches CrossRef for articles
    static func search(query: String) async throws -> [SearchResult] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.crossref.org/works?query.bibliographic=\(encodedQuery)&rows=5") else {
            throw DOIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw DOIError.invalidResponse
        }
        
        // Helper struct to parse CrossRef JSON
        struct CrossRefResponse: Decodable {
            let message: Message
            struct Message: Decodable {
                let items: [SearchResult] // CrossRef returns items
            }
        }
        
        let result = try JSONDecoder().decode(CrossRefResponse.self, from: data)
        return result.message.items
    }
    
    private static func mechanismEncoded(_ string: String) -> String {
       return string.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? string
    }
}
