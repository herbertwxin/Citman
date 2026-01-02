import Foundation

struct BibTeXEntry: Identifiable, Codable, Hashable {
    var id: String
    var type: String
    var fields: [String: String]
    
    // Helper accessors
    var title: String { fields["title"] ?? "" }
    var author: String { fields["author"] ?? "" }
    var year: String { fields["year"] ?? "" }
    
    init(id: String, type: String, fields: [String: String]) {
        self.id = id
        self.type = type
        self.fields = fields
    }
}
