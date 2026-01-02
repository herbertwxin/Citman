import SwiftUI

struct CitationDetailView: View {
    @Binding var entry: BibTeXEntry
    
    var body: some View {
        Form {
            Section("Info") {
                TextField("ID", text: $entry.id)
                TextField("Type", text: $entry.type)
            }
            
            Section("Fields") {
                TextField("Title", text: Binding(
                    get: { entry.fields["title"] ?? "" },
                    set: { entry.fields["title"] = $0 }
                ))
                TextField("Author", text: Binding(
                    get: { entry.fields["author"] ?? "" },
                    set: { entry.fields["author"] = $0 }
                ))
                TextField("Year", text: Binding(
                    get: { entry.fields["year"] ?? "" },
                    set: { entry.fields["year"] = $0 }
                ))
                TextField("Journal", text: Binding(
                    get: { entry.fields["journal"] ?? "" },
                    set: { entry.fields["journal"] = $0 }
                ))
                
                // Dynamic fields - simplified for now
                // Ideally a list of other fields
            }
        }
        .padding()
    }
}
