import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    /// Standard identifier for BibTeX files.
    static var bibtex: UTType {
        UTType("org.tug.tex.bibtex") ?? UTType.plainText
    }
}

struct CitmanDocument: FileDocument {
    var entries: [BibTeXEntry]

    init() {
        self.entries = []
    }

    // Allow reading .bib and generic text files
    static var readableContentTypes: [UTType] { 
        [.bibtex, .plainText, .text, UTType(filenameExtension: "bib")!].compactMap { $0 }
    }
    
    // Allow saving back to any of these types
    static var writableContentTypes: [UTType] { 
        [.bibtex, .plainText, .text]
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            self.entries = []
            return
        }
        
        let string = String(data: data, encoding: .utf8) 
                  ?? String(data: data, encoding: .ascii)
                  ?? ""
        
        self.entries = BibTeXParser.parse(content: string)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let content = BibTeXParser.serialize(entries: entries)
        let data = content.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }
}