import SwiftUI
import AppKit

struct CitationDetailView: View {
    @Binding var entry: BibTeXEntry
    @State private var newFieldKey: String = ""
    @State private var newFieldValue: String = ""
    @State private var isAddingField = false
    
    // Core fields that should always appear at the top
    private let coreFields = ["title", "author", "year", "journal", "publisher", "volume", "number", "pages", "month", "doi", "url"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header: ID and Type
                HStack(alignment: .top, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Citation Key")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack {
                            TextField("ID", text: $entry.id)
                                .font(.system(.body, design: .monospaced))
                                .textFieldStyle(.roundedBorder)
                            
                            Button(action: { entry.id = entry.generateKey() }) {
                                Image(systemName: "wand.and.stars")
                            }
                            .buttonStyle(.plain)
                            .help("Auto-generate Citation Key")
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Type")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("Type", text: $entry.type)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Fields Grid
                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                    // 1. Core Fields (if they exist or are empty)
                    ForEach(coreFields, id: \.self) { key in
                        fieldRow(key: key, label: key.capitalized)
                    }
                    
                    Divider()
                    
                    // 2. Other Fields (Dynamic)
                    ForEach(otherFieldKeys, id: \.self) { key in
                        fieldRow(key: key, label: key.capitalized)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Add New Field Section
                HStack {
                    if isAddingField {
                        TextField("Key", text: $newFieldKey)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                        TextField("Value", text: $newFieldValue)
                            .textFieldStyle(.roundedBorder)
                        
                        Button(action: addNewField) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                        .buttonStyle(.plain)
                        .disabled(newFieldKey.isEmpty)
                        
                        Button(action: { isAddingField = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: { isAddingField = true }) {
                            Label("Add Field", systemImage: "plus")
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
                }
                .background(Color(NSColor.controlBackgroundColor)) // Native background
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(action: copyToClipboard) {
                            Label("Copy BibTeX", systemImage: "doc.on.doc")
                        }
                        .help("Copy citation as BibTeX")
                    }
                }
            }
            
            // MARK: - Subviews
            
            private func copyToClipboard() {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(entry.toBibTeX(), forType: .string)
            }
        
            @ViewBuilder    private func fieldRow(key: String, label: String) -> some View {
        GridRow {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .gridColumnAlignment(.trailing)
            
            TextField("", text: Binding(
                get: { entry.fields[key] ?? "" },
                set: { newValue in
                    if newValue.isEmpty {
                        // Optional: decide if empty fields should be removed or kept empty.
                        // For core fields, maybe keep them? For now, we update.
                        entry.fields[key] = newValue
                    } else {
                        entry.fields[key] = newValue
                    }
                }
            ))
            .textFieldStyle(.plain) // Clean look
            .padding(6)
            .background(Color(NSColor.textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Helpers
    
    private var otherFieldKeys: [String] {
        let allKeys = entry.fields.keys
        let other = allKeys.filter { !coreFields.contains($0) }
        return other.sorted()
    }
    
    private func addNewField() {
        guard !newFieldKey.isEmpty else { return }
        entry.fields[newFieldKey.lowercased()] = newFieldValue
        newFieldKey = ""
        newFieldValue = ""
        isAddingField = false
    }
}