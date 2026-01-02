import Foundation

struct BibTeXParser {
    
    /// Parses a BibTeX string into an array of BibTeXEntry objects.
    static func parse(content: String) -> [BibTeXEntry] {
        var entries: [BibTeXEntry] = []
        
        // Regex to find entries like @article{ID, ... }
        // 1. Type
        // 2. ID
        // 3. Body content
        let entryPattern = #"@(\w+)\s*\{([^,]*),((?:[^{}]*|\{[^{}]*\})*)\}"#
        
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: entryPattern, options: [.dotMatchesLineSeparators])
        } catch {
            print("Regex error: \(error)")
            return []
        }
        
        let nsString = content as NSString
        let results = regex.matches(in: content, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for result in results {
            guard result.numberOfRanges >= 4 else { continue }
            
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
        
        // Regex to find key = value.
        // Supports:
        // 1. {value}
        // 2. "value"
        // 3. 1234 (unquoted numbers/identifiers)
        let fieldPattern = #"(\w+)\s*=\s*(?:\{((?:[^{}]|\\\}|\{[^{}]*\})*)\}|"((?:[^"]|\\")*)"|([0-9a-zA-Z\-]+))"#
        
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: fieldPattern, options: [.dotMatchesLineSeparators])
        } catch {
            return [:]
        }
        
        let nsBody = body as NSString
        let matches = regex.matches(in: body, options: [], range: NSRange(location: 0, length: nsBody.length))
        
        for match in matches {
            guard match.numberOfRanges >= 5 else { continue }
            let key = nsBody.substring(with: match.range(at: 1)).lowercased()
            
            var value = ""
            if match.range(at: 2).location != NSNotFound {
                value = nsBody.substring(with: match.range(at: 2))
            } else if match.range(at: 3).location != NSNotFound {
                value = nsBody.substring(with: match.range(at: 3))
            } else if match.range(at: 4).location != NSNotFound {
                value = nsBody.substring(with: match.range(at: 4))
            }
            
            // Basic cleanup of BibTeX escaping could go here
            fields[key] = value
        }
        return fields
    }
    
    static func serialize(entries: [BibTeXEntry]) -> String {
        var output = ""
        for entry in entries {
            output += "@\(entry.type){\(entry.id),\n"
            let sortedKeys = entry.fields.keys.sorted() // Sort keys for consistent output
            for key in sortedKeys {
                if let value = entry.fields[key] {
                    output += "  \(key) = {\(value)},\n"
                }
            }
            output += "}\n\n"
        }
        return output
    }
}
