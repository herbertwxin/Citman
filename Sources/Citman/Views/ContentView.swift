import SwiftUI

struct ContentView: View {
    @Binding var document: CitmanDocument
    @State private var selection: Set<BibTeXEntry.ID> = []
    @State private var showingAddSheet = false

    var body: some View {
        NavigationSplitView {
             List {
                 Label("All Citations", systemImage: "tray.full")
             }
             .navigationSplitViewColumnWidth(min: 150, ideal: 200)
        } content: {
            Table(document.entries, selection: $selection) {
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
        } detail: {
            if let id = selection.first,
               let index = document.entries.firstIndex(where: { $0.id == id }) {
                CitationDetailView(entry: $document.entries[index])
            } else {
                Text("Select a citation")
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCitationView(document: $document)
        }
    }
    
    private func delete(ids: Set<BibTeXEntry.ID>) {
        document.entries.removeAll { ids.contains($0.id) }
        selection = []
    }
}
