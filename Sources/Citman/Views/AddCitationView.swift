import SwiftUI

struct AddCitationView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var document: CitmanDocument
    
    @State private var searchText: String = ""
    @State private var searchResults: [DOIService.SearchResult] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Mode", selection: $selectedTab) {
                Text("Search").tag(0)
                Text("DOI").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTab == 0 {
                searchView
            } else {
                doiView
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
                
                Button("Search") { performSearch() }
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
                    Button("Add") {
                        addEntry(doi: result.id) // CrossRef "id" is the DOI
                    }
                }
            }
            .overlay {
                if searchResults.isEmpty && !isLoading {
                    Text("No results").foregroundStyle(.secondary)
                }
            }
        }
    }
    
    // MARK: - DOI Mode
    var doiView: some View {
        Form {
            Section("Add via DOI") {
                TextField("DOI (e.g. 10.1145/1234.5678)", text: $searchText)
                Button("Fetch and Add") {
                    addEntry(doi: searchText)
                }
                .disabled(searchText.isEmpty || isLoading)
            }
            if isLoading { ProgressView() }
        }
        .padding()
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
}
