import SwiftUI

struct AddCitationView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var document: CitmanDocument
    
    @State private var searchText: String = ""
    @State private var searchResults: [DOIService.SearchResult] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    @State private var selectedTab = 0
    
    // Manual Entry States
    @State private var manualType: String = "article"
    @State private var manualID: String = ""
    @State private var manualTitle: String = ""
    @State private var manualAuthor: String = ""
    @State private var manualYear: String = ""
    @State private var manualJournal: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Mode", selection: $selectedTab) {
                Text("Search").tag(0)
                Text("DOI").tag(1)
                Text("Manual").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTab == 0 {
                searchView
            } else if selectedTab == 1 {
                doiView
            } else {
                manualView
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .padding()
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .toolbar {
             ToolbarItem(placement: .cancellationAction) {
                 Button("Cancel") { dismiss() }
             }
        }
    }
    
    // MARK: - Search Mode
    var searchView: some View {
        VStack {
            HStack {
                TextField("Article Title, Author, etc.", text: $searchText)
                    .onSubmit { performSearch() }
                
                Button(action: { performSearch() }) {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .disabled(searchText.isEmpty || isLoading)
            }
            .padding(.horizontal)
            
            if isLoading {
                ProgressView().padding()
            }
            
            List(searchResults) { result in
                HStack {
                    VStack(alignment: .leading) {
                        Text(result.displayTitle)
                            .font(.headline)
                        Text(result.displayAuthor)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(action: {
                        addEntry(doi: result.id) // CrossRef "id" is the DOI
                    }) {
                        Label("Add", systemImage: "plus.circle")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .overlay {
                if searchResults.isEmpty && !isLoading {
                    ContentUnavailableView("No Results", systemImage: "magnifyingglass", description: Text("Try searching for a title or author."))
                }
            }
        }
    }
    
    // MARK: - DOI Mode
    var doiView: some View {
        Form {
            Section("Add via DOI") {
                TextField("DOI (e.g. 10.1145/1234.5678)", text: $searchText)
                Button(action: {
                    addEntry(doi: searchText)
                }) {
                    Label("Fetch and Add", systemImage: "icloud.and.arrow.down")
                }
                .disabled(searchText.isEmpty || isLoading)
            }
            if isLoading { ProgressView() }
        }
        .padding()
        .formStyle(.grouped)
    }
    
    // MARK: - Manual Mode
    var manualView: some View {
        Form {
            Section("Citation Details") {
                Picker("Type", selection: $manualType) {
                    Text("Article").tag("article")
                    Text("Book").tag("book")
                    Text("InProceedings").tag("inproceedings")
                    Text("Misc").tag("misc")
                }
                
                TextField("Citation Key (ID)", text: $manualID)
                TextField("Title", text: $manualTitle)
                TextField("Author", text: $manualAuthor)
                TextField("Year", text: $manualYear)
                TextField("Journal/Publisher", text: $manualJournal)
            }
            
            Button(action: {
                addManualEntry()
            }) {
                HStack {
                    Spacer()
                    Label("Add Entry", systemImage: "plus.circle.fill")
                    Spacer()
                }
            }
            .disabled(manualID.isEmpty || manualTitle.isEmpty)
        }
        .padding()
        .formStyle(.grouped)
    }
    
    // MARK: - Logic
    
    private func performSearch() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let results = try await DOIService.search(query: searchText)
                await MainActor.run {
                    self.searchResults = results
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func addEntry(doi: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let bibString = try await DOIService.fetchBibTeX(for: doi)
                let newEntries = BibTeXParser.parse(content: bibString)
                
                await MainActor.run {
                    if let entry = newEntries.first {
                        document.entries.append(entry)
                        dismiss()
                    } else {
                        errorMessage = "Could not parse BibTeX from response."
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func addManualEntry() {
        var fields: [String: String] = [:]
        if !manualTitle.isEmpty { fields["title"] = manualTitle }
        if !manualAuthor.isEmpty { fields["author"] = manualAuthor }
        if !manualYear.isEmpty { fields["year"] = manualYear }
        if !manualJournal.isEmpty { fields["journal"] = manualJournal }
        // Add more mapping if needed
        
        let entry = BibTeXEntry(id: manualID, type: manualType, fields: fields)
        document.entries.append(entry)
        dismiss()
    }
}