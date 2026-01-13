import Foundation

struct BibTeXParser {
    
    /// Parses a BibTeX string into an array of BibTeXEntry objects.
    static func parse(content: String) -> [BibTeXEntry] {
        var entries: [BibTeXEntry] = []
        let scalars = Array(content.unicodeScalars)
        var index = 0
        
        while index < scalars.count {
            // 1. Find '@'
            while index < scalars.count && scalars[index] != "@" {
                index += 1
            }
            if index >= scalars.count { break }
            index += 1 // Skip '@'
            
            // 2. Parse Type
            var type = ""
            while index < scalars.count && (CharacterSet.alphanumerics.contains(scalars[index]) || scalars[index] == "_") {
                type.append(Character(scalars[index]))
                index += 1
            }
            
            // Skip whitespace
            while index < scalars.count && CharacterSet.whitespacesAndNewlines.contains(scalars[index]) {
                index += 1
            }
            
            // 3. Expect '{'
            if index < scalars.count && scalars[index] == "{" {
                index += 1
            } else {
                continue // Malformed, skip
            }
            
            // 4. Parse ID
            var id = ""
            while index < scalars.count && scalars[index] != "," && scalars[index] != "}" {
                id.append(Character(scalars[index]))
                index += 1
            }
            id = id.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if index < scalars.count && scalars[index] == "," {
                index += 1 // Skip comma
            }
            
            // 5. Parse Body (capture until matching '}')
            var body = ""
            var braceDepth = 1
            
            while index < scalars.count && braceDepth > 0 {
                let char = scalars[index]
                if char == "{" {
                    braceDepth += 1
                } else if char == "}" {
                    braceDepth -= 1
                }
                
                if braceDepth > 0 {
                    body.append(Character(char))
                }
                index += 1
            }
            
            let fields = parseFields(body)
            entries.append(BibTeXEntry(id: id, type: type, fields: fields))
        }
        
        return entries
    }
    
    private static func parseFields(_ body: String) -> [String: String] {
        var fields: [String: String] = [:]
        var key = ""
        var value = ""
        
        var inKey = true
        var inValue = false
        var valueDelimiter: Character? = nil
        var braceDepth = 0
        var isEscaped = false
        
        // Simple state machine
        for char in body {
            if inKey {
                if char == "=" {
                    inKey = false
                    inValue = false // Waiting for value start
                    key = key.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                } else if char == "," {
                     // Trailing comma or empty field, reset
                    key = ""
                } else {
                    key.append(char)
                }
            } else {
                // We are looking for value or inside value
                if !inValue {
                    if char.isWhitespace { continue }
                    
                    if char == "{" {
                        inValue = true
                        valueDelimiter = "}"
                        braceDepth = 1
                        value = ""
                    } else if char == "\"" {
                        inValue = true
                        valueDelimiter = "\""
                        braceDepth = 0
                        value = ""
                    } else if char.isNumber || char.isLetter {
                         // Unquoted value
                        inValue = true
                        valueDelimiter = nil // delimiter is comma or closing brace of entry
                        value = String(char)
                    }
                } else {
                    // Inside value
                    if let delimiter = valueDelimiter {
                        if delimiter == "}" {
                            // Braced value logic
                            if char == "{" {
                                braceDepth += 1
                                value.append(char)
                            } else if char == "}" {
                                braceDepth -= 1
                                if braceDepth == 0 {
                                    // End of value
                                    fields[key] = value
                                    key = ""
                                    inKey = true // Back to looking for key (after comma)
                                } else {
                                    value.append(char)
                                }
                            } else {
                                value.append(char)
                            }
                        } else if delimiter == "\"" {
                            // Quoted value logic
                            if isEscaped {
                                value.append(char)
                                isEscaped = false
                            } else if char == "\\" {
                                isEscaped = true
                                value.append(char)
                            } else if char == "\"" {
                                // End of value
                                fields[key] = value
                                key = ""
                                inKey = true
                            } else {
                                value.append(char)
                            }
                        }
                    } else {
                        // Unquoted value (numbers or macros)
                        if char == "," || char == "}" || char.isNewline {
                            // End of unquoted value (rough heuristic, assumes well-formedness or regex-extracted body)
                            fields[key] = value.trimmingCharacters(in: .whitespacesAndNewlines)
                            key = ""
                            inKey = true
                        } else {
                            value.append(char)
                        }
                    }
                }
            }
        }
        
        // Catch last field if no trailing comma
        if !key.isEmpty && !value.isEmpty {
             fields[key] = value.trimmingCharacters(in: .whitespacesAndNewlines)
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
