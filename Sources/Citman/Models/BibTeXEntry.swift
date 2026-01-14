import Foundation

struct BibTeXEntry: Identifiable, Codable, Hashable {
    var id: String
    var type: String
    var fields: [String: String]
    
    // Helper accessors
    var title: String { clean(fields["title"] ?? "Untitled") }
    var author: String { clean(fields["author"] ?? "Unknown") }
    var year: String { clean(fields["year"] ?? "") }
    
    /// Removes BibTeX curly braces logic for display and handles basic LaTeX accents
    private func clean(_ text: String) -> String {
        var cleanText = text
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .replacingOccurrences(of: "\\&", with: "&")
        
        // Basic LaTeX accent replacements
        let replacements = [
            "\\\"a": "ä", "\\\"o": "ö", "\\\"u": "ü",
            "\\\"A": "Ä", "\\\"O": "Ö", "\\\"U": "Ü",
            "\\'e": "é", "\\'a": "á", "\\'o": "ó", "\\'i": "í", "\\'u": "ú",
            "\\`e": "è", "\\`a": "à", "\\`o": "ò", "\\`i": "ì", "\\`u": "ù",
            "\\^e": "ê", "\\^a": "â", "\\^o": "ô", "\\^i": "î", "\\^u": "û",
            "\\ss": "ß", "\\ae": "æ", "\\AE": "Æ", "\\oe": "œ", "\\OE": "Œ",
            "\\aa": "å", "\\AA": "Å", "\\o": "ø", "\\O": "Ø"
        ]
        
        for (latex, char) in replacements {
            cleanText = cleanText.replacingOccurrences(of: latex, with: char)
        }
        
        return cleanText
    }
    
    /// Generates a standard Citation Key (e.g. AuthorYear)
    func generateKey() -> String {
        let cleanAuthor = author.components(separatedBy: CharacterSet.letters.inverted).joined()
        // Extract first author's last name (heuristic)
        let lastName: String
        if let commaIndex = cleanAuthor.firstIndex(of: ",") {
            // "Smith, John" -> "Smith"
            lastName = String(cleanAuthor[..<commaIndex])
        } else {
             // "John Smith" -> "Smith" (rough guess, take last word) or just take first word if single name
             // Better heuristic: "Author" usually stores "Last, First" in BibTeX. 
             // If not, take the first word for safety.
             let words = cleanAuthor.split(separator: " ")
             lastName = String(words.first ?? "Unknown")
        }
        
        let safeLast = lastName.filter { $0.isLetter }.prefix(6) // Limit length
        let safeYear = year.filter { $0.isNumber }
        
        if safeLast.isEmpty && safeYear.isEmpty { return id }
        return "\(safeLast)\(safeYear)"
    }
    
    /// Serializes this single entry to BibTeX format
    func toBibTeX() -> String {
        var output = "@\(type){\(id),\n"
        let sortedKeys = fields.keys.sorted()
        for key in sortedKeys {
            if let value = fields[key] {
                output += "  \(key) = {\(value)},\n"
            }
        }
        output += "}"
        return output
    }
    
    init(id: String, type: String, fields: [String: String]) {
        self.id = id
        self.type = type
        self.fields = fields
    }
}
