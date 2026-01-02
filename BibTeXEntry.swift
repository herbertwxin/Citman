import Foundation

struct BibTeXEntry: Identifiable, Hashable, Codable {
    var id: String
    var type: String
    var fields: [String: String] = [:]
    
    // Convenience accessors for the Table view
    var title: String { clean(fields["title"] ?? "Untitled") }
    var author: String { clean(fields["author"] ?? "Unknown") }
    var year: String { clean(fields["year"] ?? "") }
    
    /// Removes BibTeX curly braces logic for display
    private func clean(_ text: String) -> String {
        text.replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
    }
}
