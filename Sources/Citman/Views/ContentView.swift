import SwiftUI

struct ContentView: View {
    @Binding var document: CitmanDocument
    @State private var selection: Set<BibTeXEntry.ID> = []
    @State private var showingAddSheet = false
    
    // Sidebar selection state
    @State private var selectedCategory: String? = "All"
    
    // Sorting state
    @State private var sortOrder = [KeyPathComparator(\BibTeXEntry.id)]

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedCategory) {
                Section("Library") {
                    NavigationLink(value: "All") {
                        Label("All Citations", systemImage: "tray.full")
                    }
                }
                
                Section("Types") {
                    ForEach(allEntryTypes, id: \.self) { type in
                        NavigationLink(value: type) {
                            Label(type.capitalized, systemImage: iconForType(type))
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 150, ideal: 200)
            .navigationTitle("Library")
        } content: {
            Table(sortedEntries, selection: $selection, sortOrder: $sortOrder) {
                TableColumn("ID", value: \.id)
                TableColumn("Type", value: \.type)
                TableColumn("Title", value: \.title)
                TableColumn("Author", value: \.author)
                TableColumn("Year", value: \.year)
            }
            .contextMenu(forSelectionType: BibTeXEntry.ID.self) { selection in
                 Button("Delete") {
                     delete(ids: selection)
                 }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSheet = true }) {
                        Label("Add Citation", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    Button(action: { delete(ids: selection) }) {
                        Label("Delete", systemImage: "trash")
                    }
                    .disabled(selection.isEmpty)
                }
            }
            .navigationTitle(selectedCategory ?? "Citations")
        } detail: {
            if let id = selection.first,
               let index = document.entries.firstIndex(where: { $0.id == id }) {
                CitationDetailView(entry: $document.entries[index])
            } else {
                ContentUnavailableView("No Selection", systemImage: "doc.text", description: Text("Select a citation to view details."))
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCitationView(document: $document)
        }
    }
    
    // MARK: - Computed Properties
    
    private var allEntryTypes: [String] {
        let types = Set(document.entries.map { $0.type.lowercased() })
        return types.sorted()
    }
    
    private var filteredEntries: [BibTeXEntry] {
        if selectedCategory == "All" || selectedCategory == nil {
            return document.entries
        } else {
            return document.entries.filter { $0.type.lowercased() == selectedCategory?.lowercased() }
        }
    }
    
    private var sortedEntries: [BibTeXEntry] {
        filteredEntries.sorted(using: sortOrder)
    }
    
    // MARK: - Helpers
    
    private func delete(ids: Set<BibTeXEntry.ID>) {
        document.entries.removeAll { ids.contains($0.id) }
        selection = []
    }
    
    private func iconForType(_ type: String) -> String {
        switch type.lowercased() {
        case "article": return "doc.text"
        case "book": return "book.closed"
        case "inproceedings": return "person.2.crop.square.stack"
        case "phdthesis", "mastersthesis": return "graduationcap"
        default: return "doc"
        }
    }
}