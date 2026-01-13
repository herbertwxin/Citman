import Foundation

struct BibTeXEntry: Identifiable, Codable, Hashable {
    var id: String
    var type: String
    var fields: [String: String]
    
    // Helper accessors
    var title: String { clean(fields["title"] ?? "Untitled") }
    var author: String { clean(fields["author"] ?? "Unknown") }
    var year: String { clean(fields["year"] ?? "") }
    
    /// Removes BibTeX curly braces logic for display
    private func clean(_ text: String) -> String {
        text.replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
    }
    
    init(id: String, type: String, fields: [String: String]) {
        self.id = id
        self.type = type
        self.fields = fields
    }
}
