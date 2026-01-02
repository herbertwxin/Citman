import Foundation

struct BibTeXParser {
    
    static func parse(content: String) -> [BibTeXEntry] {
        var entries: [BibTeXEntry] = []
        // Regex to find entries like @article{ID, ... }
        let entryPattern = #"@(\w+)\s*\{([^,]*),((?:[^{}]*|\{[^{}]*\})*)\}"#
        
        let regex = try! NSRegularExpression(pattern: entryPattern, options: [.dotMatchesLineSeparators])
        let nsString = content as NSString
        let results = regex.matches(in: content, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for result in results {
            let type = nsString.substring(with: result.range(at: 1))
            let id = nsString.substring(with: result.range(at: 2)).trimmingCharacters(in: .whitespacesAndNewlines)
            let body = nsString.substring(with: result.range(at: 3))
            
            let fields = parseFields(body)
            entries.append(BibTeXEntry(id: id, type: type, fields: fields))
        }
        
        return entries
    }
    
    private static func parseFields(_ body: String) -> [String: String] {
        var fields: [String: String] = [:]
        // Regex to find key = {value} or key = "value"
        let fieldPattern = #"(\w+)\s*=\s*[\{"](.*?)[\}"](?=,\s*\w+\s*=|,\s*\}|\s*\Z)"#
        let regex = try! NSRegularExpression(pattern: fieldPattern, options: [.dotMatchesLineSeparators])
        let nsBody = body as NSString
        let matches = regex.matches(in: body, options: [], range: NSRange(location: 0, length: nsBody.length))
        
        for match in matches {
            let key = nsBody.substring(with: match.range(at: 1)).lowercased()
            let value = nsBody.substring(with: match.range(at: 2))
            fields[key] = value
        }
        return fields
    }
    
    static func serialize(entries: [BibTeXEntry]) -> String {
        var output = ""
        for entry in entries {
            output += "@\(entry.type){\(entry.id),\n"
            for (key, value) in entry.fields {
                output += "  \(key) = {\(value)},\n"
            }
            output += "}\n\n"
        }
        return output
    }
}
